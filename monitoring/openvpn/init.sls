# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'openvpn' %}
{%- set has_check = True %}
{%- set has_autodiscovery = True %}
{% include "monitoring/install_check.jinja" %}
