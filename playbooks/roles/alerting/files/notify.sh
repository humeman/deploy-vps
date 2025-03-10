# Params:
#  service [delay] [count]
# service: systemd service to alert on
# delay: 1 to delay for 5 minutes, 0 to run immediately
# count: number of executions, timeout at 10

readonly MAX_RETRIES=10
readonly RETRY_DELAY=300

if [ $# -eq 0 ]; then
    echo "Parameters: service [delay] [count]"
    exit 1
fi

count=1
if [ -n "${3}" ]; then
    count=$3
    echo "Attempt: $3"
fi

if [ -n "${2}" ]; then
    if [ ${2} -eq 1 ]; then
        sleep ${RETRY_DELAY}
    fi
fi

service_status=$(systemctl -l status $1 --no-pager | tail -n 50 | jq -Rsa . | cut -d '"' -f 2)

read -rd '' json <<EOF
{
    "topic": "{{ alerting["ntfy_topic"] }}",
    "title": "Service: $1",
    "message": "Service \`$1\` has failed.\n\`\`\`$service_status\`\`\`",
    "tags": ["rotating_light"],
    "priority": 4,
    "markdown": true
}
EOF

curl ntfy.sh \
    -d "$json"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to post to ntfy."

    if [ ${count} -ge ${MAX_RETRIES} ]; then
        echo "Process failed after ${count} retries. Exiting."
        exit 1
    fi

    let "count=count+1"

    . /scripts/notifier/notify.sh $1 1 ${count}