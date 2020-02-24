#!/bin/bash
FIRST_ELEMENT=1
GATEWAYS=$(/usr/bin/fs_cli -x 'sofia status gateway' | grep "sip:")
IFS=$'\n'

function json_head {
    printf "{"
    printf "\"data\":["
}

function json_end {
    printf "]"
    printf "}"
}

function check_first_element {
    if [[ $FIRST_ELEMENT -ne 1 ]]; then
        printf ","
    fi
    FIRST_ELEMENT=0
}

function discover_gateways {
    json_head

    for gw in ${GATEWAYS}
    do
      GWNAME=$(echo ${gw} | awk {'print $1'} | cut -d ':' -f3)
      GWHOST=$(echo ${gw} | awk {'print $2'} | cut -d ':' -f2)

      check_first_element
      printf "{"
      printf "\"{#UID}\":\"${GWNAME}\","
      printf "\"{#FRIENDLYNAME}\":\"${GWHOST}\""
      printf "}"
    done

    json_end
}

discover_gateways
