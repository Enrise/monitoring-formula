#!/bin/bash
FIRST_ELEMENT=1

CHECK_URL="https://localhost/-/liveness"

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

function discover_gitlab {
	json_head

	KEYS=$(curl --silent --insecure ${CHECK_URL} | jq keys |  sed 's/[][]//g' | sed 's/"//g' | sed 's/,//g' | sed '/^\s*$/d')

	for k in ${KEYS}
	do
		check_first_element
		printf "{"
		printf "\"{#CHECK}\":\"${k}\""
		printf "}"
	done

	json_end
}

discover_gitlab
