Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``mariadb``
^^^^^^^^^^^
*Meta-state*.

This installs the mariadb package,
manages the mariadb configuration,
creates TLS certificates if they have been configured,
starts the MariaDB service,
initializes a Vault connection if configured
and then manages configured databases and user accounts.


``mariadb.package``
^^^^^^^^^^^^^^^^^^^
Installs the mariadb package only.


``mariadb.package.repo``
^^^^^^^^^^^^^^^^^^^^^^^^
This state will install the configured mariadb repository.
This works for apt/dnf/yum/zypper-based distributions only by default.


``mariadb.config``
^^^^^^^^^^^^^^^^^^
Manages the mariadb service configuration.
Has a dependency on `mariadb.package`_.


``mariadb.cert``
^^^^^^^^^^^^^^^^
Manages MariaDB server/client certificates as well as the trusted
root CA certificate.

Pulls the certificate paths directly from the configuration.
All three values ``ssl_key``, ``ssl_cert`` and ``ssl_ca`` must be specified
in ``mysqld``/``mariadb`` (server) or ``mysql`` (client) for this
state to apply.


``mariadb.service``
^^^^^^^^^^^^^^^^^^^
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


``mariadb.vault``
^^^^^^^^^^^^^^^^^
Connects the local database to a Vault database secret plugin
and manages associated roles.

Requires ``vault:init`` set to true to be included in the
meta state by default.


``mariadb.databases``
^^^^^^^^^^^^^^^^^^^^^
Manages databases.
Has a dependency on `mariadb.service`_.


``mariadb.users``
^^^^^^^^^^^^^^^^^
Manages user accounts and their database grants.
Has a dependency on `mariadb.databases`_.


``mariadb.clean``
^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``mariadb`` meta-state
in reverse order, i.e.
removes managed databases if ``clean_databases`` is true,
removes managed user accounts,
removes the Vault connection if configured,
stops the service,
removes the configuration file and then
uninstalls the package.


``mariadb.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the mariadb package.
Has a dependency on `mariadb.config.clean`_.


``mariadb.package.repo.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This state will remove the configured mariadb repository.
This works for apt/dnf/yum/zypper-based distributions only by default.


``mariadb.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the mariadb service and has a
dependency on `mariadb.service.clean`_.


``mariadb.cert.clean``
^^^^^^^^^^^^^^^^^^^^^^
Removes the managed MariaDB server/client certificates as well as the trusted
root CA certificate.


``mariadb.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the mariadb service and disables it at boot time.


``mariadb.vault.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Removes the Vault connection, associated roles and the ``vault`` user account.


``mariadb.databases.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes all managed databases if ``mariadb:clean_databases`` is True.


``mariadb.users.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Removes all managed user accounts and grants.


