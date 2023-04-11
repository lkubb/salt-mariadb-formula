# vim: ft=sls

{#-
    Removes all managed user accounts and grants.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

{%- for user, config in mariadb.users.items() %}
{%-   if config.get("grants") %}

Wanted grants for user {{ user }} are absent:
  mysql_grants.absent:
    - names:
{%-     for db in config.grants %}
      - {{ user }}_{{ db }}
{%-     endfor %}
{%-   endif %}
{%- endfor %}

{%- if mariadb.users %}

Wanted MariaDB users are absent:
  mysql_user.absent:
    - names: {{ mariadb.users.keys() | list | json }}
{%- endif %}
