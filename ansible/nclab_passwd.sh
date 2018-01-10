#!/bin/bash
#you need packages: whois and heirloom-mailx

function send_mail {
    echo "User $USER changed his password using the nclab_passwd command." | mailx -v \
    -r "pass@nclab.com" \
    -s "User $USER changed his password using the nclab_passwd command." \
    -S smtp="smtp.mandrillapp.com:587" \
    -S smtp-use-starttls \
    -S smtp-auth=login \
    -S smtp-auth-user="NCLab" \
    -S smtp-auth-password="uLmDAw4jZEAJXhwv-RH0vQ" \
    -S ssl-verify=ignore \
     monitoring-alerts@nclab.com
}

#clean sudo cache
sudo -k

if sudo -v -p 'Enter your OLD password: '
then
    echo -n 'Now enter your NEW password: '
    IFS= read -rs NEWPASSWD
    echo
    echo -n 'Enter your NEW password again: '
    IFS= read -rs NEWPASSWD_SECOND
    echo

    #both new passwords have to match
    if [ "$NEWPASSWD" = "$NEWPASSWD_SECOND" ]; then
        #create hash from the plaintext password
        NEWPASSWD_ENCRYPTED="`mkpasswd -m sha-512 $NEWPASSWD`"
	
	#set new password on all servers        
	for i in `grep '^[a-z]' /etc/ansible/hosts|sort -u`;
		do echo "## Changing your password on $i"; ssh -p 2022 -o StrictHostKeyChecking=no $i 'sudo usermod -p '\'"$NEWPASSWD_ENCRYPTED"\'' $USER';
	done

        #send email with the message for administrators
        send_mail
    else
        echo "New passwords do not match."
    fi
else 
    echo 'Wrong password.'
fi

