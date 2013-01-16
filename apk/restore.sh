#!/bin/bash

# Install all the apk:s that can be found in this dir.
# -r is undokumented. It overwrites previous instalations

if [ -z $RESTORE_SH ]; then

RESTORE_SH="restore.sh"

function restore() {
	source futil.tmpname.sh
	tmpname_flags_init "-a"

	echo wait-for-device
	adb wait-for-device
	for a in *.apk ; do
		echo -n "Installing: [$a] "
		adb wait-for-device install -r $a | tee -a $(tmpname apks) | grep "Failure"
		if [ $? -eq 0 ]; then
			echo
			echo "==============================================="
			adb shell df
			echo "==============================================="
			exit 1
		fi
	done

	tmpname_cleanup
}

source s3.ebasename.sh
if [ "$RESTORE_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	RESTORE_SH_INFO=${RESTORE_SH}
	source .aosp.apk.ui..restore.sh

	restore "$@"
	RC=$?

	exit $RC
fi

fi




