#!/bin/bash

date;
echo "Running scheduled mongodb backup";
mkdir -p /backups;
today="$(date +%Y-%m-%d)"

mongodump \
    --authenticationDatabase "$MONGODB_USER" \
    --db=belgium_users \
    --archive="/backups/backup_users_$today" \
    --gzip \
    --uri="mongodb://$MONGODB_URI" \
    -u "$MONGODB_USER" \
    -p "$MONGODB_PASSWORD" 2>&1;
if [ "$?" = "0" ]; then echo "DONE";else 1>&2 echo "FAILED";exit 1;fi

mongodump \
    --authenticationDatabase "$MONGODB_USER" \
    --db=belgium_studyDB \
    --archive="/backups/backup_studyDB_$today" \
    --gzip \
    --uri="mongodb://$MONGODB_URI" \
    -u "$MONGODB_USER" \
    -p "$MONGODB_PASSWORD" 2>&1;
if [ "$?" = "0" ]; then echo "DONE";else 1>&2 echo "FAILED";exit 1;fi

rclone --config /config/rclone.conf copy "/backups/backup_users_$today" google_participants:infectieradar.be-backups
rclone --config /config/rclone.conf copy "/backups/backup_studyDB_$today" n:infectieradar.be-backups
