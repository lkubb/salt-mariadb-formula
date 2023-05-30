# vim: ft=sls

{#-
    *Meta-state*.

    This installs the mariadb package,
    manages the mariadb configuration,
    creates TLS certificates if they have been configured,
    starts the MariaDB service,
    initializes a Vault connection if configured
    and then manages configured databases and user accounts.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - .package
  - .config
  - .cert
  - .service
{%- if mariadb.vault.init %}
  - .vault
{%- endif %}
  - .databases
  - .users
