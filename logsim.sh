#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2013-04-26

if [ -z $LOGSIM_SH ]; then

LOGSIM_SH="logsim.sh"

#Precision sleep
function psleep() {
	python -c "from time import sleep; sleep($1)"
}

function cond_sleep() {
	read line

	echo -n $line
}

function logsim() {
		cat ${INFILE} | awk -v ST="0.1" '{print $0; system("sleep "ST"")}'  >> ${OUTFILE}
		#cat ${INFILE} | cond_sleep >> ${OUTFILE}
		#cat ${INFILE} >> ${OUTFILE}
		#echo "hej på dig"  >> ${OUTFILE}
}

source s3.ebasename.sh
if [ "$LOGSIM_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	LOGSIM_SH_INFO=${LOGSIM_SH}
	source .aosp.ui..logsim.sh
	set -u

	if [ "X${PIPE}" != "X" ]; then
		OUTFILE="${PIPE}"

		if [ -a "${OUTFILE}" ] && [ ! -p "${OUTFILE}" ]; then
			echo "Error: File [${OUTFILE}] already exists but it's not a pipe"
			exit 1
		fi
		if [ ! -p "${OUTFILE}" ]; then
			mkfifo "${OUTFILE}"
		fi
	fi

	logsim "$@"
	RC=$?

	exit $RC
fi

fi
