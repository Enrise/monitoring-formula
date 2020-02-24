# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'solr' %}
{%- set has_check = True %}
{%- set has_autodiscovery = True %}
{%- set discovery_file = 'autodiscovery.py' %}
{%- set check_file = 'check.py' %}
{% include "monitoring/install_check.jinja" %}
