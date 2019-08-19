#!/bin/bash

source $BACKUP_DIR/backup.env

TIME=`date +%b-%d-%y%s`          # This Command will add date in Backup File Name.
FILENAME=backup-rieau-$TIME.tar.gz     # Here i define Backup file name format.

tar -zcvf $DEST/$FILENAME $SRC

ftp -p -inv $FTP_SITE <<EOF
    user $FTP_USER $FTP_PASS
    lcd $DEST
    mput *.tar.gz
    bye
EOF

rm $DEST/$FILENAME