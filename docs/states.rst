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
Has a dependency on `mariadb.config`_.


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
Has a depency on `mariadb.config.clean`_.


``mariadb.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^



``mariadb.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the mariadb service and disables it at boot time.


``mariadb.databases.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes all managed databases if ``mariadb:clean_databases`` is True.


``mariadb.users.clean``
^^^^^^^^^^^^^^^^^^^^^^^
Removes all managed user accounts and grants.


