# vim: ft=sls

{#-
    Starts the mariadb service and enables it at boot time.
    If ``manage_firewall`` is true, will also ensure the service
    ports are exposed.
    Has a dependency on `mariadb.config`_.

    Notes for Galera (``install:galera`` is true):

      * If ``config:mariadb:wsrep_cluster_address`` is unspecified, will initialize a new cluster.
      * If you need to bootstrap a cluster after shutting down all nodes,
        you will need to pass ``pillar='{"galera_bootstrap": false}'`` to ``state.apply``.
      * Ensure that all service ports are exposed to other nodes in the cluster, otherwise
        starting the service will fail.
#}

include:
  - .running
