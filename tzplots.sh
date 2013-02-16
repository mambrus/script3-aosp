#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-12-16

if [ -z $TZPLOTS_SH ]; then

TZPLOTS_SH="tzplots.sh"

function tzplots() {
	source aosp.fixreply.sh
	source futil.tmpname.sh
	tmpname_flags_init "-a"

	if [ "X$(echo ${SHELL_CMD} | grep adb)" != "X" ]; then
		adb wait-for-device
	fi

	local NCPU=$(
		bash -c "${SHELL_CMD} cat \"/proc/cpuinfo\"" | \
		fixreply | \
		grep -i bogomips | \
		wc -l
	)
	local Y2_LEGEND_STR="--y2 0"

##Add 2 more for bus and GPU-freq
	(( NCPU += 2 ))
	for (( n=1;n<NCPU;n++ )); do
		Y2_LEGEND_STR="${Y2_LEGEND_STR},${n}"
	done

	local LEGEND=$(
		aosp.tzsample.sh -F -G0 -B0 -L | \
		sed -e 's/;/\n/g' | \
		 awk '
		 	BEGIN{
				c=0
			}{
				printf("--legend %d %s\n",c,$1);
				c++
			}' | \
		 head -n-1
	)

	if [ "X${FRQ_HZ}" == "Xyes" ];then
		local Y2LABEL="Hz(%)"
		local FRQ_MIN=0
		local FRQ_MAX=100
		#TBD - needs adding real maxfreqs for GPU and SYSbus
		local FLG="-f -G600 -B792"
	else
		local Y2LABEL="MHz"
		local FLG="-F -G0 -B0"
		#Detect min/max supported frequencies. Use CPU0 to detec it from
		#which is always available.
		local CPU_PATH="/sys/devices/system/cpu"
		local FRQ_MIN=$(
			bash -c "${SHELL_CMD} \"cat ${CPU_PATH}/cpu0/cpufreq/cpuinfo_min_freq\"" | \
			fixreply )

		local FRQ_MAX=$(
			bash -c "${SHELL_CMD} \"cat ${CPU_PATH}/cpu0/cpufreq/cpuinfo_max_freq\"" | \
			fixreply )

		(( FRQ_MIN /= 1000 ))
		(( FRQ_MAX /= 1000 ))

		#Ingnore calc low level. 0 is needed to se when a CPU is off-line
		FRQ_MIN=0
	fi

    if [ "X${DEBUG}" == "Xyes" ];then
		xterm -e /bin/bash -c "tail -f $(tmpname samples)" &

		echo "Will execute:"
		echo "aosp.tzsample.sh ${FLG} -T${XOFFS_SCS} -lno | \
			tee $(tmpname samples) | \
			feedgnuplot \
				--geometry \"${XGEOMETRY}\" \
				--stream \"${PERIOD_SCS}\" \
				--xlen \"${XWIDTH_SCS}\" \
				--line \
				--domain \
				--xlabel \"Time(s)\" \
				--ylabel \"milli Celcius\" \
				--y2label=\"${Y2LABEL}\" \
				${Y2_LEGEND_STR} \
				--ymin 22000 \
				--ymax 95000 \
				--y2min ${FRQ_MIN} \
				--y2max ${FRQ_MAX} \
				$(echo ${LEGEND})" | sed -e 's/\t//g'
	fi

	aosp.tzsample.sh ${FLG} -T${XOFFS_SCS} -lno | \
		tee $(tmpname samples) | \
		feedgnuplot \
			--geometry "${XGEOMETRY}" \
			--stream "${PERIOD_SCS}" \
			--xlen "${XWIDTH_SCS}" \
			--line \
			--domain \
			--xlabel "Time(s)" \
			--ylabel "milli Celcius" \
			--y2label="${Y2LABEL}" \
			${Y2_LEGEND_STR} \
			--ymin 22000 \
			--ymax 95000 \
			--y2min ${FRQ_MIN} \
			--y2max ${FRQ_MAX} \
			$(echo ${LEGEND})

	tmpname_cleanup
}

source s3.ebasename.sh
if [ "$TZPLOTS_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	TZPLOTS_SH_INFO=${TZPLOTS_SH}
	source .aosp.ui..tzplots.sh

	tzplots "$@"
	RC=$?

	exit $RC
fi

fi
