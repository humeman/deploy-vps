#!/bin/sh

set -e

# Remove files older than 45 days
duplicity \
    remove-older-than 45D --force \
    b2://{{ b2_account }}:{{ b2_key }}@{{ b2_bucket }}/backups

# Perform the backup, make a full backup if it's been over 20 days
duplicity \
    --full-if-older-than 20D \
    --include '/home' \
    --exclude '**' \
    / b2://{{ b2_account }}:{{ b2_key }}@{{ b2_bucket }}/backups

# Cleanup failures
duplicity \
    cleanup --force \
    b2://{{ b2_account }}:{{ b2_key }}@{{ b2_bucket }}/backups

# Show collection-status
duplicity collection-status \
    b2://{{ b2_account }}:{{ b2_key }}@{{ b2_bucket }}/backups