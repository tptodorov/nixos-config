#!/bin/sh
# Kill any existing gnome-keyring-daemon instances
pkill -f gnome-keyring-daemon 2>/dev/null
sleep 0.5

# Start gnome-keyring-daemon and export the environment variables
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh 2>/dev/null)
export SSH_AUTH_SOCK
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

# Update systemd and dbus environments
dbus-update-activation-environment --systemd SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID

# Log for debugging
echo "Keyring initialized: GNOME_KEYRING_CONTROL=$GNOME_KEYRING_CONTROL SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
