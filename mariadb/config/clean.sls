# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - {{ sls_service_clean }}

{%- if "config_dir" not in mariadb.lookup %}

MariaDB config is absent:
  file.absent:
    - name: {{ mariadb.lookup.config }}
    - require:
      - sls: {{ sls_service_clean }}
{%- else %}

MariaDB scope configs are absent:
  file.absent:
    - names:
{%-   for scope in mariadb.lookup.group_file_mapping %}
      - {{ mariadb.lookup.config_dir | path_join(mariadb.lookup.config_files[scope]) }}
{%-   endfor %}
    - require:
      - sls: {{ sls_service_clean }}
{%- endif %}
