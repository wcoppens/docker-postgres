#!/bin/bash

if [ "$AWS_ACCESS_KEY_ID" = "" ]
then
    echo "AWS_ACCESS_KEY_ID does not exist"
else
    if [ "$AWS_SECRET_ACCESS_KEY" = "" ]
    then
        echo "AWS_SECRET_ACCESS_KEY does not exist"
    else
        if [ "$WALE_S3_PREFIX" = "" ]
        then
            echo "WALE_S3_PREFIX does not exist"
        else
        
            if [ "$AWS_REGION" = "" ]
            then
                echo "AWS_REGION does not exist"
            else
            
                # Assumption: the group is trusted to read secret information
                umask u=rwx,g=rx,o=
                mkdir -p /etc/wal-e.d/env
    
                echo "$AWS_REGION" > /etc/wal-e.d/env/AWS_REGION
                echo "$AWS_SECRET_ACCESS_KEY" > /etc/wal-e.d/env/AWS_SECRET_ACCESS_KEY
                echo "$AWS_ACCESS_KEY_ID" > /etc/wal-e.d/env/AWS_ACCESS_KEY_ID
                echo "$WALE_S3_PREFIX" > /etc/wal-e.d/env/WALE_S3_PREFIX
                chown -R root:postgres /etc/wal-e.d
    
                if [ -e "/firstrun" ]; then
    
                    rm /firstrun
    
                    if [ "$INIT_PULL_BACKUP" = true ]; then
    
                        if ! kill -s TERM "$pid" || ! wait "$pid"; then
                            echo >&2 'PostgreSQL init process failed'
                            exit 1
                        fi
    
                        su - postgres -c "envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-fetch $PGDATA LATEST"
    
                        chown -R postgres:postgres $PGDATA
    
                        su - postgres -c "echo \"restore_command = 'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-fetch \"%f\" \"%p\"'\" > $PGDATA/recovery.conf"
    
                    fi
                fi
    
                if [ "$BACKUP_PUSH" = true ]; then
    
                    # wal-e specific
                    echo "wal_level = archive" >> $PGDATA/postgresql.conf
                    echo "archive_mode = on" >> $PGDATA/postgresql.conf
                    echo "archive_command = 'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-push %p'" >> $PGDATA/postgresql.conf
                    echo "archive_timeout = 60" >> $PGDATA/postgresql.conf
    
                    echo "$BASE_BACKUP_CRON postgres /usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-push $PGDATA" > /etc/cron.d/wal-e
                    echo "$DELETE_BACKUP_CRON postgres /usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e delete --confirm retain $DELETE_BACKUP_RETAIN" >> /etc/cron.d/wal-e
                fi
            fi
        fi
    fi
fi
