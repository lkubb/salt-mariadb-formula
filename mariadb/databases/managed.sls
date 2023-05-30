# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_running = tplroot ~ ".service.running" %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - {{ sls_service_running }}

{%- for db, config in mariadb.databases.items() %}

MariaDB database {{ db }} is present:
  mysql_database.present:
    - name: {{ db }}
{%-   if config.get("character_set") %}
    - character_set: {{ config.character_set }}
{%-   endif %}
{%-   if config.get("collate") %}
    - collate: {{ config.collate }}
{%-   endif %}
    - connection_unix_socket: {{ mariadb._socket }}
    - require:
      - sls: {{ sls_service_running }}
{%- endfor %}

{%- if mariadb.databases_absent %}

Unwanted MariaDB databases are absent:
  mysql_database.absent:
    - names: {{ mariadb.databases_absent | json }}
    - connection_unix_socket: {{ mariadb._socket }}
    - require:
      - sls: {{ sls_service_running }}
{%- endif %}
