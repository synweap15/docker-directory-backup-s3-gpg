#!/bin/bash
[[ -n "${DEBUG:-}" ]] && set -x
set -eu -o pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

source /etc/profile.d/s3.sh

AWS_CLI_OPTS=(--color off)
[[ -n "${AWS_ENDPOINT}" ]] && AWS_CLI_OPTS+=(--endpoint-url "$AWS_ENDPOINT")

BACKUP_FILENAME=backup
S3_FILENAME="${BACKUP_BUCKET}/$(date "+${BACKUP_PREFIX}${BACKUP_FILENAME}${BACKUP_SUFFIX}")"

function s3() {
    aws "${AWS_CLI_OPTS[@]}" s3 "$@"
}

tar cf - "${BACKUP_DIRECTORY}" \
    | gpg --encrypt -r "${PGP_KEY}" --compress-algo zlib --quiet \
    | s3 cp - "s3://${S3_FILENAME}" \
    || (s3 rm "s3://${S3_FILENAME}";  $(exit 1))

E_CODE=$?

if [[ "$E_CODE" -eq 0 ]]; then
  STATUS="SUCCESS"
  SUBJECT="[DIRECTORY] Backup to '$BACKUP_BUCKET' successful"
else
  STATUS="FAIL"
  SUBJECT="[DIRECTORY] Backup to '$BACKUP_BUCKET' error"
fi

# Set email body
BODY="[$STATUS] MySQL backup of '$BACKUP_DIRECTORY' to $S3_FILENAME, exit code: $?"

# Print body for logging/debugging
echo "$BODY"

# Send notification email
SEND_MAIL_SCRIPT="${BASH_SOURCE%/*}/send-mail.sh"
if "${SEND_MAIL_SCRIPT}" -t "${MAIL_TO}" -s "${SUBJECT}" -o "${BODY}"; then
    echo "Notification email sent"
else
    echo "Notification email error"
fi
