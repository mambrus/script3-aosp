#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2013-04-26

if [ -z $LOGSIM_SH ]; then

LOGSIM_SH="logsim.sh"

function logsim() {
		cat -- | \
		sed -e 's/\x1b.\x4b//g' | \
		sed -e 's/\x0d/\n/g'
}

source s3.ebasename.sh
if [ "$LOGSIM_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	LOGSIM_SH_INFO=${LOGSIM_SH}
	source .aosp.ui..logsim.sh

	logsim "$@"
	RC=$?

	exit $RC
fi

fi
