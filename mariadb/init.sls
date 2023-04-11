# vim: ft=sls

{#-
    *Meta-state*.

    This installs the mariadb package,
    manages the mariadb configuration file
    and then starts the associated mariadb service.
#}

include:
  - .package
  - .config
  - .service
  - .databases
  - .users
