# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'w3svc' %}
{%- set has_autodiscovery = False %}
{%- set has_check = False %}
{% include "monitoring/install_check.jinja" %}

# Install checks
zabbix_{{ service_name }}_get_apppool:
  file.managed:
    - name: "C:\\Program Files\\Zabbix Agent\\Scripts\\iis_get_apppool.ps1"
    - source: salt://monitoring/{{ service_name }}/files/get_apppool.ps1
    - require:
      - file: zabbix_scripts_directory

zabbix_{{ service_name }}_get_apppoolstate:
  file.managed:
    - name: "C:\\Program Files\\Zabbix Agent\\Scripts\\iis_get_apppoolstate.ps1"
    - source: salt://monitoring/{{ service_name }}/files/get_apppoolstate.ps1
    - require:
      - file: zabbix_scripts_directory

zabbix_{{ service_name }}_get_sites:
  file.managed:
    - name: "C:\\Program Files\\Zabbix Agent\\Scripts\\iis_get_sites.ps1"
    - source: salt://monitoring/{{ service_name }}/files/get_sites.ps1
    - require:
      - file: zabbix_scripts_directory

zabbix_{{ service_name }}_get_sitestate:
  file.managed:
    - name: "C:\\Program Files\\Zabbix Agent\\Scripts\\iis_get_sitestate.ps1"
    - source: salt://monitoring/{{ service_name }}/files/get_sitestate.ps1
    - require:
      - file: zabbix_scripts_directory
