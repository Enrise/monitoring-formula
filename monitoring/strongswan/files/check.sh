#!/bin/bash
ACTION="${1}"
CONNECTION="${2}"

# save the ipsec stats in a variable for future parsing
IPSEC_STATS=$(ipsec status 2> /dev/null)

# error during retrieve
if [ $? -ne 0 -o -z "${IPSEC_STATS}" ]; then
  exit 1
fi

function get_uptime() {
	UPTIME_STR=$(echo "${IPSEC_STATS}" | grep "${CONNECTION}" | grep '\[' | cut -d ' ' -f9-10)
	PERIOD=$(echo ${UPTIME_STR} | cut -d ' ' -f1)
	UNITS=$(echo ${UPTIME_STR} | cut -d ' ' -f2)

	case ${UNITS} in
		minute*)          echo "${PERIOD}";;
		hour*)            echo "${PERIOD}*60" | bc;;
		day*)             echo "${PERIOD}*60*24" | bc;;
		week*)            echo "${PERIOD}*60*24*7" | bc;;
		month*)           echo "${PERIOD}*60*24*7*4" | bc;;
	esac
}

function get_status() {
	STATUS_STR=$(echo "${IPSEC_STATS}" | grep "${CONNECTION}" | grep '\[' | cut -d ' ' -f8)
	case ${STATUS_STR} in
  	ESTABLISHED*)        echo 1;;    
  	CONNECTING*)         echo 2;;
    CREATED*)            echo 3;;
  	PASSIVE*)            echo 4;;
  	REKEYING*)           echo 5;;
  	REKEYED*)            echo 6;;
  	DELETING*)           echo 7;;
  	DESTROYING*)         echo 8;;
		*)                   echo 0;;
	esac
}

if [ "$ACTION" = "conn_status" ]; then
  # Status for a specific connection
  printf '{"status":%d,"uptime":%d}\n' "$(get_status)" "$(get_uptime)"
elif [ "$ACTION" == "global_status" ]; then
  # Get global status
  PHASE2_COUNT=$(echo "${IPSEC_STATS}" | egrep -e "INSTALLED, |IPsec SA established" | wc -l)
  CONN_UP=$(echo "${IPSEC_STATS}" | grep "Security Associations" | cut -d '(' -f2 | cut -d ' ' -f1)
  CONN_CONNECTING=$(echo "${IPSEC_STATS}" | grep "Security Associations" | cut -d ',' -f2 | cut -d' ' -f2)
  printf '{"phase2_count":%d,"conn_up":%d,"conn_connecting":%d}\n' "$PHASE2_COUNT" "$CONN_UP" "$CONN_CONNECTING"
fi

exit 0
