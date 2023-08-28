# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_running = tplroot ~ ".service.running" %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}
{%- set vault_pw = salt["random.get_str"](32, punctuation=false) %}
{%- set host =  mariadb.vault.mariadb_host or
                grains.get("fqdn") or
                ((grains.get("fqdns") or [(mariadb.config.get("mariadb") or mariadb.config.get("mysqld", {}).get("bind-address", "127.0.0.1"))]) | first) %}
{%- set port =  mariadb.vault.mariadb_port or
                (mariadb.config.get("mariadb") or mariadb.config.get("mysqld", {})).get("port", "3306") %}

include:
  - {{ sls_service_running }}

Vault user account is present:
  mysql_user.present:
    - name: {{ mariadb.vault.user.name }}
    - password: {{ vault_pw }}
    - host: '{{ mariadb.vault.user.host }}'
    - connection_unix_socket: {{ mariadb._socket }}
    - unless:
{%- if mariadb.vault.user.keep_managing %}
      - fun: mysql.user_info
        user: {{ mariadb.vault.user.name }}
        host: '{{ mariadb.vault.user.host }}'
        connection_unix_socket: {{ mariadb._socket }}
{%- else %}
      - '{{ salt["vault_db.fetch_connection"](mariadb.vault.connection_name, mount=mariadb.vault.database_mount) is not none | lower }}'
{%- endif %}
    - require:
      - sls: {{ sls_service_running }}

# User accounts need the privileges which they issue to other ones
Vault user account has privileges:
  mysql_grants.present:
    - names:
{%- for grant in mariadb.vault.user.grants %}
        - vault_grant_{{ grant.db }}_{{ grant.grant }}:
          - grant: {{ grant.grant }}
          - database: '{{ grant.db }}'
{%- endfor %}
    - user: {{ mariadb.vault.user.name }}
    - host: '{{ mariadb.vault.user.host }}'
    - connection_unix_socket: {{ mariadb._socket }}
{%- if not mariadb.vault.user.keep_managing %}
    - onchanges:
      - Vault user account is present
{%- else %}
    - require:
      - Vault user account is present
{%- endif %}

Vault MariaDB connection is managed:
  vault_db.connection_present:
    - name: {{ mariadb.vault.connection_name }}
    - mount: {{ mariadb.vault.database_mount }}
    - rotate: true
    - allowed_roles: {{ mariadb.vault_roles | map(attribute="name") | list | json }}
    - plugin: mysql
    - version: {{ mariadb.vault.plugin_version or "null" }}
    - connection_url: {%- raw %} '{{username}}:{{password}}@tcp({%- endraw %}{{ host }}:{{ port }})/'
    - username: vault
    - password: {{ vault_pw }}
    - max_open_connections: {{ mariadb.vault.max_open_connections }}
    - max_idle_connections: {{ mariadb.vault.max_idle_connections }}
    - max_connection_lifetime: {{ mariadb.vault.max_connection_lifetime }}
    - tls_ca: {{ mariadb.cert.root | json }}
    - tls_server_name: {{ mariadb.vault.tls_server_name }}
    - tls_skip_verify: {{ mariadb.vault.tls_skip_verify }}
    - require:
      - Vault user account has privileges

{%- for role in mariadb.vault_roles %}

Vault MariaDB role {{ role.name }} is present:
  vault_db.role_present:
    - name: {{ role.name }}
    - mount: {{ mariadb.vault.database_mount }}
    - connection: {{ mariadb.vault.connection_name }}
    - creation_statements: >-
        {{ role.definition | json }}
{%-   if role.get("revocation") %}
    - revocation_statements: >-
        {{ role.revocation | json }}
{%-   endif %}
    - default_ttl: {{ role.get("default_ttl") or "null" }}
    - max_ttl: {{ role.get("max_ttl") or "null" }}
    - require:
      - Vault MariaDB connection is managed
{%- endfor %}
