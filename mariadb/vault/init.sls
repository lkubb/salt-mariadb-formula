# vim: ft=sls

{#-
    Connects the local database to a Vault database secret plugin
    and manages associated roles.

    Requires ``vault:init`` set to true to be included in the
    meta state by default.
#}

include:
  - .setup
