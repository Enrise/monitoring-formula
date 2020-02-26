# State to test some of the states in Travis-CI
monitoring:
  roles:
    - apcupsd
    - dnsmasq
    - gitlab
    - openvpn
    - postfix
    - mysql
    - salt-minion
    - vnstat
    #- docker # Since the travis image contains docker, this will be auto-detected

# Zabbix-agent config
zabbix-agent:
   include: /etc/zabbix/zabbix_agentd.d/*.conf
