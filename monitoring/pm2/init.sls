# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'pm2' %}
{%- set has_autodiscovery = False %}
{%- set has_check = False %}
{% include "monitoring/install_check.jinja" %}

# Install dependency package:
{%- if salt['grains.get']('init', 'upstart') == 'systemd' %}
pm2_initscript:
  file.managed:
    - name: /etc/systemd/system/pm2-zabbix.service
    - source: salt://monitoring/{{service_name}}/files/init/systemd/pm2-zabbix.service
    - template: jinja
    - require:
      - pkg: zabbix-agent
      - npm: pm2-zabbix
{%- else %}
pm2_initscript:
  file.managed:
    - name: /etc/init.d/pm2-zabbix
    - source: salt://monitoring/{{service_name}}/files/init/sysv/pm2-zabbix
    - template: jinja
    - mode: 0755
    - require:
      - pkg: zabbix-agent
      - npm: pm2-zabbix

/etc/default/pm2-zabbix:
  file.managed:
    - source: salt://monitoring/{{service_name}}/files/init/sysv/pm2-zabbix.defaults
    - template: jinja
    - require:
      - pkg: zabbix-agent
      - npm: pm2-zabbix
      - file: pm2_initscript
{%- endif %}

pm2-zabbix:
  npm.installed:
    - user: root
    - require:
      - pkg: nodejs
  service.running:
    - enable: True
    - require:
      - file: pm2_initscript
      - npm: pm2-zabbix
