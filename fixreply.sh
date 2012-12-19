#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-12-18

if [ -z $FIXREPLYS_SH ]; then

FIXREPLYS_SH="fixreply.sh"

function fixreply() {
		cat -- | \
		sed -e 's/\x1b.\x4b//g' | \
		sed -e 's/\x0d/\n/g'
}

source s3.ebasename.sh
if [ "$FIXREPLYS_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	FIXREPLYS_SH_INFO=${TZPLOTS_SH}
	source .aosp.ui..fixreply.sh

	fixreply "$@"
	RC=$?

	exit $RC
fi

fi
