#!/bin/bash
# Params:
#  service [delay] [count]
# service: systemd service to alert on
# delay: 1 to delay for 5 minutes, 0 to run immediately
# count: number of executions, timeout at 10

set -e

readonly MAX_RETRIES=10
readonly RETRY_DELAY=300

if [ $# -eq 0 ]; then
    echo "Parameters: service [delay] [count]"
    exit 1
fi

count=0
if [ -n "${3}" ]; then
    count=$3
    echo "Attempt: $3"
fi

if [ -n "${2}" ]; then
    if [ ${2} -eq 1 ]; then
        sleep ${RETRY_DELAY}
    fi
fi

read -rd '' json <<EOF
payload_json={
    "embeds": [
        {
            "title": "Systemd node alert: $(hostname -f), $1",
            "description": "Systemd service \`$1\` has failed. See attached logs for more.",
            "color": 12869919,
            "footer": {
                "text": "Retry #: ${count}/${MAX_RETRIES}"
            }
        }
    ]
}
EOF

systemctl -l status $1 --no-pager > /tmp/discord_notifier_log.txt

curl -X POST {{ discord_webhook_url }} \
    -F "file=@/tmp/discord_notifier_log.txt" \
    -F "$json"

rm /tmp/discord_notifier_log.txt

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to post to Discord."

    if [ ${count} -ge ${MAX_RETRIES} ]; then
        echo "Process failed after ${count} retries. Exiting."
        exit 1
    fi

    let "count=count+1"

    . /scripts/notifier/notify.sh $1 1 ${count}

fi