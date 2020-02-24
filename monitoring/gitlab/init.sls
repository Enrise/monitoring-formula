# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'gitlab' %}
{%- set has_autodiscovery = True %}
{%- set has_check = False %}
{% include "monitoring/install_check.jinja" %}

# Install dependency package:
jq:
  pkg.installed
