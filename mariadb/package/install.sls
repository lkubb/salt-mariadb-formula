# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

mariadb-package-install-pkg-installed:
  pkg.installed:
    - pkgs:
{%- if mariadb.install.client %}
      - {{ mariadb.lookup.pkg.client }}
{%- endif %}
{%- if mariadb.install.server %}
      - {{ mariadb.lookup.pkg.server }}
{%- endif %}

Salt can manage MariaDB:
  pkg.installed:
    - name: {{ mariadb.lookup.pkg.python }}
