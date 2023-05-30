# vim: ft=sls

{#-
    Manages MariaDB server/client certificates as well as the trusted
    root CA certificate.

    Pulls the certificate paths directly from the configuration.
    All three values ``ssl_key``, ``ssl_cert`` and ``ssl_ca`` must be specified
    in ``mysqld``/``mariadb`` (server) or ``mysql`` (client) for this
    state to apply.
#}

include:
  - .managed
