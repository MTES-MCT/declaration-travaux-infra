#!/bin/bash

cd rieau-infra/backup

source backup.env

ftp -p -inv $FTP_SITE <<EOF
    user $FTP_USER $FTP_PASS
    lcd $DEST
    mget *.tar.gz
    bye
EOF

# FILENAME="backup-rieau-août-19-191566204128.tar.gz"
if [ ! -z "$FILENAME" ]; then
    tar -zxvf "$DEST/$FILENAME"
fi