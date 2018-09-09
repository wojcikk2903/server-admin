#!/bin/bash
#
# Backup a Postgresql database into a daily file.
#

BACKUP_DIR=/var/backups/postgresql
DAYS_TO_KEEP=14
FILE_SUFFIX=_pg_backup

FILE=`date +"%Y%m%d%H%M"`${FILE_SUFFIX}

OUTPUT_FILE=${BACKUP_DIR}/${FILE}
OUTPUT_FILE_GLOBAL=${BACKUP_DIR}/${FILE}_global.sql


#do global backup with users&permissions
/usr/bin/pg_dumpall -g --dbname=postgresql://postgres:cOb1RJQx8lhQ@localhost:5432 > ${OUTPUT_FILE_GLOBAL}

# backup all other databases in a loop
/usr/bin/psql -at --dbname=postgresql://postgres:cOb1RJQx8lhQ@localhost:5432/postgres -c "SELECT datname FROM pg_database \
                          WHERE NOT datistemplate"| \
while read f; 
   do /usr/bin/pg_dump --dbname=postgresql://postgres:cOb1RJQx8lhQ@localhost:5432/$f --format=c --file=${OUTPUT_FILE}_$f.sql ;
done;

# prune old backups
/usr/bin/find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -exec rm -rf '{}' ';'
