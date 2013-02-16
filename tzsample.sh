#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-12-10

HOST_TRIM_MS=89
#HOST_DELAY_FIRST=114
HOST_DELAY_FIRST=154


if [ -z $TZSAMPLE_SH ]; then

TZSAMPLE_SH="tzsample.sh"

function aosp.dvfs_print() {
	local DEVFS="/sys/kernel/debug/clock/dvfs"
	local ANSWER=$(
		bash -c "${SHELL_CMD} cat ${DEVFS}" | \
			fixreply | \
			grep "${1}" | \
			awk '{print $2}'
	)
	if [ "X${ANSWER}" != "X" ]; then
		echo -n "$(( ${ANSWER} / 1000000 ))${DELIM}"
	else
		echo -n "0"${DELIM}
	fi

}

function aosp.gpufreq_print() {
	 aosp.dvfs_print "3d"
}

function aosp.busfreq_print() {
	 aosp.dvfs_print "emc"
}

function tzsample() {
	source aosp.fixreply.sh
	source time.epoch.sh
	source time.tdiff.sh
	source time.tadd.sh

	local CPU_PATH="/sys/devices/system/cpu"
	local CFRQ_PATT="${CPU_PATH}/cpu*/cpufreq/cpuinfo_cur_freq"
	local TZ_PATT="${TZ_DIR}/thermal_zone*/temp"
	local TS_START=$(epoch)
	local TS_NOW=${TS_START}
	local TS_LAST=${TS_START}
	local NCPU=$(
		bash -c "${SHELL_CMD} cat \"/proc/cpuinfo\"" | \
		fixreply | \
		grep -i bogomips | \
		wc -l
	)

	FREQ_FORMULA='$F / 1512 * 100'
	if [ "X${CPUFREQ}" != "Xno" ]; then
		# Detect min/max supported frequencies. Use CPU0 to conclude as
		# CPU0 is always online (on an alive system i.e. otherwise it's
		# rather pointless anyway).
		local FRQ_MIN=$(
			bash -c "${SHELL_CMD} \"cat ${CPU_PATH}/cpu0/cpufreq/scaling_min_freq\"" | \
			fixreply )

		local FRQ_MAX=$(
			bash -c "${SHELL_CMD} \"cat ${CPU_PATH}/cpu0/cpufreq/scaling_max_freq\"" | \
			fixreply )
	fi


 	PERIOD=$(( ${PERIOD} - ${HOST_TRIM_MS} ))

	local TS_ROUNDTRIP_MS=""

	while true; do
		if [ "X${CPUFREQ}" != "Xno" ]; then
			CFRQS=$(
				bash -c "${SHELL_CMD} \"cat ${CFRQ_PATT}\"" | \
				fixreply )
		fi
		THS=$(
			bash -c "${SHELL_CMD} \"cat ${TZ_PATT}\"" | \
			fixreply )

		TS_LAST=${TS_NOW}
		TS_NOW=$(epoch)
		TS_FROM_START=$(tdiff ${TS_START} ${TS_NOW})
		if [ "X${TS_ROUNDTRIP_MS}" != "X" ]; then
			TS_ROUNDTRIP_MS=$(echo "$(tdiff ${TS_LAST} ${TS_NOW} ) * 1000" | bc )
		else
			TS_ROUNDTRIP_MS=$(( ${PERIOD} + ${HOST_DELAY_FIRST} ))
		fi

		if [ "X${XOFFSET}" != "X" ]; then
			echo -n "$(tadd ${TS_FROM_START} ${XOFFSET})${DELIM}"
		fi
		if [ "X${CPUFREQ}" == 'XkHz' ]; then
			local N=0
			for F in $CFRQS; do
				echo -n "$(( ${F} / 1000 ))${DELIM}"
				(( N ++ ))
			done
			#Print zero HZ for ofline CPU. must be a value as feedgnuplot has
			#whitespace as separator
			for (( I=N;N<NCPU;N++ )); do
				echo -n "0${DELIM}"
			done
		fi
		if [ "X${CPUFREQ}" == 'X%' ]; then
			local N=0
			for F in $CFRQS; do
				echo -n "$(( (${F} * 100 / $FRQ_MAX ) ))${DELIM}"
				(( N ++ ))
			done
			#Print zero HZ for ofline CPU. must be a value as feedgnuplot has
			#whitespace as separator
			for (( I=N;N<NCPU;N++ )); do
				echo -n "0${DELIM}"
			done
		fi

		if [ "X${BUSFREQ_MAX}" != "X" ]; then
			aosp.busfreq_print
		fi
		if [ "X${GPUCLK_MAX}" != "X" ]; then
			aosp.gpufreq_print
		fi

		for T in $THS; do
			if [ $T -lt 256 ]; then
				echo -n "$(( $T * 1000))${DELIM}"
			else
				echo -n "$T${DELIM}"
			fi
		done
		echo

		local -i SLEEP_T=$(
			echo "${PERIOD} - (${TS_ROUNDTRIP_MS}-${PERIOD})/2 " | \
			bc | \
			cut -f1 -d"."
		)

		if [[ $SLEEP_T == 0 ]]; then
			SLEEP_T=1;
		fi
		#echo $SLEEP_T
		if [ $SLEEP_T -gt 0 ]; then
			msleep ${SLEEP_T}
		else
			echo "Can't compensate lag-error" 2>&1
		fi
	done
}

source s3.ebasename.sh
if [ "$TZSAMPLE_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	TZSAMPLE_SH_INFO=${TZSAMPLE_SH}
	source .aosp.ui..tzsample.sh
	source futil.find.sh
	source aosp.fixreply.sh

	#tzsample "$@"

	#detect available thermal zones:
	TZS=$(
		bash -c "${SHELL_CMD} echo /sys/class/thermal/thermal_zone*/temp" | \
		fixreply )

	#Print legend
	if [ "X${LEGEND}" == "Xyes" ]; then
		if [ "X${XOFFSET}" != "X" ]; then
			echo -n "Time${DELIM}"
		fi
		if [ "X${CPUFREQ}" != "Xno" ]; then
			NCPU=$(
				bash -c "${SHELL_CMD} cat \"/proc/cpuinfo\"" | \
				fixreply | \
				grep -i bogomips | \
				wc -l
			)
			for (( N=0;N<NCPU;N++ )); do
				echo -n "freqCPU${N}${DELIM}"
			done
		fi
		if [ "X${BUSFREQ_MAX}" != "X" ]; then
			echo -n "freqBUS${DELIM}"
		fi
		if [ "X${GPUCLK_MAX}" != "X" ]; then
			echo -n "freqGPU${DELIM}"
		fi

		NAMES=$(
			bash -c "${SHELL_CMD} cat \"${TZ_DIR}/thermal_zone*/type\"" | \
			fixreply )
		for N in ${NAMES}; do
			echo -n "$N${DELIM}"
		done
		echo
	fi
	if [ "X${DRYRUN}" == "Xyes" ]; then
		exit 0
	fi
	#Pass as one argument
	tzsample "${TZS}"
	RC=$?

	exit $RC
fi

fi
