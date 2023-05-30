# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

{%- if mariadb.install.method == "repo" %}

include:
  - {{ slsdotpath }}.repo
{%- endif %}

MariaDB is installed:
  pkg.installed:
    - pkgs:
{%- if mariadb.install.client %}
      - {{ mariadb.lookup.pkg.client[mariadb.install.method] }}
{%- endif %}
{%- if mariadb.install.server %}
      - {{ mariadb.lookup.pkg.server[mariadb.install.method] }}
{%-   if mariadb.install.galera and mariadb.lookup.pkg.galera[mariadb.install.method] %}
      - {{ mariadb.lookup.pkg.galera[mariadb.install.method] }}
{%-   endif %}
{%- endif %}


{#- Very crude onedir check – relenv pythonexecutable does not end with `run #}
{%- if grains.pythonexecutable.startswith("/opt/saltstack") %}

Salt can manage MariaDB:
  pip.installed:
    - name: {{ mariadb.lookup.pkg.pip }}
{%- else %}

Salt can manage MariaDB:
  pkg.installed:
    - name: {{ mariadb.lookup.pkg.python }}
{%- endif %}


{#-
    During the first run, imitate mariadb-secure-installation (it's interactive).
    It should not be necessary with (non-ancient) versions >= 10.4 though.
    This requires the client to be installed.
#}

{%- if grains.get("systemd") and mariadb.install.client and mariadb.lookup.pkg.server[mariadb.install.method] not in salt["pkg.list_pkgs"]() %}

MariaDB secure installation is performed:
  cmd.run:
    - name: |
        systemctl start {{ mariadb.lookup.service.name }} && mysql -sfu root <<EOS
        -- Socket auth is already enabled if this command succeeds (>= v10.4).
        -- That also means root has a password set to 'invalid'.
        -- The rest should be redundant, but should not hurt to run anyways.
        -- Delete anonymous users.
        DELETE FROM mysql.global_priv WHERE User='';
        -- Disallow remote root login.
        DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        -- Remove test database.
        DROP DATABASE IF EXISTS test;
        -- Remove any lingering permissions to the test database.
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        -- Apply changes immediately.
        FLUSH PRIVILEGES;
        EOS
        systemctl stop mariadb
    - require:
      - MariaDB is installed
{%- endif %}
