# vim: ft=sls

{#-
    Manages user accounts and their database grants.
    Has a dependency on `mariadb.databases`_.
#}

include:
  - .managed
