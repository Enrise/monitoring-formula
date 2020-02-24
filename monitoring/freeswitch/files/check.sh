#!/bin/bash
CHECK_ITEM=${1}
CHECK_ACTION=${2}


#### Check Gateway state
if [[ "${CHECK_ACTION}" == "state" ]]; then
	GATEWAY_STATE=$(/usr/bin/fs_cli -x "sofia status gateway ${CHECK_ITEM}" | grep "^State" | awk {'print $2'})

	# Gateway is registered
	if [[ "${GATEWAY_STATE}" == "REGED" ]]; then
		echo 1 && exit 0
	fi

	# Gateway doesn't require registration
	if [[ "${GATEWAY_STATE}" == "NOREG" ]]; then
		echo 2 && exit 0
	fi

	# Gateway is NOT registered, abort
	echo 0 && exit 1
fi

#### Check Gateway Status
if [[ "${CHECK_ACTION}" == "status" ]]; then
	GATEWAY_STATUS=$(/usr/bin/fs_cli -x "sofia status gateway ${CHECK_ITEM}" | grep "^Status" | awk {'print $2'})

	# Gateway is registered
	if [[ "${GATEWAY_STATUS}" == "UP" ]]; then
		echo 1 && exit 0
	fi

	# Gateway is NOT registered, abort
	echo 0 && exit 1
fi

#### Check Gateway Uptime
if [[ "${CHECK_ACTION}" == "uptime" ]]; then
	GATEWAY_UPTIME=$(/usr/bin/fs_cli -x "sofia status gateway ${CHECK_ITEM}" | grep "^Uptime" | awk {'print $2'} | cut -d's' -f1 )
	echo ${GATEWAY_UPTIME} && exit 0
fi
