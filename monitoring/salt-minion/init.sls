# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'salt-minion' %}
{%- set has_check = False %}
{% include "monitoring/install_check.jinja" %}
