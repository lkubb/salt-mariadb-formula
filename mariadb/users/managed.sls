# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- set sls_databases_managed = tplroot ~ ".databases.managed" %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - {{ tplroot }}.package.install
  - {{ sls_config_file }}
  - {{ sls_databases_managed }}

{%- for user in mariadb.users %}

MariaDB user {{ user.name }}@{{ user.get("host", "localhost") }} is present:
  mysql_user.present:
    - name: {{ user.name }}
    - host: {{ user.get("host", "localhost") }}
{%-   if user.get("socket") %}
    - unix_socket: {{ user.get("socket", false) }}
{%-   elif user.get("password") %}
    - password: {{ user.password }}
{%-   elif user.get("password_hash") %}
    - password_hash: {{ user.password_hash }}
{%-   elif user.get("passwordless") %}
    - allow_passwordless: true
{%-   endif %}
    - password_column: {{ user.get("password_column", "null") }}
    - auth_plugin: {{ user.get("auth_plugin", "mysql_native_password") }}
    - connection_unix_socket: {{ mariadb._socket }}
    - require:
      - Salt can manage MariaDB
      - sls: {{ sls_config_file }}
{%- endfor %}

{%- if mariadb.users_absent %}

Unwanted MariaDB users are absent:
  mysql_user.absent:
    - names:
{%-   for user in mariadb.users_absent %}
{%-     if user is dict %}
      - {{ user | first }}:
        - host: {{ user.get("host", "localhost") }}
{%-     else %}
      - {{ user }}:
        - host: localhost
{%-     endif %}
{%-   endfor %}
    - connection_unix_socket: {{ mariadb._socket }}
    - require:
      - Salt can manage MariaDB
      - sls: {{ sls_config_file }}
{%- endif %}

{%- for user in mariadb.users %}
{%-   if user.get("grants") %}

Wanted grants for user {{ user.name }} are present:
  mysql_grants.present:
    - names:
{%-     for grant in user.grants %}
      - {{ user.name }}_{{ grant.get("db", loop.index) }}:
        - user: {{ user.name }}
        - grant: {{ grant.get("grants", []) | join(",") }}
        - host: {{ user.get("host", "localhost") }}
        - database: {{ grant.get("db", "null") }}
        - grant_option: {{ user.get("grant_option") | to_bool }}
        - escape: {{ user.get("escape", true) | to_bool }}
        - revoke_first: {{ user.get("revoke_first") | to_bool }}
{%-       if user.get("ssl_option") %}
        - ssl_option: {{ user.ssl_option | json }}
{%-       endif %}
{%-     endfor %}
    - connection_unix_socket: {{ mariadb._socket }}
    - require:
      - MariaDB user {{ user.name }}@{{ user.get("host", "localhost") }} is present
      - sls: {{ sls_databases_managed }}
{%-   endif %}

{%-   if user.get("grants_unwanted") %}

Unwanted grants for user {{ user.name }} are absent:
  mysql_grants.absent:
    - names:
{%-     for grant in user.grants_unwanted %}
      - {{ user.name }}_{{ grant.get("db", loop.index) }}:
        - user: {{ user.name }}
        - grant: {{ grant.get("grants", []) | join(",") }}
        - database: {{ grant.get("db", "null") }}
        - host: {{ user.get("host", "localhost") }}
{%-     endfor %}
    - connection_unix_socket: {{ mariadb._socket }}
    - require:
      - MariaDB user {{ user.name }}@{{ user.get("host", "localhost") }} is present
      - sls: {{ sls_databases_managed }}
{%-   endif %}
{%- endfor %}
