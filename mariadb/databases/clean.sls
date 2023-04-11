# vim: ft=sls

{#-
    Removes all managed databases if ``mariadb:clean_databases`` is True.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

{%- if mariadb.databases and mariadb.clean_databases %}

Wanted MariaDB databases are absent:
  mysql_database.absent:
    - names: {{ mariadb.databases.keys() | list | json }}
{%- endif %}
