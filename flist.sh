#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2013-01-30

if [ -z $FLIST_SH ]; then

FLIST_SH="flist.sh"

# This solution takes care of the case where directories and files comes
# and goes. This way, *all* files are expanded simultaniously.

function flist() {
	source aosp.fixreply.sh
	local APPEND_STR="${START_DIR}"
	local -a APPEND_ARR
	local T_DIR=$(echo ${START_DIR} | sed -e 's/\//\\\//g')

	if [ "X$(echo ${SHELL_CMD} | grep adb)" != "X" ]; then
		adb wait-for-device
	fi

	for (( i=0; i<$DIR_DEPTH; i++ )); do
		APPEND_STR="${APPEND_STR}/*"
		APPEND_ARR[i]=${APPEND_STR}
	done

	${SHELL_CMD} echo "${APPEND_ARR[@]}" | \
		fixreply | \
		sed -e 's/ /\n/g' | \
		sed -n "/^${T_DIR}/p"
}

source s3.ebasename.sh
if [ "$FLIST_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	FLIST_SH_INFO=${FLIST_SH}
	source .aosp.ui..flist.sh

	flist "$@"
	RC=$?

	exit $RC
fi

fi
