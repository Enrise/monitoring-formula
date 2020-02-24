#!/bin/bash
CHECK_FILE=${1}

LOG_FILE="/var/log/backupninja.log"

# Check if it is the first of the month so we'll also check the logfile
# for yesterday since rotation occurs close to backupninja execution
if [ $(date '+%d') == 01 ]; then
	LOG_FILE="${LOG_FILE}.1.gz ${LOG_FILE}"
fi

STATUS=$(zgrep "<<<< finished action /etc/backup.d/${CHECK_FILE}" ${LOG_FILE} | tail -n1)
STATUS_TEXT=$(echo $STATUS | awk {'print $9'})

BACKUP_VALUE=0
if [ "${STATUS_TEXT}" == "SUCCESS" ]; then
	BACKUP_VALUE=1
fi

echo ${BACKUP_VALUE}
exit 0
