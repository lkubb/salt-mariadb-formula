# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

mariadb-service-clean-service-dead:
  service.dead:
    - name: {{ mariadb.lookup.service.name }}
    - enable: False
