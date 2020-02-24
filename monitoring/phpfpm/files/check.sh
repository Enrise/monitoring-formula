#!/bin/bash
# Grab PHP-FPM Pool data and send it to Zabbix

# Parameters:
# $1 - Metric to retrieve
# $2 - Listener to connect to
# $3 - Status path to query

METRIC="$1"
LISTENING="$2"
STATUSPATH="$3"

export SCRIPT_NAME=$STATUSPATH
export SCRIPT_FILENAME=$STATUSPATH
export QUERY_STRING=full
export REQUEST_METHOD=GET

## output metrics
case $METRIC in
        ping)
                STATUS=$(cgi-fcgi -bind -connect $LISTENING | grep "^pong")
                if [[ $STATUS == "pong" ]];
                then
                  echo 1
                  exit 0
                fi
                echo 0
                exit 1
                ;;
        pool)
                cgi-fcgi -bind -connect $LISTENING | grep "^pool:"| cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        process_manager)
                cgi-fcgi -bind -connect $LISTENING | grep "^process manager:"| cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        start_time)
                cgi-fcgi -bind -connect $LISTENING | grep "^start time:"| sed 's|^start time:\s\+||'
                ;;
        start_since)
                cgi-fcgi -bind -connect $LISTENING | grep "^start since:" | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        accepted_conn)
                cgi-fcgi -bind -connect $LISTENING | grep "^accepted conn:" | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        listen_queue)
                cgi-fcgi -bind -connect $LISTENING | grep "^listen queue:" | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        max_listen_queue)
                cgi-fcgi -bind -connect $LISTENING | grep "^max listen queue:" | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        listen_queue_len)
                cgi-fcgi -bind -connect $LISTENING | grep "^listen queue len:" | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        idle_processes)
                cgi-fcgi -bind -connect $LISTENING | grep "^idle processes:" | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        active_processes)
                cgi-fcgi -bind -connect $LISTENING | grep "^active processes:" | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        total_processes)
                cgi-fcgi -bind -connect $LISTENING | grep "^total processes:" | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        max_active_processes)
                cgi-fcgi -bind -connect $LISTENING | grep "^max active processes:"  | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        max_children_reached)
                cgi-fcgi -bind -connect $LISTENING | grep "^max children reached:"  | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        slow_requests)
                cgi-fcgi -bind -connect $LISTENING | grep "^slow requests:"  | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        state)
                cgi-fcgi -bind -connect $LISTENING | grep "^state:"  | cut -d ":" -f 2 | sed 's|^\s\+||'
                ;;
        *)
                echo "Unsupported metric $METRIC"
                exit 1
        ;;
esac

exit 0
