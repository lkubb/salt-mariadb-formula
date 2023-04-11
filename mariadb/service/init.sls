# vim: ft=sls

{#-
    Starts the mariadb service and enables it at boot time.
    Has a dependency on `mariadb.config`_.
#}

include:
  - .running
