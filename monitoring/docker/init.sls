# Definitions for installing and loading the specific additional requirements
{%- set service_name = 'docker' %}
{%- set has_autodiscovery = True %}
{%- set has_check = True %}
{%- set discovery_file = 'autodiscovery.py' %}
{%- set check_file = 'check.py' %}
{%- set python_major_version = salt['grains.get']('pythonversion', ['3','6'])[0] %}
{%- set pypip_pkg = 'python-pip' %}
{%- if python_major_version == 3 %}
{%- set pypip_pkg = 'python3-pip' %}
{%- endif %}
{% include "monitoring/install_check.jinja" %}

# We're using the docker-py package
docker_monitoring_deps:
  pkg.installed:
    - name: {{ pypip_pkg }}
  pip.installed:
    - name: docker-py
    - reload_modules: true
    - bin_env: /usr/bin/pip{{ python_major_version }}
    - require:
      - pkg: docker_monitoring_deps
    - require_in:
      - file: /opt/zabbix/scripts/docker-autodiscovery.py
      - file: /opt/zabbix/scripts/docker-check.py

# We need access to the Docker socket, therefor need to have zabbix-agent to be a member of the docker group
extend:
  zabbix-formula_zabbix_user:
    user.present:
      - groups:
        - zabbix
        - docker
