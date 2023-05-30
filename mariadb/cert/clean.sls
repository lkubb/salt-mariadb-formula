# vim: ft=sls

{#-
    Removes the managed MariaDB server/client certificates as well as the trusted
    root CA certificate.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - {{ sls_service_clean }}

{%- set config = mariadb.config.get("mariadb", {}) %}
{%- set config2 = mariadb.config.get("mysqld", {}) %}
{%- if  (config.get("ssl_cert") or config2.get("ssl_cert")) and
        (config.get("ssl_key") or config2.get("ssl_key")) and
        (config.get("ssl_ca") or config2.get("ssl_ca")) %}

MariaDB server key/cert/ca is absent:
  file.absent:
    - names:
      - {{ config.get("ssl_key") or config2.get("ssl_key") }}
      - {{ config.get("ssl_cert") or config2.get("ssl_cert") }}
      - {{ config.get("ssl_ca") or config2.get("ssl_ca") }}
    - require:
      - sls: {{ sls_service_clean }}
{%- endif %}

{%- set config = mariadb.config.get("mariadb-client", {}) %}
{%- set config2 = mariadb.config.get("mysql", {}) %}
{%- if  (config.get("ssl_cert") or config2.get("ssl_cert")) and
        (config.get("ssl_key") or config2.get("ssl_key")) and
        (config.get("ssl_ca") or config2.get("ssl_ca")) %}

MariaDB client key/cert/ca is absent:
  file.absent:
    - names:
      - {{ config.get("ssl_key") or config2.get("ssl_key") }}
      - {{ config.get("ssl_cert") or config2.get("ssl_cert") }}
      - {{ config.get("ssl_ca") or config2.get("ssl_ca") }}
    - require:
      - sls: {{ sls_service_clean }}
{%- endif %}

