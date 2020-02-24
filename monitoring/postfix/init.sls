# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'postfix' %}
{%- set has_check = True %}
{% include "monitoring/install_check.jinja" %}

{{ service_name }}_monitoring_dependencies:
  pkg.installed:
    - pkgs:
      - logtail
      - pflogsumm
