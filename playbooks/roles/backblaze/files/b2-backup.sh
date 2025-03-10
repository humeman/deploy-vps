#!/bin/sh

set -e

# Remove files older than 8 days
duplicity \
    remove-older-than 8D --force \
    --no-encryption \
    b2://{{ b2["account"] }}:{{ b2["key"] }}@{{ b2["bucket"] }}/backups

# Perform the backup, make a full backup if it's been over 7 days
duplicity \
    --full-if-older-than 7D \
    --include '/home' \
{% for item in flag_backups %}
    --include '{{ item }}' \
{% endfor %}
{% for item in extra_backups %}
    --include '{{ item }}' \
{% endfor %}
    --exclude '**' \
    --no-encryption \
    / b2://{{ b2["account"] }}:{{ b2["key"] }}@{{ b2["bucket"] }}/backups

# Cleanup failures
duplicity \
    cleanup --force \
    --no-encryption \
    b2://{{ b2["account"] }}:{{ b2["key"] }}@{{ b2["bucket"] }}/backups

# Show collection-status
duplicity collection-status \
    --no-encryption \
    b2://{{ b2["account"] }}:{{ b2["key"] }}@{{ b2["bucket"] }}/backups