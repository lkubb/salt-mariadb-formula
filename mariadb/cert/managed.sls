# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}

include:
  - {{ sls_config_file }}

{%- set config = mariadb.config.get("mariadb", {}) %}
{%- set config2 = mariadb.config.get("mysqld", {}) %}
{%- set ca_cert = [] %}
{%- if  (config.get("ssl_cert") or config2.get("ssl_cert")) and
        (config.get("ssl_key") or config2.get("ssl_key")) and
        (config.get("ssl_ca") or config2.get("ssl_ca")) %}
{%-     do ca_cert.append(config.get("ssl_ca") or config2.get("ssl_ca")) %}

MariaDB server certificate private key is managed:
  x509.private_key_managed:
    - name: {{ config.get("ssl_key") or config2.get("ssl_key") }}
    - algo: rsa
    - keysize: 2048
    - new: true
{%-   if salt["file.file_exists"](config.get("ssl_key") or config2.get("ssl_key")) %}
    - prereq:
      - MariaDB server certificate is managed
{%-   endif %}
    - makedirs: true
    - user: {{ mariadb.lookup.user }}
    - group: {{ mariadb.lookup.group }}
    - require:
      - sls: {{ sls_config_file }}

MariaDB server certificate is managed:
  x509.certificate_managed:
    - name: {{ config.get("ssl_cert") or config2.get("ssl_cert") }}
    - ca_server: {{ mariadb.cert.ca_server or "null" }}
    - signing_policy: {{ mariadb.cert.signing_policy or "null" }}
    - signing_cert: {{ mariadb.cert.signing_cert or "null" }}
    - signing_private_key: {{ mariadb.cert.signing_private_key or
                              (config.get("ssl_cert") or config2.get("ssl_cert") if not mariadb.cert.ca_server and not mariadb.cert.signing_cert else "null") }}
    - private_key: {{ config.get("ssl_key") or config2.get("ssl_key") }}
    - authorityKeyIdentifier: keyid:always
    - basicConstraints: critical, CA:false
    - subjectKeyIdentifier: hash
{%-   if mariadb.cert.san %}
    - subjectAltName:  {{ mariadb.cert.san | json }}
{%-   else %}
    - subjectAltName:
      - dns: {{ mariadb.cert.cn or ([grains.fqdn] + grains.fqdns) | reject("==", "localhost.localdomain") | first | d(grains.id) }}
      - ip: {{ (grains.get("ip4_interfaces", {}).get("eth0", [""]) | first) or (grains.get("ipv4") | reject("==", "127.0.0.1") | first) }}
{%-   endif %}
    - CN: {{ mariadb.cert.cn or grains.fqdns | reject("==", "localhost.localdomain") | first | d(grains.id) }}
    - mode: '0640'
    - user: {{ mariadb.lookup.user }}
    - group: {{ mariadb.lookup.group }}
    - makedirs: true
    - append_certs: {{ mariadb.cert.intermediate | json }}
    - days_remaining: {{ mariadb.cert.days_remaining }}
    - days_valid: {{ mariadb.cert.days_valid }}
    - require:
      - sls: {{ sls_config_file }}
{%-   if not salt["file.file_exists"](config.get("ssl_key") or config2.get("ssl_key")) %}
      - MariaDB server certificate private key is managed
{%-   endif %}

MariaDB CA cert is managed:
  file.managed:
    - name: {{ config.get("ssl_ca") or config2.get("ssl_ca") }}
    - contents: {{ ([mariadb.cert.root] + mariadb.cert.intermediate) | join("\n") | json }}
    - makedirs: true
    - require:
      - sls: {{ sls_config_file }}

{%- endif %}

{%- set config = mariadb.config.get("mariadb-client", {}) %}
{%- set config2 = mariadb.config.get("mysql", {}) %}
{%- if  (config.get("ssl_cert") or config2.get("ssl_cert")) and
        (config.get("ssl_key") or config2.get("ssl_key")) and
        (config.get("ssl_ca") or config2.get("ssl_ca")) %}

MariaDB client certificate private key is managed:
  x509.private_key_managed:
    - name: {{ config.get("ssl_key") or config2.get("ssl_key") }}
    - algo: rsa
    - keysize: 2048
    - new: true
{%-   if salt["file.file_exists"](config.get("ssl_key") or config2.get("ssl_key")) %}
    - prereq:
      - MariaDB client certificate is managed
{%-   endif %}
    - makedirs: true
    - user: {{ mariadb.lookup.user }}
    - group: {{ mariadb.lookup.group }}
    - require:
      - sls: {{ sls_config_file }}

MariaDB client certificate is managed:
  x509.certificate_managed:
    - name: {{ config.get("ssl_cert") or config2.get("ssl_cert") }}
    - ca_server: {{ mariadb.cert.ca_server or "null" }}
    - signing_policy: {{ mariadb.cert.signing_policy or "null" }}
    - signing_cert: {{ mariadb.cert.signing_cert or "null" }}
    - signing_private_key: {{ mariadb.cert.signing_private_key or
                              (config.get("ssl_cert") or config2.get("ssl_cert") if not mariadb.cert.ca_server and not mariadb.cert.signing_cert else "null") }}
    - private_key: {{ config.get("ssl_key") or config2.get("ssl_key") }}
    - authorityKeyIdentifier: keyid:always
    - basicConstraints: critical, CA:false
    - subjectKeyIdentifier: hash
{%-   if mariadb.cert.san %}
    - subjectAltName:  {{ mariadb.cert.san | json }}
{%-   else %}
    - subjectAltName:
      - dns: {{ mariadb.cert.cn or ([grains.fqdn] + grains.fqdns) | reject("==", "localhost.localdomain") | first | d(grains.id) }}
      - ip: {{ mariadb.cert.cn or grains.fqdns | reject("==", "localhost.localdomain") | first | d(grains.id) }}
{%-   endif %}
    - CN: {{ mariadb.cert.cn or grains.fqdns | reject("==", "localhost.localdomain") | first | d(grains.id) }}
    - mode: '0640'
    - user: {{ mariadb.lookup.user }}
    - group: {{ mariadb.lookup.group }}
    - makedirs: true
    - append_certs: {{ mariadb.cert.intermediate | json }}
    - days_remaining: {{ mariadb.cert.days_remaining }}
    - days_valid: {{ mariadb.cert.days_valid }}
    - require:
      - sls: {{ sls_config_file }}
{%-   if not salt["file.file_exists"](config.get("ssl_key") or config2.get("ssl_key")) %}
      - MariaDB client certificate private key is managed
{%-   endif %}

{%-   if not ca_cert or ca_cert[0] != (config.get("ssl_ca") or config2.get("ssl_ca")) %}
{%-     do ca_cert.append(config.get("ssl_ca") or config2.get("ssl_ca")) %}

MariaDB CA cert is managed:
  file.managed:
    - name: {{ config.get("ssl_ca") or config2.get("ssl_ca") }}
    - contents: {{ ([mariadb.cert.root] + mariadb.cert.intermediate) | join("\n") | json }}
    - makedirs: true
    - require:
      - sls: {{ sls_config_file }}
{%-   endif %}
{%- endif %}

{%- if not ca_cert %}

Ensure this file can be required:
  test.nop:
    - name: Nothing to do.
{%- endif %}
