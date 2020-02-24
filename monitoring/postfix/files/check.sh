#!/bin/bash
MAILLOG=/var/log/mail.log
DAT1=/var/run/zabbix/postfix-offset.dat
PFLOGSUMM=/usr/sbin/pflogsumm

PFSTATUS="`sudo /usr/sbin/logtail -f$MAILLOG -o$DAT1 | $PFLOGSUMM -h 0 -u 0 --bounce-detail=0 --deferral-detail=0 --reject-detail=0 --no_no_msg_size --smtpd-warning-detail=0`"
PF_QUEUE=$(sudo /usr/bin/mailq | /bin/grep -v "Mail queue is empty" | /bin/grep -c '^[0-9A-Z]')

function getval {
  echo "${PFSTATUS}" | grep -m 1 "$1" | awk '{print $1}'
}

printf '{"queue":%d,"received":%d,"delivered":%d,"forwarded":%d,"deferred":%d,"bounced":%d,"rejected":%d,"held":%d,"discarded":%d,"rejected_warnings":%d,"bytes_received":%d,"bytes_delivered":%d,"senders":%d,"recipients":%d}\n' $PF_QUEUE $(getval received) $(getval delivered) $(getval forwarded) $(getval deferred)$(getval bounced) $(getval rejected) $(getval held) $(getval 'rejected warnings') $(getval 'bytes received') $(getval 'bytes delivered') $(getval 'senders')  $(getval 'recipients')
