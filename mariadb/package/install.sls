# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

{%- if mariadb.install.method == "repo" %}

include:
  - {{ slsdotpath }}.repo
{%- endif %}

MariaDB is installed:
  pkg.installed:
    - pkgs:
{%- if mariadb.install.client %}
      - {{ mariadb.lookup.pkg.client }}
{%- endif %}
{%- if mariadb.install.server %}
      - {{ mariadb.lookup.pkg.server }}
{%- endif %}

{#- Very crude onedir check – relenv pythonexecutable does not end with `run #}
{%- if grains.pythonexecutable.startswith("/opt/saltstack") %}

Salt can manage MariaDB:
  pip.installed:
    - name: {{ mariadb.lookup.pkg.pip }}
{%- else %}

Salt can manage MariaDB:
  pkg.installed:
    - name: {{ mariadb.lookup.pkg.python }}
{%- endif %}
