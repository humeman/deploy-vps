#!/bin/bash
# Params:
#  service
# service: systemd service to alert on

readonly MAX_ATTEMPTS=5
readonly RETRY_DELAY=30

if [ $# -eq 0 ]; then
    echo "Parameters: service"
    exit 1
fi

service="$1"

service_status=$(systemctl -l status "$service" --no-pager | tail -n 50)

json=$(jq -n \
    --arg title "Service failed" \
    --arg description "$(printf '%s\n\n%s' "$service" "$service_status")" \
    '{level: "error", title: $title, description: $description}')

for attempt in $(seq 1 ${MAX_ATTEMPTS}); do
    if curl --fail --silent --show-error --max-time 30 \
        -X POST "{{ alerting["url"] }}/v1/notify" \
        -H "Authorization: Bearer {{ alerting["key"] }}" \
        -H "Content-Type: application/json" \
        -d "$json"; then
        exit 0
    fi

    echo "ERROR: Failed to post alert (attempt ${attempt}/${MAX_ATTEMPTS})."

    if [ "${attempt}" -lt ${MAX_ATTEMPTS} ]; then
        sleep ${RETRY_DELAY}
    fi
done

echo "Alert failed after ${MAX_ATTEMPTS} attempts. Exiting."
exit 1
