#!/bin/bash
hyprshade_filter="blue-light-filter"
if [[ "$1" == "rofi" ]]; then

    # Open rofi to select the Hyprshade filter for toggle
    options="$(hyprshade ls)\noff"

    # Open rofi
    choice=$(echo -e "$options" | rofi -dmenu -replace -config ~/dotfiles/rofi/config-hyprshade.rasi -i -no-show-icons -l 4 -width 30 -p "Hyprshade")
    if [ ! -z $choice ] ;then
		# strip choice
		choice=$(echo $choice | awk '{print $1}')
        dunstify "Changing Hyprshade to $choice"
		hyprshade_filter=$choice
    fi
fi

# Toggle Hyprshade
if [ "$hyprshade_filter" != "off" ] ;then
	if [ -z "$(hyprshade current)" ] ;then
		echo ":: hyprshade is not running"
		hyprshade on $hyprshade_filter
		notify-send "Hyprshade activated" "with $(hyprshade current)"
		echo ":: hyprshade started with $(hyprshade current)"
	else
		notify-send "Hyprshade deactivated"
		echo ":: Current hyprshade $(hyprshade current)"
		echo ":: Switching hyprshade off"
		hyprshade off
	fi
else
	hyprshade off
	echo ":: hyprshade turned off"
fi
