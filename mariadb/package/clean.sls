# vim: ft=sls

{#-
    Removes the mariadb package.
    Has a dependency on `mariadb.config.clean`_.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - {{ sls_config_clean }}
  - {{ slsdotpath }}.repo.clean

MariaDB is removed:
  pkg.removed:
    - pkgs:
{%- if mariadb.install.client %}
      - {{ mariadb.lookup.pkg.client[mariadb.install.method] }}
{%- endif %}
{%- if mariadb.install.server %}
      - {{ mariadb.lookup.pkg.server[mariadb.install.method] }}
{%-   if mariadb.install.galera and mariadb.lookup.pkg.galera[mariadb.install.method] %}
      - {{ mariadb.lookup.pkg.galera[mariadb.install.method] }}
{%-   endif %}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}
