#!/bin/bash

lftp -u $FTP_USER,$FTP_PASSWORD -e "mirror --delete --only-newer --verbose $SRC $DEST --log=$BACKUP_LOG_FILE" $FTP_SITE &