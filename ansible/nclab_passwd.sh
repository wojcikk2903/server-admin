#!/bin/bash
#you need packages: whois and heirloom-mailx

function send_mail {
    echo "Password change requested by user $USER. The new password can be found on pass.nclab.com in /tmp/new-password-$USER" | mailx -v \
    -r "ansible01@nclab.com" \
    -s "Password change requested by $USER" \
    -S smtp="smtp.mandrillapp.com:587" \
    -S smtp-use-starttls \
    -S smtp-auth=login \
    -S smtp-auth-user="NCLab" \
    -S smtp-auth-password="uLmDAw4jZEAJXhwv-RH0vQ" \
    -S ssl-verify=ignore \
     monitoring-alerts@nclab.com
}

#check old password
echo -n "Enter your OLD password:   "

#clean sudo cache
sudo -k

if sudo -v &> /dev/null
then
    echo 'Now enter your NEW password:'
    IFS= read -rs NEWPASSWD
    echo 'Enter your NEW password again:'
    IFS= read -rs NEWPASSWD_SECOND

    #both new passwords have to match
    if [ "$NEWPASSWD" = "$NEWPASSWD_SECOND" ]; then
        #create hash from the plaintext password
        NEWPASSWD_ENCRYPTED="`mkpasswd -m sha-512 $NEWPASSWD`"
        #save the hash temporarily
        echo $NEWPASSWD_ENCRYPTED > "/tmp/new-password-$USER"
	#set permissions
	chmod 600 /tmp/new-password-$USER
        #send email with the message for administrators
        send_mail
	echo "Your request was sent to the administrators."
    else
        echo "New passwords do not match."
    fi
else 
    echo 'Wrong password.'
fi
