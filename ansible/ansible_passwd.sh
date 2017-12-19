#!/bin/bash
#Script to change user's password

if [ "$1" == "" ]; then
    echo "You have to write your username"
    exit 1
fi

USERNAME=$1
OLD_PASSWD=$(cat /etc/shadow | grep $USERNAME | awk -F: '{print $2}')
echo $OLD_PASSWD
