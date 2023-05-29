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

Manage MariaDB with Salt.

.. contents:: **Table of Contents**
   :depth: 1

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please refer to:

- `how to configure the formula with map.jinja <map.jinja.rst>`_
- the ``pillar.example`` file
- the `Special notes`_ section

Special notes
-------------
- On Debian, MariaDB root user has no password by default and running ``mysql_secure_installation`` `is discouraged <https://salsa.debian.org/mariadb-team/mariadb-10.5/-/blob/52ed70783405f51c2633be9749ec7ec8ea8fd01f/debian/mariadb-server-10.5.README.Debian#L76-95>`_. Since this formula is currently targeted to Debian only, there is no option to set the root password.

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
manages the mariadb configuration file
and then starts the associated mariadb service.


``mariadb.package``
^^^^^^^^^^^^^^^^^^^
Installs the mariadb package only.


``mariadb.config``
^^^^^^^^^^^^^^^^^^
Manages the mariadb service configuration.
Has a dependency on `mariadb.package`_.


``mariadb.service``
^^^^^^^^^^^^^^^^^^^
Starts the mariadb service and enables it at boot time.
Has a dependency on `mariadb.config`_.


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
stops the service,
removes the configuration file and then
uninstalls the package.


``mariadb.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the mariadb package.
Has a dependency on `mariadb.config.clean`_.


``mariadb.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the mariadb service and has a
dependency on `mariadb.service.clean`_.


``mariadb.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the mariadb service and disables it at boot time.


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

Testing
-------

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

   $ gem install bundler
   $ bundle install
   $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``mariadb`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.
