#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-03-07
# Shell wraps tcp_tap to make it aosp.gdb.tap.sh

if [ -z $TAP_SH ]; then

TAP_SH="tap.sh"

# This script works as the basename command, except that it also
# ripps away everything in the name before the next but last '.'
# I.e. usage like:
# $ tap /some/path/pre.fix.myshell.sh
#   myshell.sh
#
# The script is a core part of the 'script3' script library

function tap() {
	exec tcp_tap "$@"
}

source s3.ebasename.sh
if [ "$TAP_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	export TCP_TAP_EXEC="$(which arm-eabi-gdb)"
	#export TCP_TAP_EXEC="$(which gdb71)"
	export TCP_TAP_PORT="6969"

	#Remove the remarks below to disable logging
	#Logging is default on and outputs at /tmp/tcp_tap*

	#export TCP_TAP_LOG_STDIN="/dev/null"
	#export TCP_TAP_LOG_STDOUT="/dev/null"
	#export TCP_TAP_LOG_STDERR="/dev/null"
	#export TCP_TAP_LOG_PARENT="/dev/null"
	#export TCP_TAP_LOG_CHILD="/dev/null"

	tap "$@"
	exit $?
fi

fi
