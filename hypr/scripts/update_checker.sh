#!/bin/bash

# TODO only execute if internet
# TODO maybe throttle this to be called only once a day

interval_eix=${1:600}

# TODO actually the diff should be between this, then emerge --syn, then another
diff="$(( $(date +%s) - $(date +%s --date="$(cat /var/db/repos/gentoo/metadata/timestamp.chk)") ))"

if [[ $interval_eix -lt $diff ]]; then
	if wget -q --spider http://google.com; then
		{ sudo eix-sync -q 2>&1; } > /dev/null
	fi
fi

# list updates (non-deep)
# TODO have multiple scripts that check different updates that all use the same eix-sync
eix -cu --world -'#'
