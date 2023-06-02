# vim: ft=yaml
---
mariadb:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    enablerepo:
      stable: true
    config: '/etc/mysql/my.cnf'
    service:
      name: mysql
    config_defaults:
      pkg:
        client: {}
        client-mariadb: {}
        embedded: {}
        galera: {}
        mysql: {}
        mysql_upgrade: {}
        mysqladmin: {}
        mysqlbinlog: {}
        mysqlcheck: {}
        mysqld: {}
        mysqldump: {}
        mysqlimport: {}
        mysqlshow: {}
        mysqlslap: {}
        server: {}
      repo:
        client: {}
        client-mariadb: {}
        embedded: {}
        galera: {}
        mysql: {}
        mysql_upgrade: {}
        mysqladmin: {}
        mysqlbinlog: {}
        mysqlcheck: {}
        mysqld: {}
        mysqldump: {}
        mysqlimport: {}
        mysqlshow: {}
        mysqlslap: {}
        server: {}
    config_galera:
      binlog_format: ROW
      default_storage_engine: InnoDB
      innodb_autoinc_lock_mode: 2
      innodb_doublewrite: 1
      wsrep_on: 'ON'
    group: mysql
    libgalera:
      pkg: /usr/lib/galera/libgalera_smm.so
      repo: /usr/lib/galera/libgalera_smm.so
    pkg:
      client:
        pkg: mariadb-client
        repo: mariadb-client
      galera:
        pkg: false
        repo: false
      pip: pymysql
      python: python3-mysqldb
      server:
        pkg: mariadb-server
        repo: mariadb-server
    socket:
      pkg: /run/mysqld/mysqld.sock
      repo: /run/mysqld/mysqld.sock
    user: mysql
  cert:
    ca_server: null
    cn: null
    days_remaining: 7
    days_valid: 30
    intermediate: []
    root: ''
    san: []
    signing_cert: null
    signing_policy: null
    signing_private_key: null
    signing_private_key_passphrase: null
  clean_databases: false
  config: {}
  databases: {}
  databases_absent: []
  install:
    client: true
    galera: false
    method: pkg
    server: true
    version: '10.11'
  manage_firewall: false
  users: []
  users_absent: []
  vault:
    connection_name: mariadb
    database_mount: database
    init: false
    mariadb_host: null
    mariadb_port: null
    max_connection_lifetime: 0s
    max_idle_connections: 0
    max_open_connections: 4
    plugin_version: null
    tls_server_name: ''
    tls_skip_verify: false
    user:
      grants:
        - db: '*.*'
          grant: all privileges
      host: '%'
      keep_managing: true
      name: vault
  vault_roles: []

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://mariadb/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   mariadb-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      mariadb-config-file-file-managed:
        - 'example.tmpl.jinja'

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
