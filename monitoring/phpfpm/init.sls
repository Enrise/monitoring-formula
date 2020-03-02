# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'phpfpm' %}
{%- set has_autodiscovery = True %}
{%- set has_check = True %}
{% include "monitoring/install_check.jinja" %}

# Install dependency package:
libfcgi0ldbl:
  pkg.installed
