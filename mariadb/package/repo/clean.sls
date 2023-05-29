# vim: ft=sls

{#-
    This state will remove the configured mariadb repository.
    This works for apt/dnf/yum/zypper-based distributions only by default.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}


{%- if mariadb.lookup.pkg_manager not in ["apt", "dnf", "yum", "zypper"] %}
{%-   if salt["state.sls_exists"](slsdotpath ~ "." ~ mariadb.lookup.pkg_manager ~ ".clean") %}

include:
  - {{ slsdotpath ~ "." ~ mariadb.lookup.pkg_manager ~ ".clean" }}
{%-   endif %}

{%- else %}
{%-   for reponame, enabled in mariadb.lookup.enablerepo.items() %}
{%-     if enabled %}

MariaDB {{ reponame }} repository is absent:
  pkgrepo.absent:
{%-       for conf in ["name", "ppa", "ppa_auth", "keyid", "keyid_ppa", "copr"] %}
{%-         if conf in mariadb.lookup.repos[reponame] %}
{%-           set val = mariadb.lookup.repos[reponame][conf] %}
    - {{ conf }}: {{ val.format(version=mariadb.install.version) if val is string else val }}
{%-         endif %}
{%-       endfor %}
{%-     endif %}
{%-   endfor %}
{%- endif %}
