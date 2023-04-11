# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``mariadb`` meta-state
    in reverse order, i.e.
    stops the service,
    removes the configuration file and then
    uninstalls the package.
#}

include:
  - .databases.clean
  - .users.clean
  - .service.clean
  - .config.clean
  - .package.clean
