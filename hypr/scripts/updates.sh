#!/bin/bash
#  _   _           _       _             
threshhold_green=0
threshhold_yellow=25
threshhold_red=100

script_folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

updates=$("$script_folder/update_checker.sh" | wc -l)

css_class="green"

if [ "$updates" -gt $threshhold_yellow ]; then
    css_class="yellow"
fi

if [ "$updates" -gt $threshhold_red ]; then
    css_class="red"
fi

if [ "$updates" -gt $threshhold_green ]; then
    printf '{"text": "%s", "alt": "%s", "tooltip": "Click to update your system", "class": "%s"}' "$updates" "$updates" "$updates" "$css_class"
else
    printf '{"text": "0", "alt": "0", "tooltip": "No updates available", "class": "green"}'
fi

