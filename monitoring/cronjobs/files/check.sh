#!/bin/bash
LOG_FILE="/var/log/cronjobs/${1}.log"

STATUS=$(grep "cronjob exited with code" ${LOG_FILE} | tail -n1)
CRON_EXITCODE=$(echo $STATUS | rev | cut -d' ' -f1 | rev)

if [ -z "$CRON_EXITCODE" ];
then
	CRON_EXITCODE=1
fi

echo ${CRON_EXITCODE}
exit 0
