#!/bin/bash
set -e

if [ ! -f /state/fail2ban/installed ]; then
    cd /tmp
    wget https://launchpad.net/ubuntu/+source/fail2ban/1.1.0-1/+build/28291332/+files/fail2ban_1.1.0-1_all.deb
    sudo dpkg -i fail2ban_1.1.0-1_all.deb
    rm fail2ban_1.1.0-1_all.deb
    touch /state/fail2ban/installed
fi