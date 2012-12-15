#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-12-10


if [ -z $TZSAMPLE_SH ]; then

TZSAMPLE_SH="tzsample.sh"


function tzsample() {
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
function tzsample_alt1() {
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
if [ "$TZSAMPLE_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	TZSAMPLE_SH_INFO=${TZSAMPLE_SH}
	source .aosp.ui..tzsample.sh
	source futil.find.sh

	#tzsample "$@"

	#detect available thermal zones:
	TZS=$(
		bash -c "${SHELL_CMD} echo /sys/class/thermal/thermal_zone*/temp" | \
		sed -e 's/\x1b.\x4b//g' | \
		sed -e 's/\x0d/\n/g'
	)

	#Print legend
	#adb shell cat /sys/class/thermal/thermal_zone1/type
	NAMES=$(
		bash -c "${SHELL_CMD} cat /sys/class/thermal/thermal_zone*/type" | \
		sed -e 's/\x1b.\x4b//g' | \
		sed -e 's/\x0d/\n/g')
	for N in ${NAMES}
	do
		echo -n "$N${DELIM}" 1>&2
		#echo -n "$N${DELIM}"
	done
	echo 1>&2
	#echo

	#Pass as one argument
	tzsample "${TZS}"
	RC=$?

	cd ${OLD_PATH}

	exit $RC
fi

fi
