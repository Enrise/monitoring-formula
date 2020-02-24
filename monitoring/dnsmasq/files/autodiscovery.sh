#!/bin/bash
IFS=$'\n'
ZABBIX_CONF=/etc/zabbix/zabbix_agentd.conf

#################
## Autodetection
#################
FIRST_ELEMENT=1
function json_head() {
  printf "["
}

function json_end() {
  printf "]"
}

function check_first_element() {
  if [[ $FIRST_ELEMENT -ne 1 ]]; then
    printf ","
  fi
  FIRST_ELEMENT=0
}

function server_detect() {
  json_head
  SERVER_NAMES=$(grep ^server= /etc/dnsmasq.conf | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -u)
  for servername in ${SERVER_NAMES}; do
    check_first_element
    printf "{"
    printf "\"{#SERVERNAME}\":\"$servername\""
    printf "}"
  done
  json_end
  exit 0
}

server_detect
