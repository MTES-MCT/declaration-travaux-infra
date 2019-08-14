#!/bin/bash

lftp -u $FTP_USER,$FTP_PASSWORD -e "mirror --reverse --delete --only-newer --verbose $SRC $DEST --log=$RESTORE_LOG_FILE" $FTP_SITE &