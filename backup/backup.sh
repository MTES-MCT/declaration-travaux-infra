#!/bin/bash

source backup.env

TIME=`date +%b-%d-%y%s`          # This Command will add date in Backup File Name.
FILENAME=backup-rieau-$TIME.tar.gz     # Here i define Backup file name format.
SRCDIR=$SRC                   # Location of Important Data Directory (Source of backup).
DESDIR=/backup                   # Destination of backup file.
SNF="$SRCDIR/mydata.snar"          # Snapshot file name and location

tar -cvf $DESDIR/$FILENAME -g $SNF $SRCDIR

ftp -inv $FTP_SITE <<EOF
    user $FTP_USER $FTP_PASSWORD
    lcd $SRC
    mput *.tar.gz
    bye
EOF