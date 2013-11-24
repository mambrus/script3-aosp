#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2013-04-26

if [ -z $LOGCAT_SH ]; then

LOGCAT_SH="logcat.sh"

function logcat() {
	for (( ; 1 ; )); do
		echo "wait-for-device"
		adb wait-for-device
		TS=$(date "+%y%m%d_%H%M%S");
		echo "Starting to log in file: logcat_${TS}"
		adb logcat -v threadtime | tee "logcat_${TS}".txt;
		echo
		echo
		echo "Finished logging at $(date "+%y%m%d_%H%M%S"). Data is in: logcat_${TS}.txt"
	done
}

source s3.ebasename.sh
if [ "$LOGCAT_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	LOGCAT_SH_INFO=${LOGCAT_SH}
	source .aosp.forever.ui..logcat.sh

	logcat "$@"
	RC=$?

	exit $RC
fi

fi
