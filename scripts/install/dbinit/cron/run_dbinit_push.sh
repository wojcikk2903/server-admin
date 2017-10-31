#!/usr/bin/env bash

HOME_DIR=/home/lab
LOG_DIR=$HOME_DIR/log
DATA_DIR=/data/backup/dbinit
#HOST=127.0.0.1
#PORT=27017

EMAIL_NOTIFICATION=1
EMAIL_RECIPIENT="backup-notify@nclab.com"

API_KEY="key-82bc17d7c1bf83756b2336c5730efaec"
EMAIL_FROM="no-reply@nclab.com"
EMAIL_SUBJECT="DBInit Push Master"

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

mkdir -p $LOG_DIR $DATA_DIR

# First find old backup and delete it. The number in "$#files-4" defines how many are kept
cd $DATA_DIR
ls -tr | perl -ne '{@files = <>; print @files[0..$#files-7 ]}' | xargs -n1 rm -rf

cd $LOG_DIR
ls -tr | perl -ne '{@files = <>; print @files[0..$#files-20 ]}' | xargs -n1 rm -rf

# Do the backup
BACKUP_NAME=$(date +%Y%m%d%H%M%S)
LOG_NAME=$BACKUP_NAME.log

BACKUP_PATH=$DATA_DIR/$BACKUP_NAME
LOG_PATH=$LOG_DIR/$LOG_NAME

t=$(echo $(date +%s.%N) | bc)
START_TIME=${t%.*}

cd ~
./nclab dbinit push master | tee $LOG_PATH

t=$(echo $(date +%s.%N) | bc)
END_TIME=${t%.*}
DIFF_TIME=$(displaytime $(( $END_TIME - $START_TIME )))

if [ $EMAIL_NOTIFICATION -eq 1 ]; then
    echo "Sending email..."

    TEXT="DBInit Push Master

Machine: $HOSTNAME
Log file: $LOG_PATH
Time taken: $DIFF_TIME

Log
-------------------------------------

"

    LOG_TEXT="$(cat $LOG_PATH)"

    TEXT="$TEXT$LOG_TEXT"

    curl -s --user "api:$API_KEY" \
        https://api.mailgun.net/v3/mg.nclab.com/messages \
         -F from="NCLab Team <$EMAIL_FROM>" \
         -F to="$EMAIL_RECIPIENT" \
         -F subject="$EMAIL_SUBJECT" \
         -F text="$TEXT"
fi

echo "Done"
