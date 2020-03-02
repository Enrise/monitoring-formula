# monitoring-formula
[![Travis branch](https://img.shields.io/travis/Enrise/monitoring-formula/master.svg?style=flat-square)](https://travis-ci.org/Enrise/monitoring-formula)

This formula automatically installs required client-side scripts and configurations for [Zabbix-Agent](https://www.zabbix.com/zabbix_agent) based on defined states and services in your statefiles.

## Contributing

Pull requests for added monitoring scripts and bug fixes are more than welcome.

## Usage

Include `monitoring` in your project. It will auto-detect states and services and include the appropriate zabbix-agent scripts.
It's highly recommended to use this in conjunction with the [Zabbix-Formula](https://github.com/saltstack-formulas/zabbix-formula).

## Configuration
### Agent
There is no configuration required for the agent-side, it will automatically take care of this.
Some modules may require additional configuration, please refer to the `README.md` in the subfolders.

In case the auto-detection does not pick up particular services you can specify them in a pillar:
```yaml
monitoring:
  roles:
    - redis
    - docker
```

### Server
Each monitoring component has its own template you need to import into your Zabbix environment for these checks to work.


## Creating checks
In the `monitoring` folder a new folder with the service name should be created.
It's structure should be:
```
files/autodiscovery.sh  # Autodiscovery script (optional). Can have any name, but must be explicitly configured as such.
files/check.sh          # Checks script. Can have any name, but must be explicitly configured as such.
files/params.conf       # Params file to install into Zabbix Agent configuration
init.sls                # Monitoring Module configuration
template.xml            # Zabbix Template
```

The `init.sls` file contains configuration of the monitoring-module:

```jinja
{%- set service_name = 'SERVICENAME' %}
{%- set has_autodiscovery = True %}
{%- set has_check = True %}
{% include "monitoring/install_check.jinja" %}
```

The following variables are available for the `init.sls` and are used by `install_check.jinja`:

* `service_name`: Service to check (e.g. phpfpm)
* `has_autodiscovery`: Boolean whether there is autodiscovery for this module. Defaults to `False`
* `autodiscovery_file`: Filename to use as autodiscovery template. Defaults to `autodiscovery.sh` but can also be changed to Python, go etc.
* `has_check`: Boolean whether there is autodiscovery for this module. Defaults to `False`
* `check_file`: Filename to use as check template. Defaults to `check.sh` but can also be changed to Python, go etc.
* `params_file`: Filename to use as parameters-file template. Defaults to `params.conf`

This file can also be used to install specific dependencies for the monitoring submodule (e.g. python-docker for monitoring Docker) using the default Saltstack syntax.

## Todo
* [ ] Remove the `data` keys for all discoveries
* [ ] De-duplicate repeated code (e.g. in generating JSON structures)
