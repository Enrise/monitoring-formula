#!/bin/bash
PROGNAME=`basename $0`
VERSION="Version 1.2"

port=1150
statusfile=/run/openvpn/users.status

get_value()
{
	# try to connect
	if ! exec 3<> /dev/tcp/localhost/$port; then
  		echo "`basename $0`: unable to connect to localhost:$port"
  		echo "Make sure that you started openvpn with management option"
  		exit 1
	fi

	read<&3
	echo load-stats>&3
	sleep 1
	read<&3
	#Set positional parameters and get rid of \r and $'
	set -f
	set -- ${REPLY//$'\r'/}
	nclients=`echo $2|cut -d, -f1|cut -d= -f2`
	bytesin=`echo $2|cut -d, -f2|cut -d= -f2`
	bytesout=`echo $2|cut -d, -f3|cut -d= -f2`
	set +f
	exec 3<&-
}

case $1 in
'server_stats')
		get_value
		printf '{"clients":%d,"rx":%d,"tx":%d}\n' "$nclients" "$bytesin" "$bytesout"
		;;
'client_stats')
		val=$(sudo grep ^$2 $statusfile)
		printf '{"rx":%d,"tx":%d,"client_ip":"%s"}\n' "$(echo $val|cut -d, -f4)" "$(echo $val|cut -d, -f3)" "$(echo $val|cut -d, -f2 | cut -d':' -f1)"
		;;
'version')
	  echo "$PROGNAME $VERSION"
	  exit 1
		;;
*)
    echo "usage:"
		echo "    $0 client_stats USER        -- Client stats (traffic, IP)"
		echo "    $0 server_stats             -- Server stats (clients, traffic)"
    exit 1;;
esac
