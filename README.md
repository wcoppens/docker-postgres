## Postgres docker container with wal-e

Mostly based on [https://github.com/lukesmith/docker-postgres-wale](https://github.com/lukesmith/docker-postgres-wale)

Uses original official Postgres base image

## What does this do?

This container has the following additional options over the original Postgres container.

### Pre-install Wal-e
Wal-e is preinstalled and can be configured in several ways.

**Initial backup-pull**
By supplying `INIT_PULL_BACKUP` env variable with value `true` the container will instruct to WAL-e to initially pull a basebackup from the respective WAL-e bucket destination.

**Backup-push after start**
By supplying `BACKUP_PUSH` env variable with value `true` the container will instruct Postgres to continously push backups using WAL-e to the respective bucket destination.

### Wal-e S3 configuration

For now only S3 backups are supported in this container, please feel free to extend backup destination support.

Environment variables to pass to the container for WAL-E, all of these must be present or WAL-E is not configured.

`AWS_ACCESS_KEY_ID`

`AWS_SECRET_ACCESS_KEY`

`WALE_S3_PREFIX=\"s3://<bucketname>/<path>\"`