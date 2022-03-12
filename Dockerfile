FROM ubuntu:focal-20220302

ENV AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_DEFAULT_REGION="us-east-1" \
    AWS_ENDPOINT="" \
    BACKUP_SCHEDULE="0 0 * * *" \
    BACKUP_BUCKET="backup" \
    BACKUP_PREFIX="files/%Y/%m/%d/files-" \
    BACKUP_SUFFIX="-%Y%m%d-%H%M.sql.gpg" \
    BACKUP_DIRECTORY="/backup" \
    PGP_KEY="" \
    PGP_KEYSERVER="hkps://keys.gnupg.net,hkps://pgp.mit.edu,hkps://keyserver.ubuntu.com,hkps://peegeepee.com,hkp://keys.gnupg.net,hkp://pgp.mit.edu,hkp://keyserver.ubuntu.com,hkp://pool.sks-keyservers.net"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
           python3 python3-pip python3-setuptools python3-wheel \
           cron wget gnupg \
    && pip3 install awscli \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && echo "Done."

COPY README.md /
COPY *.sh /usr/local/bin/
RUN ["chmod", "+x", "/usr/local/bin/docker-entrypoint.sh"]

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["cron"]
