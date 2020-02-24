#!/bin/bash

# Memcached status
echo -e "stats\nquit" | nc 127.0.0.1 $1 | grep "STAT $2 " | awk '{print $3}'
