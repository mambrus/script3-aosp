#!/bin/bash

# All the user installed apps is in /data/app/


if [ -z $GETALL_SH ]; then

GETALL_SH="getall.sh"

function getall() {
	source aosp.fixreply.sh

	adb wait-for-device root
	FS=$(adb shell ls /data/app/ | fixreply)
	for F in $FS; do
		echo -n "pulling: [$F] "
		adb pull /data/app/$F
	done
}

source s3.ebasename.sh
if [ "$GETALL_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	GETALL_SH_INFO=${TZPLOTS_SH}
	source .aosp.apk.ui..getall.sh

	getall "$@"
	RC=$?

	exit $RC
fi

fi
