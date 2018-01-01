#!/bin/bash
#you need packages: whois and heirloom-mailx

function send_mail {
    echo "User $USER wants to change his password" | mailx -v \
    -r "ansible01@nclab.com" \
    -s "Password change request" \
    -S smtp="smtp.mandrillapp.com:587" \
    -S smtp-use-starttls \
    -S smtp-auth=login \
    -S smtp-auth-user="NCLab" \
    -S smtp-auth-password="uLmDAw4jZEAJXhwv-RH0vQ" \
    -S ssl-verify=ignore \
     monitoring-alerts@nclab.com
}

#check old password
echo "Insert your OLD password:"
IFS= read -rs PASSWD
sudo -k

if sudo -lS &> /dev/null << EOF
$PASSWD
EOF
then
    echo 'Now insert your NEW password'
    IFS= read -rs NEWPASSWD
    echo 'Insert your NEW password again'
    IFS= read -rs NEWPASSWD_SECOND

    #both new passwords have to match
    if ( NEWPASSWD==NEWPASSWD_SECOND ); then
        #create hash from the plaintext password
        NEWPASSWD_ENCRYPTED="`mkpasswd -m sha-512 $NEWPASSWD`"
        #save the hash temporarily
        echo $NEWPASSWD_ENCRYPTED > "/tmp/$USER"
        #send email with the message for administrators
        send_mail
    else
        echo "Passwords do not match"
    fi
else 
    echo 'Wrong password.'
fi
