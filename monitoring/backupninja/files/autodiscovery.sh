#!/bin/bash
FILES=$(ls /etc/backup.d/)
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

function discover_backups {
	json_head

	for f in ${FILES}
	do
		check_first_element
		printf "{"
		printf "\"{#BACKUPTASK}\":\"${f}\""
		printf "}"
	done

	json_end
}

discover_backups
