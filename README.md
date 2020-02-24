# monitoring-formula
This formula automatically installs required client-side scripts for Zabbix-Agent based on defined states and services in your statefiles.

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

## Todo
* [ ] Remove the `data` keys for all discoveries
* [ ] De-duplicate repeated code
