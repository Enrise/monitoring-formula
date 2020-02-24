# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'varnish' %}
{%- set has_check = True %}
{%- set check_file = 'check.py' %}
{% include "monitoring/install_check.jinja" %}
