#!/bin/bash

source backup.env

FILENAME=backup-rieau-$TIME.tar.gz
DESDIR=/backup  

ftp -inv $FTP_SITE <<EOF
    user $FTP_USER $FTP_PASSWORD
    lcd $DESDIR
    mget $FILENAME
    bye
EOF

tar -tvf "$DESDIR/$FILENAME"