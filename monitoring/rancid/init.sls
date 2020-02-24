# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'rancid' %}
{%- set has_autodiscovery = True %}
{%- set has_check = False %}
{% include "monitoring/install_check.jinja" %}
