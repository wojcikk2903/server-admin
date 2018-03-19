#!/bin/bash

# synchronizace a snapshot souboru vsech serveru
# toto je hlavni skript urceny k volani cronem

MY_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. $MY_DIR/global.conf

# vystup a chybovy vystup presmerovan do hlavniho logu

MAIN_LOG_BASENAME=`date '+%Y-%m-%d-%H-%M'`
MAIN_LOG=$MAIN_LOGS_PATH/$MAIN_LOG_BASENAME

exec >$MAIN_LOG
exec 2>&1

cd $CONFIG_PATH

for SUBDIR in *; do
    if [ -d "$SUBDIR" ]; then
        $SCRIPTS_PATH/sync-server.sh $SUBDIR
        RETVAL=$?

        # snapshot pouze pokud synchronizace dopadla dobre
        #if [ $RETVAL = 0 ]; then
         #   $SCRIPTS_PATH/snapshot-server.sh $SUBDIR
        #fi

    fi
done

#/backup/scripts/clean.sh
