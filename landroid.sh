#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-02-25

if [ -z $LANDROID_SH ]; then

LANDROID_SH="landroid.sh"

# This script returns the full path of the last successfully built Android
# source path.
# It relies on that your build updates the file ~/.landroid
function landroid() {
    cat ~/.landroid  | egrep '^/' | tail -n1
}

source s3.ebasename.sh
if [ "$LANDROID_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	landroid $@
	exit $?
fi

fi
