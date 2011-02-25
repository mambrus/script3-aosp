#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-02-25

if [ -z $LINK_MYSYMS_SH ]; then

LINK_MYSYMS_SH="link_mysyms.sh"

# This script makes a link 'mysyms' to your last built Android
# symbols
function link_mysyms() {
    source ~/.android-helpers/build-config && \
    	ln -sf $(landroid)/out/target/product/${BUILD_RTARGET}/symbols mysyms 
}

source s3.ebasename.sh
if [ "$LINK_MYSYMS_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	source aosp.landroid.sh
	link_mysyms "$@"
	exit $?
fi

fi
