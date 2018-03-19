#!/bin/bash

# synchronizace souboru z jednoho serveru

usage()
{
    echo "Usage: sync-server.sh <server-name>"
    exit 1
}

[ -n "$1" ] || usage

MY_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. $MY_DIR/global.conf

CONFIG_DIR=$CONFIG_PATH/$1
SERVER_DIR=$SERVERS_PATH/$1

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Server configuration directory does not exist: $CONFIG_DIR"
    exit 1
fi

if [ ! -f "$CONFIG_DIR/backup.conf" ]; then
    echo "Server backup configuration not found: $CONFIG_DIR/backup.conf"
    exit 1
fi

. $CONFIG_DIR/backup.conf

if [ -z "$SERVER_IP" -a -z "$REMOTE_BACKUP_IP" ]; then
    echo "SERVER_IP nor REMOTE_BACKUP_IP not set"
    exit 1
fi

DST=$SERVER_DIR/current
BCKNAME=`date '+%Y-%m-%d-%H-%M'`
LOGDIR=$SERVER_DIR/log-sync/`date '+%Y-%m'`
LOGFILE=$LOGDIR/$BCKNAME.log
LOGLINK=$SERVER_DIR/last-log-sync.log

mkdir -p $DST
mkdir -p $LOGDIR

RSYNC_OPTS="-a --numeric-ids --hard-links --compress --inplace --delete --stats -e ssh"

if [ "$RSYNC_COMPRESS" = "no" ]; then
    RSYNC_OPTS="-a --numeric-ids --hard-links --inplace --delete --stats -e ssh"
fi

if [ -n "$SERVER_IP" ]; then

    if [ ! -f "$CONFIG_DIR/sync.include" ]; then
        echo "Server sync include file not found: $CONFIG_DIR/sync.include"
        exit 1
    fi

    SRC=root@$SERVER_IP/backup
    rsync $RSYNC_OPTS --include-from=$CONFIG_DIR/sync.include --exclude '*' $SRC $DST &> $LOGFILE
else
    SRC=root@$REMOTE_BACKUP_IP/backup_remote/$1/current/
    rsync $RSYNC_OPTS $SRC $DST &> $LOGFILE
fi

RETVAL=$?

# symlink na posledni log
rm -f $LOGLINK
ln -s $LOGFILE $LOGLINK

# zaslani chyby (vypis na vystup, cron to posle e-mailem)
# nevadi nam chyba 24 (nektere zdrojove soubory behem rsync zmizely - obvykle docasne soubory)
if [ $RETVAL != 0 -a $RETVAL != 24 ]; then
    cat $LOGFILE
else
    exit 0
fi


exit $RETVAL
