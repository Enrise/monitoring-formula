#!/bin/bash
path=/etc/openvpn/users.conf.d # path to userconfig directory

users=`ls -F $path | sed 's/\///g'` # array of users

echo "{"
echo "\"data\":["

comma=""
for user in $users
do
	echo "    $comma{\"{#VPNUSER}\":\"$user\"}"
	comma=","
done

echo "]"
echo "}"
