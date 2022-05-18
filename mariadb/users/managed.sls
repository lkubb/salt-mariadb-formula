# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- set sls_databases_managed = tplroot ~ '.databases.managed' %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - {{ tplroot }}.package.install
  - {{ sls_config_file }}
  - {{ sls_databases_managed }}

{%- for user, config in mariadb.users.items() %}

MariaDB user {{ user }} is present:
  mysql_user.present:
    - name: {{ user }}
{%-   if config.get("socket") %}
    - unix_socket: {{ config.get("socket", false) }}
{%-   elif config.get("password") %}
    - password: {{ config.password }}
{%-   elif config.get("password_hash") %}
    - password_hash: {{ config.password_hash }}
{%-   elif config.get("passwordless") %}
    - passwordless: true
{%-   endif %}
    - require:
      - pkg: {{ mariadb.lookup.pkg.python }}
      - sls: {{ sls_config_file }}
{%- endfor %}

{%- if mariadb.users_absent %}

Unwanted MariaDB users are absent:
  mysql_user.absent:
    - names: {{ mariadb.users_absent | json }}
    - require:
      - pkg: {{ mariadb.lookup.pkg.python }}
      - sls: {{ sls_config_file }}
{%- endif %}

{%- for user, config in mariadb.users.items() %}
{%-   if config.get("grants") %}

Wanted grants for user {{ user }} are present:
  mysql_grants.present:
    - names:
{%-     for db, grants in config.grants.items() %}
      - {{ user }}_{{ db }}:
        - user: {{ user }}
        - grant: {{ grants | join(",") }}
        - database: {{ db }}
{%-     endfor %}
    - require:
      - MariaDB user {{ user }} is present
      - sls: {{ sls_databases_managed }}
{%-   endif %}

{%-   if config.get("grants_unwanted") %}

Unwanted grants for user {{ user }} are absent:
  mysql_grants.absent:
    - names:
{%-     for db in config.grants_unwanted %}
      - {{ user }}_{{ db }}
{%-     endfor %}
    - require:
      - MariaDB user {{ user }} is present
      - sls: {{ sls_databases_managed }}
{%-   endif %}
{%- endfor %}
