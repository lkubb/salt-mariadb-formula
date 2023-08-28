# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as mariadb with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

{%- if "config_dir" not in mariadb.lookup %}

MariaDB config is managed:
  file.managed:
    - name: {{ mariadb.lookup.config }}
    - source: {{ files_switch(
                    ["my.cnf", "my.cnf.j2"],
                    config=mariadb,
                    lookup="MariaDB config is managed",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ mariadb.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        mariadb: {{ mariadb | json }}
{%- else %}

{%-   for scope in mariadb.lookup.group_file_mapping %}

MariaDB {{ scope }} config is managed:
  file.managed:
    - name: {{ mariadb.lookup.config_dir | path_join(mariadb.lookup.config_files[scope]) }}
    - source: {{ files_switch(
                    [scope ~ ".cnf", "scope.cnf.j2"],
                    config=mariadb,
                    lookup="MariaDB " ~ scope ~ " config is managed",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ mariadb.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        mariadb: {{ mariadb | json }}
        render_groups: {{ mariadb.lookup.group_file_mapping[scope] }}
{%-   endfor %}
{%- endif %}
