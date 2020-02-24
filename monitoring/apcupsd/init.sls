# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'apcupsd' %}
{%- set has_check = False %}
{%- set has_autodiscovery = False %}
{% include "monitoring/install_check.jinja" %}
