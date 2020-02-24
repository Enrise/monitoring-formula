# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'freeswitch' %}
{%- set has_autodiscovery = True %}
{%- set has_check = True %}
{% include "monitoring/install_check.jinja" %}
