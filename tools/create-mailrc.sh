#!/bin/bash
for user in $(ls /home);
	do echo "set from=$user@nclab.com" > /home/$user/.mailrc;
done
