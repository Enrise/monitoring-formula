#!/bin/bash
FIRST_ELEMENT=1

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

function discover_ipsec {
	json_head

	for f in $(grep '^conn ' /etc/ipsec.conf  | awk {'print $2'})
	do
		check_first_element
		printf "{"
		printf "\"{#CONNECTION}\":\"${f%.*}\""
		printf "}"
	done

	json_end
}

discover_ipsec
