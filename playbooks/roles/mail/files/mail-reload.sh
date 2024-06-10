#!/bin/bash
set -e

postfix reload
systemctl reload dovecot