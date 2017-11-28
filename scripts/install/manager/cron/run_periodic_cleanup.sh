#!/usr/bin/env bash

HOME_DIR=/home/lab
LOG_DIR=$HOME_DIR/log/periodic

EMAIL_NOTIFICATION=1
EMAIL_RECIPIENT="backup-notify@nclab.com"

API_KEY_MAILGUN="key-82bc17d7c1bf83756b2336c5730efaec"
API_KEY_MANDRILL="QktS-OXidPja-IC2vkxA5Q"
EMAIL_FROM="no-reply@nclab.com"
EMAIL_SUBJECT="Database Periodic Cleanup"

function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

function run_periodic_cleanup {
cd $HOME_DIR
./nclab db periodic
sleep 1
}

function send_mail_mailgun {
  curl -s --user "api:$API_KEY_MAILGUN" \
      https://api.mailgun.net/v3/mg.nclab.com/messages \
       -F from="NCLab Team <$EMAIL_FROM>" \
       -F to="$EMAIL_RECIPIENT" \
       -F subject="$EMAIL_SUBJECT" \
       -F text="$TEXT"
}

function send_mail_mandrill {
  BODY=\
"From: NCLab Team <$EMAIL_FROM>
To: $EMAIL_RECIPIENT
Subject: $EMAIL_SUBJECT

$TEXT
.
"
  printf "$BODY" | \
  curl -s --mail-from $EMAIL_FROM \
        --mail-rcpt $EMAIL_RECIPIENT \
        -u "nclab:$API_KEY_MANDRILL" \
        smtp://smtp.mandrillapp.com \
        -T -
}

mkdir -p $LOG_DIR
cd $LOG_DIR
ls -tr | perl -ne '{@files = <>; print @files[0..$#files-20 ]}' | xargs -n1 rm -rf

# Do the backup
LOG_NAME=$(date +%Y%m%d%H%M%S).log
LOG_PATH=$LOG_DIR/$LOG_NAME

t=$(echo $(date +%s.%N) | bc)
START_TIME=${t%.*}

run_log=$(run_periodic_cleanup)

t=$(echo $(date +%s.%N) | bc)
END_TIME=${t%.*}
DIFF_TIME=$(displaytime $(( $END_TIME - $START_TIME )))

TEXT="Database Periodic Cleanup

Machine: $HOSTNAME
Log file: $LOG_PATH
Time taken: $DIFF_TIME

Log
-------------------------------------

"

LOG_TEXT="$run_log"
TEXT="$TEXT$LOG_TEXT"

# Save log
echo $TEXT > $LOG_PATH

if [ $EMAIL_NOTIFICATION -eq 1 ]; then
    echo "Sending email..."

#    send_mail_mailgun
    send_mail_mandrill
fi

echo "Done"
