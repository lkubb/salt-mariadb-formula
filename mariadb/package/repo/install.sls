# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

# There is no need for python-apt anymore.

{%- for reponame, enabled in mariadb.lookup.enablerepo.items() %}
{%-   if enabled %}

MariaDB {{ reponame }} repository is available:
  pkgrepo.managed:
{%-     for conf, val in mariadb.lookup.repos[reponame].items() %}
    - {{ conf }}: {{ val.format(version=mariadb.install.version) if val is string else val }}
{%-     endfor %}
{%-     if mariadb.lookup.pkg_manager in ["dnf", "yum", "zypper"] %}
    - enabled: 1
{%-     endif %}
    - require_in:
      - MariaDB is installed

{%-   else %}

MariaDB {{ reponame }} repository is disabled:
  pkgrepo.absent:
{%-     for conf in ["name", "ppa", "ppa_auth", "keyid", "keyid_ppa", "copr"] %}
{%-       if conf in mariadb.lookup.repos[reponame] %}
{%-           set val = mariadb.lookup.repos[reponame][conf] %}
    - {{ conf }}: {{ val.format(version=mariadb.install.version) if val is string else val }}
{%-       endif %}
{%-     endfor %}
    - require_in:
      - MariaDB is installed
{%-   endif %}
{%- endfor %}
