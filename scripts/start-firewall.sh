#!/bin/bash

function log_message {
  echo "`date --iso-8601=seconds --utc` start-firewall: $1"
}

# Use firewalld instead,   [firewalld_not_ufw] [ty_v1]
# it properly blocks ports exported via Docker;  ufw doesn't.


echo
log_message "Enabling firewall..."

apt-get -y install ufw

# Configure a firewall: (not needed if you're using Google Compute Engine)
ufw allow 22
ufw allow 80
ufw allow 443

log_message "You can answer Yes to the question below, unless you know you've done something very special:"
echo
ufw enable  # will ask you to confirm
echo

# Make the firewall work with Docker: (not needed in Google Compute Engine)
# 1) Change forward policy to accept: DEFAULT_FORWARD_POLICY="ACCEPT"
sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/#&\n# This makes Docker work:\nDEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw
# 2) Allow incoming connections on the Docker port:
ufw allow 2375/tcp
ufw reload

log_message "Done enabling firewall. Bye."
echo
