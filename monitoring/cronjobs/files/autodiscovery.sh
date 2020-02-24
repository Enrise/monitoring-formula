#!/bin/bash
FILES=$(ls /var/log/cronjobs/)
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

function discover_cronjobs {
	json_head

	for f in ${FILES}
	do
		check_first_element
		printf "{"
		printf "\"{#CRONJOB}\":\"${f%.*}\""
		printf "}"
	done

	json_end
}

discover_cronjobs
