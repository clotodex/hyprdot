#!/bin/bash

###################################
# Low-Battery Notification Script #
###################################

# Description:
# > Prints a notification with notify-send when the battery percentage is under certain thresholds optionally defined by $*
#	> Example battery-notify-daemon.sh 10 30
# > The fuller the battery, the less often it checks

THRESHOLD_SUSPEND=5
THRESHOLD_CRITICAL=10
THRESHOLD_WARNING=30

MIN_SLEEP=60
MAX_SLEEP=600

# Check for arguments
if [[ $# -gt 0 ]]; then
	if [[ $1 -gt 0 ]]; then
		THRESHOLD_CRITICAL=$1
	fi
	if [[ $2 -gt 0 ]]; then
		THRESHOLD_WARNING=$2
	fi
	if [[ $3 -gt 0 ]]; then
		MIN_SLEEP=$3
	fi
	if [[ $4 -gt 0 ]]; then
		MAX_SLEEP=$4
	fi
fi

while true; do
	# Check if battery is charging
	if acpi | grep "Charging"; then
		sleep "$MAX_SLEEP"
	fi

	# Check battery percentage
	BATTERY_PERCENTAGE="$(acpi | grep -Po '\d+(?=%)')"
	REMAINING="$(acpi | grep -oP "[^ ]*(?= remaining)")"

	# battery level is below or equal to the critical threshold
	if [[ $BATTERY_PERCENTAGE -le $THRESHOLD_SUSPEND ]]; then
		systemctl suspend
	elif [[ $BATTERY_PERCENTAGE -le $THRESHOLD_CRITICAL ]]; then
		dunstify -u 2 "Battery critical: $BATTERY_PERCENTAGE%!" "Time remaining $REMAINING"
	# battery level is below or equal to the warning threshold
	elif [[ $BATTERY_PERCENTAGE -le $THRESHOLD_WARNING ]]; then
		dunstify "Battery getting low: $BATTERY_PERCENTAGE%!" "Time remaining $REMAINING"
	fi

	# computing sleep time (linear interpolation between MIN_SLEEP at THRESHOLD_CRITICAL and MAX_SLEEP at 100%

	SLEEP_TIME=$(echo "scale=2; $MIN_SLEEP + (($MAX_SLEEP - $MIN_SLEEP) * (($BATTERY_PERCENTAGE-$THRESHOLD_CRITICAL) / (100-$THRESHOLD_CRITICAL)))" | bc | xargs printf "%.0f\n")
	SLEEP_TIME="$((SLEEP_TIME>MIN_SLEEP ? SLEEP_TIME : MIN_SLEEP))"

	echo "sleeping for $SLEEP_TIME @ bat: $BATTERY_PERCENTAGE"
	sleep "$SLEEP_TIME"
done

