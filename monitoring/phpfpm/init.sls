# Cleanup old params (20-01-2020)
/etc/zabbix/zabbix_agentd.d/params_php5-fpm.conf:
  file.absent:
    - require_in:
      - file: /etc/zabbix/zabbix_agentd.d/params_phpfpm.conf
/opt/zabbix/scripts/php5-fpm-autodiscovery.sh:
  file.absent:
    - require_in:
      - file: /opt/zabbix/scripts/phpfpm-autodiscovery.sh
/opt/zabbix/scripts/php5-fpm-check.sh:
  file.absent:
    - require_in:
      - file: /opt/zabbix/scripts/phpfpm-check.sh

# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'phpfpm' %}
{%- set has_autodiscovery = True %}
{%- set has_check = True %}
{% include "monitoring/install_check.jinja" %}

# Install dependency package:
libfcgi0ldbl:
  pkg.installed
