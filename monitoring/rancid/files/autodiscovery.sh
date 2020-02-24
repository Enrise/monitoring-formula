#!/bin/bash
RANCID_FILES=$(ls /mnt/nfs/networkbackups/rancid/*.new)
UNIFI_FILE=$(ls -t /mnt/nfs/networkbackups/rancid/unifi/*.unf | head -1)
BACKUP_FILES="${RANCID_FILES} ${UNIFI_FILE}"
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

function discover_backup_files {
        json_head

        for f in ${BACKUP_FILES}
        do
                check_first_element
                printf "{"
                printf "\"{#FILE}\":\"${f%.*}\""
                printf "}"
        done

        json_end
}

discover_backup_files
