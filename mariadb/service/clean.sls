# vim: ft=sls

{#-
    Stops the mariadb service and disables it at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

MariaDB is dead:
  service.dead:
    - name: {{ mariadb.lookup.service.name }}
    - enable: false
