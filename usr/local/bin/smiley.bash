#!/usr/bin/bash

set -o nounset
set -o verbose

SUDO="/usr/bin/sudo"

INTERFACE="wlp2s0"
ESSID="smiley"
CHANNEL=6
SHOW_INTERFACE="ip link show $INTERFACE"

$SUDO /usr/bin/dhcpcd --release ${INTERFACE}
set -o errexit
$SUDO $SHOW_INTERFACE
$SUDO ip link set $INTERFACE up
$SUDO $SHOW_INTERFACE
$SUDO iwconfig $INTERFACE essid $ESSID channel $CHANNEL
$SUDO $SHOW_INTERFACE
$SUDO sudo dhcpcd $INTERFACE
$SUDO $SHOW_INTERFACE

