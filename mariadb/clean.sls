# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``mariadb`` meta-state
    in reverse order, i.e.
    removes managed databases if ``clean_databases`` is true,
    removes managed user accounts,
    removes the Vault connection if configured,
    stops the service,
    removes the configuration file and then
    uninstalls the package.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - .databases.clean
  - .users.clean
{%- if mariadb.vault.init %}
  - .vault.clean
{%- endif %}
  - .service.clean
  - .config.clean
  - .package.clean
