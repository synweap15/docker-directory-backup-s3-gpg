# Backup MySQL Data to S3/Minio

This docker image backup and encrypt directories to S3/Minio periodically.

## Usage

### Backup to S3

    docker run -d --restart unless-stopped \
           --name mysql_backup \
           -e AWS_ACCESS_KEY_ID="your-access-key" \
           -e AWS_SECRET_ACCESS_KEY="your-secret-access-keys" \
           -e PGP_KEY=YOUR_PGP_PUBLIC_KEY \
           -e BACKUP_SCHEDULE="0 * * * *" \
           -e BACKUP_DIRECTORY="/backup" \
           -v /project/directory/to/backup:/backup \
           --network your-network \
           synweap15/docker-directory-backup-s3-gpg

### Backup to your own Mino server

    docker run -d --restart unless-stopped \
           --name mysql_backup \
           -e AWS_ENDPOINT="https://your.minio.server.example.com" \
           -e AWS_ACCESS_KEY_ID="your-access-key" \
           -e AWS_SECRET_ACCESS_KEY="your-secret-access-keys" \
           -e PGP_KEY=YOUR_PGP_PUBLIC_KEY \
           -e BACKUP_SCHEDULE="0 * * * *" \
           -e BACKUP_DIRECTORY="/backup" \
           -v /project/directory/to/backup:/backup \
           --network your-network \
           synweap15/docker-directory-backup-s3-gpg

### Use a local PGP public key file

    docker run -d --restart unless-stopped \
           --name mysql_backup \
           -e AWS_ENDPOINT="https://your.minio.server.example.com" \
           -e AWS_ACCESS_KEY_ID="your-access-key" \
           -e AWS_SECRET_ACCESS_KEY="your-secret-access-keys" \
           -v /path/to/your/pgp-public-key.txt:/pgp.txt \
           -e PGP_KEY=/pgp.txt \
           -e BACKUP_SCHEDULE="0 * * * *" \
           -e BACKUP_DIRECTORY="/backup" \
           -v /project/directory/to/backup:/backup \
           --network your-network \
           synweap15/docker-directory-backup-s3-gpg

### Use a remote PGP public key URL

    docker run -d --restart unless-stopped \
           --name mysql_backup \
           -e AWS_ACCESS_KEY_ID="your-access-key" \
           -e AWS_SECRET_ACCESS_KEY="your-secret-access-keys" \
           -e PGP_KEY=https://example.com/pgp-key.txt \
           -e BACKUP_SCHEDULE="0 * * * *" \
           -e BACKUP_DIRECTORY="/backup" \
           -v /project/directory/to/backup:/backup \
           --network your-network \
           synweap15/docker-directory-backup-s3-gpg


## Variables

- `AWS_ACCESS_KEY_ID`
  Access Key
- `AWS_SECRET_ACCESS_KEY`
  Securet Access Key
- `PGP_KEY`
  Your PGP public key ID, used to encrypt your backups
  Can be a PGP key ID or a local filename or a http/https/ftp URL.
- `BACKUP_DIRECTORY`
  Directory within the Docker container to backup.
  Ensure a host directory is mounted there.

### Optional variables
- `AWS_DEFAULT_REGION`
  `us-east-1` by default
- `AWS_ENDPOINT`
  Customize this variable if you are using Minio, the url of your Minio server
- `PGP_KEYSERVER`
  the PGP key server used to retrieve you PGP public key, supports multiple servers seperated by comma
- `BACKUP_SCHEDULE`
  the interval of cron job to run mysqldump. `0 0 * * *` by default
- `BACKUP_BUCKET`
  the bucket of your S3/Minio
- `BACKUP_PREFIX`
  the default value is `mysql/%Y/%m/%d/mysql-`, please see the strftime(3) manual page
- `BACKUP_SUFFIX`
  the default value is `-%Y%m%d-%H%M.sql.gz.gpg`, please see the strftime(3) manual page

## Decrypt

    gpg --decrypt your-backup.gpg

    aws s3 cp s3://your-bucket/path/to/your/backup.gpg - | gpg --output backup.sql --decrypt

    mc cat minio/your-bucket/path/to/your/backup.gpg | gpg --output backup.sql --decrypt
