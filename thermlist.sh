#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-12-10


if [ -z $THERMLIST_SH ]; then

THERMLIST_SH="thermlist.sh"


function thermlist() {
	while true; do
		THS=$(
			bash -c "${SHELL_CMD} cat /sys/class/thermal/thermal_zone*/temp" | \
			sed -e 's/\x1b.\x4b//g' | \
			sed -e 's/\x0d/\n/g')
		for T in $THS
		do
			echo -n "$T${DELIM}"
		done
		echo
		msleep ${PERIOD}
	done
}

#Prefered way, but too slow
function thermlist_alt1() {
	while true; do

		for T in $1; do
			TMP=$(
				bash -c "${SHELL_CMD} cat $T" \
				sed -e 's/\x1b.\x4b//g' | \
				sed -e 's/\x0d/\n/g'
			)
			echo -n "$TMP;"
		done
		echo
		msleep ${PERIOD}
	done
}

source s3.ebasename.sh
if [ "$THERMLIST_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	THERMLIST_SH_INFO=${THERMLIST_SH}
	source .aosp.ui..thermlist.sh
	source futil.find.sh

	#thermlist "$@"

	#detect available thermal zones:
	TZS=$(
		bash -c "${SHELL_CMD} echo /sys/class/thermal/thermal_zone*/temp" | \
		sed -e 's/\x1b.\x4b//g' | \
		sed -e 's/\x0d/\n/g'
	)

	#Pass as one argument
	thermlist "${TZS}"
	RC=$?

	cd ${OLD_PATH}

	exit $RC
fi

fi
