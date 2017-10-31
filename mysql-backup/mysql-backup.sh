#!/bin/bash
TARGET_TMP=/backup/mysql/temp

if [ -z "$1" -o -z "$2" ]; then
    echo "Usage: $0 <server name> <backup path>"
    echo "Example: $0 controller /backup/mysql"
    exit 1
fi

TARGET=$2/$1/`date +%Y-%m-%d`/`date +%Y-%m-%d-%H%M`

mkdir -p $2/$1 || exit 1
mkdir -p $TARGET || exit 1
mkdir -p $TARGET_TMP || exit 1

echo "SHOW DATABASES;" | mysql -h $1 -s | (
    while read DB; do
        echo -n $DB ... dump

        mysqldump \
            --single-transaction \
            -h $1 \
            -u root \
            -B $DB > $TARGET_TMP/$DB.sql

        echo -n ", xz"
        cat $TARGET_TMP/$DB.sql | ionice -c 3 nice -n 19 xz > $TARGET/$DB.sql.xz
        rm -f $TARGET_TMP/$DB.sql

        echo " ... done"
        sleep 1
    done
)
 
