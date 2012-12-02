
#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-02-25

if [ -z $ATTACH_SH ]; then

ATTACH_SH="attach.sh"

# This script attaches to a running process on an Android target
# process is defined by name
function attach() {
	local PNAME=${1}
	local PORT=$2
	local PID=$(adb shell ps | grep $PNAME | sed -e 's/^[[:alnum:]_]\+[[:space:]]\+//; s/[[:space:]]\+.*$//')

	if [ "x${PID}" == "x" ]; then
		echo "No process [$PNAME] on running target. exiting" 1>&2
		exit 1
	else
		echo "Attaching $PNAME at PID=$PID using TCP port: $PORT "
	fi

	#adb root; adb remount;
	adb forward "tcp:$PORT" "tcp:$PORT";

	#adb shell "gdbserver :$PORT --attach $PID"
	adb shell "semc_gdbserver :$PORT --attach $PID"
}

source s3.ebasename.sh
if [ "$ATTACH_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	#PNAME="com.sonyericsson.calendar"
	PNAME="system_server"
	if [ ! -z $1 ]; then
	  PNAME=$1
	fi

	PORT=5039
	#PORT=5040

	attach "${PNAME}" $PORT
	exit $?
fi

fi

