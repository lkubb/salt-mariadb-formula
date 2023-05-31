# vim: ft=sls

{#-
    Removes all managed user accounts and grants.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

{%- for user in mariadb.users %}
{%-   if user.get("grants") %}

Wanted grants for user {{ user.name }} are absent:
  mysql_grants.absent:
    - names:
{%-     for db in config.grants %}
      - {{ user.name }}_{{ grant.get("db", loop.index) }}:
        - user: {{ user.name }}
        - grant: {{ grant.get("grants", []) | join(",") }}
        - database: {{ grant.get("db", "null") }}
        - host: {{ user.get("host", "localhost") }}
{%-     endfor %}
    - connection_unix_socket: {{ mariadb._socket }}
{%-   endif %}
{%- endfor %}

{%- if mariadb.users %}

Wanted MariaDB users are absent:
  mysql_user.absent:
    - names:
{%-   for user in mariadb.users %}
      - {{ user | first }}:
        - host: {{ user.get("host", "localhost") }}
{%-   endfor %}
    - connection_unix_socket: {{ mariadb._socket }}
    - require:
      - Wanted grants for user {{ user.name }} are absent
{%- endif %}
