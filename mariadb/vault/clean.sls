# vim: ft=sls

{#-
    Removes the Vault connection, associated roles and the ``vault`` user account.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

{%- for role in mariadb.vault_roles %}

Vault MariaDB role {{ role.name }} is absent:
  vault_db.role_absent:
    - name: {{ role.name }}
    - mount: {{ mariadb.vault.database_mount }}
    - require_in:
      - Vault MariaDB connection is absent
{%- endfor %}

Vault MariaDB connection is absent:
  vault_db.connection_absent:
    - name: {{ mariadb.vault.connection_name }}
    - mount: {{ mariadb.vault.database_mount }}

{%- if mariadb.vault.user.keep_managing %}

Vault user account privileges are absent:
  mysql_grants.absent:
    - grant: {{ mariadb.vault.user.privileges | json }}
    - database: '{{ mariadb.vault.user.db }}'
    - user: {{ mariadb.vault.user.name }}
    - host: '{{ mariadb.vault.user.host }}'
    - connection_unix_socket: {{ mariadb._socket }}
    - require:
      - Vault MariaDB connection is absent

Vault user account is absent:
  mysql_user.absent:
    - name: {{ mariadb.vault.user.name }}
    - host: {{ mariadb.vault.user.host }}
    - connection_unix_socket: {{ mariadb._socket }}
    - require:
      - Vault user account privileges are absent
{%- endif %}
