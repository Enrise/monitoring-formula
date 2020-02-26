# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'nginx' %}
{%- set has_check = True %}
{% include "monitoring/install_check.jinja" %}

# Additional actions required for this plugin
/etc/nginx/conf.d/monitoring.conf:
  file.managed:
    - template: jinja
    - source: 'salt://monitoring/nginx/files/vhost.conf'
    - require:
      - pkg: nginx
    - watch_in:
      - service: nginx
