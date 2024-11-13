.. _readme:

MariaDB Formula
===============

|img_sr| |img_pc|

.. |img_sr| image:: https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg
   :alt: Semantic Release
   :scale: 100%
   :target: https://github.com/semantic-release/semantic-release
.. |img_pc| image:: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white
   :alt: pre-commit
   :scale: 100%
   :target: https://github.com/pre-commit/pre-commit

Manage MariaDB or a Galera cluster of MariaDB nodes with Salt.

.. contents:: **Table of Contents**
   :depth: 1

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please refer to:

- `how to configure the formula with map.jinja <map.jinja.rst>`_
- the ``pillar.example`` file
- the `Special notes`_ section

Special notes
-------------
- Certificates are automatically generated if configured.
- Optionally, there is also support for initializing a connection to HashiCorp Vault.
- The MariaDB root user has no password by default and running ``mysql_secure_installation`` `is discouraged <https://salsa.debian.org/mariadb-team/mariadb-10.5/-/blob/52ed70783405f51c2633be9749ec7ec8ea8fd01f/debian/mariadb-server-10.5.README.Debian#L76-95>`_. There is no option to set the root password.

Configuration
-------------
An example pillar is provided, please see `pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in `map.jinja`.


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



Contributing to this repo
-------------------------

Commit messages
^^^^^^^^^^^^^^^

**Commit message formatting is significant!**

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``. ::

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.
