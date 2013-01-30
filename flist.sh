#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2013-01-30

if [ -z $FLIST_SH ]; then

FLIST_SH="flist.sh"

function flist() {
	source aosp.fixreply.sh
	source futil.tmpname.sh
	tmpname_flags_init "-a"
	local APPEND_STR=""

	if [ "X$(echo ${SHELL_CMD} | grep adb)" != "X" ]; then
		adb wait-for-device
	fi

	for (( i=0; i<$DIR_DEPTH; i++ )); do
		APPEND_STR="${APPEND_STR}/*"
		${SHELL_CMD} echo "${START_DIR}${APPEND_STR}" | fixreply >> $(tmpname)
	done
	
	local T_DIR=$(echo ${START_DIR} | sed -e 's/\//\\\//g')
	sed -e 's/ /\n/g' < $(tmpname) | sed -n "/^${T_DIR}/p"
	tmpname_cleanup
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
