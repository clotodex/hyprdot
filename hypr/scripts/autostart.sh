#!/bin/bash

################################################################
# Script to welcom the user and start some optional services   #
# This Script is designed to be run on start of the compositor #
################################################################

# TODO this is probably better as a qtile widget

echo
read -p "Start bluetooth? (Y/n) " -n 1 -r
echo
[[ $REPLY =~ ^[Nn]$ ]] && echo "No." || systemctl restart bluetooth


echo
read -p "Start docker? (Y/n) " -n 1 -r
echo
[[ $REPLY =~ ^[Nn]$ ]] && echo "No." || systemctl restart docker


echo
read -p "Start slack? (Y/n) " -n 1 -r
echo
[[ $REPLY =~ ^[Nn]$ ]] && echo "No." || qtile cmd-obj -o cmd -f spawn -a "bash -c 'GDK_BACKEND=wayland flatpak run com.slack.Slack --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer'"
