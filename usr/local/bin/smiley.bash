#!/usr/bin/bash

set -o nounset
set -o errexit
set -o verbose

INTERFACE="wlp2s0"
ESSID="smiley"
CHANNEL=6
SHOW_INTERFACE="ip link show $INTERFACE"

$SHOW_INTERFACE
ip link set $INTERFACE up
$SHOW_INTERFACE
iwconfig $INTERFACE essid $ESSID channel $CHANNEL
$SHOW_INTERFACE
sudo dhcpcd $INTERFACE
$SHOW_INTERFACE

