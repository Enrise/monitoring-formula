#!/bin/bash
FIRST_ELEMENT=1
REGISTRIES=$(/usr/sbin/asterisk -r -x 'sip show registry' | grep -v 'http' | grep ':' | awk {'print $3'})

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

function discover_trunks {
    json_head

    for t in ${REGISTRIES}
    do
      check_first_element
      printf "{"
      printf "\"{#TRUNK}\":\"${t}\""
      printf "}"
    done

    json_end
}

discover_trunks
