# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- set sls_cert_managed = tplroot ~ ".cert.managed" %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - {{ sls_config_file }}
  - {{ sls_cert_managed }}

{%- if mariadb.install.galera and (pillar.get("galera_bootstrap") or mariadb.config.mariadb["wsrep_cluster_address"] == "gcomm://") %}
{%-   set grastate = (mariadb.config.get("mariadb") or mariadb.config.get("mysqld", {})).get("datadir", "/var/lib/mysql") | path_join("grastate.dat") %}

MariaDB Galera cluster is initialized:
  cmd.{{ "run" if pillar.get("galera_bootstrap") else "wait" }}:  # noqa: 213
    # taken from galera_new_cluster
    - name: |
        systemctl set-environment _WSREP_NEW_CLUSTER='--wsrep-new-cluster' && \
            systemctl restart '{{ mariadb.lookup.service.name }}'
        extcode=$?
        systemctl set-environment _WSREP_NEW_CLUSTER=''
        exit $extcode
{%-   if not pillar.get("galera_bootstrap") %}
    - watch:
      - sls: {{ sls_config_file }}
      - sls: {{ sls_cert_managed }}
{%-   endif %}
    - require_in:
      - MariaDB is running
    - onlyif:
      - "test -f '{{ grastate }}' || exit 0 && grep -q 'safe_to_bootstrap: 1' '{{ grastate }}'"
{%- endif %}

{%- if grains.os_family == "RedHat" and mariadb.manage_firewall %}

MariaDB services are known:
  firewalld.service:
    - names:
      - mariadb:
        - ports:
          - {{ mariadb | traverse("config:mariadb:port", mariadb | traverse("config:mysqld:port", "3306")) }}/tcp
{%-   if mariadb.install.galera %}
{%-     set node_addr = (mariadb | traverse("config:mariadb:wsrep_node_address", "0.0.0.0:4567")).split(":", maxsplit=1) %}
{%-     set recv_addr = (mariadb | traverse("config:mariadb:wsrep_provider_options:ist.recv_addr", "0.0.0.0:4568")).split(":", maxsplit=1) %}
{%-     set sst_addr = (mariadb | traverse("config:mariadb:wsrep_sst_receive_address", "0.0.0.0:4444")).split(":", maxsplit=1) %}
      - mariadb_galera:
        - ports:
          - {{ (node_addr | last) if (node_addr | length) > 1 else "4567" }}/tcp
          - {{ (node_addr | last) if (node_addr | length) > 1 else "4567" }}/udp
          - {{ (recv_addr | last) if (recv_addr | length) > 1 else "4568" }}/tcp
          - {{ (sst_addr | last) if (sst_addr | length) > 1 else "4444" }}/tcp
{%-   endif %}

MariaDB ports are open:
  firewalld.present:
    - name: public
    - services:
      - mariadb
{%-   if mariadb.install.galera %}
      - mariadb_galera
{%-   endif %}
    - require:
      - MariaDB services are known
    - require_in:
      - MariaDB is running
{%- endif %}

MariaDB is running:
  service.running:
    - name: {{ mariadb.lookup.service.name }}
    - enable: true
{%- if not mariadb.install.galera or
        (
          mariadb.install.galera and not
            (
              pillar.get("galera_bootstrap") or
              mariadb.config.mariadb["wsrep_cluster_address"] == "gcomm://"
            )
        ) %}
    - watch:
      - sls: {{ sls_config_file }}
      - sls: {{ sls_cert_managed }}
{%- endif %}
