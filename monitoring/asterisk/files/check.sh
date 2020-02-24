#!/bin/bash
CHECK_ACTION=${1}
CHECK_ITEM=${2}

if [[ "${CHECK_ACTION}" == "trunk" ]]; then
	TRUNK_STATUS=$(/usr/sbin/asterisk -r -x 'sip show registry' | grep ${CHECK_ITEM} | awk {'print $5'})

	# Trunk is registered
	if [[ "${TRUNK_STATUS}" == "Registered" ]]; then
		echo 1 && exit 0
	fi

	# Trunk is NOT registered, abort
	echo 0 && exit 1
fi

if [[ "${CHECK_ACTION}" == "peer" ]]; then
	PEER_STATUS=$(/usr/sbin/asterisk -r -x 'sip show peers' | grep ${CHECK_ITEM} | awk {'print $5'})

	# Peer status is OK
	if [[ "${PEER_STATUS}" == "OK" ]]; then
		echo 1 && exit 0
	fi

	# Trunk is not OK, abort
	echo 0 && exit 1
fi
