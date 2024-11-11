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
    - character_set: {{ config.get("character_set", "null") }}
    - collate: {{ config.get("collate", null) }}
    - connection_unix_socket: {{ mariadb._socket }}
    # Sometimes, we're too fast after the service was restarted.
    - retry:
        attempts: 5
        interval: 2
    - require:
      - sls: {{ sls_service_running }}
{%- endfor %}

{%- if mariadb.databases_absent %}

Unwanted MariaDB databases are absent:
  mysql_database.absent:
    - names: {{ mariadb.databases_absent | json }}
    - connection_unix_socket: {{ mariadb._socket }}
    # Sometimes, we're too fast after the service was restarted.
    - retry:
        attempts: 5
        interval: 2
    - require:
      - sls: {{ sls_service_running }}
{%- endif %}
