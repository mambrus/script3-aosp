#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-10-04

# This script builds a standard Android build in a uniform way
#
# Features:
# =========
# * Produce colorized output if possible (requires grcat installed to
#     colorize but is tolerant not to require it)
# * Makes a static manifest snapshot so that each build can be exactly
#     reproduced from source)
# * Figures out the best -j make-flag for your host.
# *  Yet: Accepts all make arguments that Android build system would
#    normally accept.
# * Stores build artifacts in separate directory for each build occasion
# * build-artifacts consists of the following:
#   * build-log
#   * manifest.xml
#   * images
#   * symbols


function print_build_crcat_conf(){
	cat <<EOF
#
regexp=\bgcc\b
colours=yellow
count=more
.........
#
regexp=^.*?:
colours=magenta
count=once
.........
#
regexp=\`\w+\'
colours=green
.........
# -O
regexp=\-O\d
colours=green
.........
# -o
regexp=\-o\s.+\b
colours=yellow
.........
# Numbers
regexp=:[[:digit:]]+:
colours=blue

#WARNING
regexp=\bWARNING\b
colours=yellow

# warning and error won't work, unless you redirect also
# stderr to grcat
#
# warning
regexp=([Ww]arning|WARNING)
colours=yellow
.........
# error
regexp=([Ee]rror|ERROR)
colours=red blink
count=stop
EOF
}


if [ -z $BUILD_SH ]; then

BUILD_SH="build.sh"
BUILD_SH_MAKE_RC=0

function build() {
	EXTRA_MAKE_CMDLINE=${EXTRA_MAKE_CMDLINE-""}
	echo -n "========================================"
	echo    "========================================"
	echo "Starting build:"
	echo "make "$@" ${EXTRA_MAKE_CMDLINE}"
	echo -n "========================================"
	echo    "========================================"
	make "$@" ${EXTRA_MAKE_CMDLINE}

	#We need to pass exit-code differently as this executes in a subshell
	BUILD_SH_MAKE_RC=$?

	#Push the result in tempfile to workaround pipe when used with grc.
	echo ${BUILD_SH_MAKE_RC} > $(tmpname rc)
	if [ ! ${BUILD_SH_MAKE_RC} -eq 0 ]; then
		echo "Error: Build failed [${BUILD_SH_MAKE_RC}]"
		date
		exit 3
	fi
	return ${BUILD_SH_MAKE_RC}
}


source s3.ebasename.sh
if [ "$BUILD_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	BUILD_SH_INFO=${BUILD_SH}
	source .aosp.ui..build.sh
	source s3.user_response.sh
	source futil.tmpname.sh

	tmpname_flags_init "-a"

	if [ "X${ANDROID_PRODUCT_OUT}" == "X" ] || \
	   [ $(basename $(echo $ANDROID_PRODUCT_OUT)) == "generic" ]; then
		echo "Error: Did you lunch?" 1>&2
		exit 1
	fi
	if [ "X${ARM_EABI_TOOLCHAIN}" == "X" ] || [ ! -d ${ARM_EABI_TOOLCHAIN} ]; then
		echo "Error: Did you 'source build/envsetup.sh'?" 1>&2
		exit 1
	fi

	ls .repo/manifest.xml || (
		echo "Error: You're not standing in an Android root directory" 1>&2
		exit 3
	)

	#set -e
	set -u

	TS=$(date '+%y%m%d_%H%M%S')
	TSTART=$(date)
	GRCAT_FILE="$( ebasename $0 )_${TS}"
	ABN=${TARGET_PRODUCT}_$(hostname)_${TS}
	ARTIFACT_DIR="${ARTIFACT_MAIN_DIR}/${ABN}"
	NPROPS=$(grep processor /proc/cpuinfo | wc -l)

	#In -j flag is not overridden, calculate a good value
	if [ "X${NJ}" == "X" ]; then
		NJ=$(( NPROPS + (NPROPS/2) ))
	fi

	if [ ! -d ${ARTIFACT_MAIN_DIR} ]; then
		mkdir ${ARTIFACT_MAIN_DIR}
	fi

	which grcat > /dev/null && HAS_GRCAT="yes"
	if [ ! -d "${ARTIFACT_DIR}" ]; then
		mkdir -p "${ARTIFACT_DIR}"
	fi

	rg.static_manifest.sh "${ARTIFACT_DIR}/manifest.xml"

	if [ "X${HAS_GRCAT}" == "Xyes" ]; then
		print_build_crcat_conf > "${HOME}/.grc/${GRCAT_FILE}"
		( build "-j${NJ}" "$@" 2>&1 ) | \
			tee ${ARTIFACT_DIR}/buildlog | \
			grcat "${GRCAT_FILE}" \
		|| (
			echo "Error: Build failed"
			date
			exit 3
		)

		rm -f "${HOME}/.grc/${GRCAT_FILE}"
	else
		( build "-j${NJ}" "$@" 2>&1 ) | \
			tee ${ARTIFACT_DIR}/buildlog \
		|| (
			echo "Error: Build failed"
			date
			exit 3
		)
	fi
	TSTOP=$(date)
	echo "Build job stopped at: ${TSTOP}"
	BT=$(time.tdiff.sh "${TSTART}" "${TSTOP}")
	BT_H=$(echo "${BT} / 3600" | bc)
	BT_M=$(echo "(${BT} % 3600) / 60" | bc)
	BT_S=$(echo "(${BT} % 3600) % 60" | bc)
	echo "Build-time: ${BT_H}:${BT_M}:${BT_S} (${BT}s)"

	LAST_MAKE_RC=$(tail -n1 $(tmpname rc))
	if [ "X${LAST_MAKE_RC}" != "X0" ]; then
		echo -n "########################################"
		echo    "########################################"
		echo "Error: Build failed!" 1>&2
		echo -n "Please inspect logfile in [${ARTIFACT_DIR}/buildlog] "
		echo    "for further details"
		echo -n "########################################"
		echo    "########################################"
		exit 1
	fi
	# Parse for more possible errors that top-level make doesn't return as
	# error (which is an error in it's own b.t.w., but an error of the
	# build-system)
	ERRORS_IN_LOG=""

	#Known strings could be put in array and iterated. TBD
	ERRORS_IN_LOG="${ERRORS_IN_LOG} $(grep -n 'Error 1 (ignored)' ${ARTIFACT_DIR}/buildlog)"
	if [ "X${ERRORS_IN_LOG}" != "X" ]; then
		echo -n "########################################"
		echo    "########################################"
		echo "Build errors found in log:"
		echo "${ERRORS_IN_LOG}"
		echo -n "Please inspect logfile in [${ARTIFACT_DIR}/buildlog] "
		echo    "for further details"
		echo -n "########################################"
		echo    "########################################"
		set +u
		ask_user_continue "Continue with storing build (i.e. ignore error)? (Y/n)" || exit 1
		set -u
	fi

	# This part is made to surpress symbols and img copying into artifacts
	# It's designed using environment variable to avoid messing with
	# arguments normaly passed to make (and yes, it should be on by default
	# and hard to disable by misstake).
	if [ "X${AOSP_BUILD_SURPRESS_FULL}" == "Xyes"  ]; then
		echo "You don't want me to store symbols and images? Pff, FINE! :(" 1>&2
		exit 0
	fi

	(
		echo "Storing symbols..."
		cd "${ANDROID_PRODUCT_OUT}"
		cp obj/KERNEL/vmlinux symbols/
		tar -cf ${ANDROID_BUILD_TOP}/${ARTIFACT_DIR}/symbols.tar symbols
		mkdir -p ${ANDROID_BUILD_TOP}/${ARTIFACT_DIR}/images
		echo "Storing flashable images..."
		set +e
		cp -dp * ${ANDROID_BUILD_TOP}/${ARTIFACT_DIR}/images 2>/dev/null
		set -e
	)
	if [ "X${SURPRESS_COMPRESS_AND_TIDY}" != "Xno" ]; then
		(
			echo "Compressing into filename ${ARTIFACT_MAIN_DIR}/${ABN}.tar.gz..."
			cd ${ARTIFACT_MAIN_DIR}
			tar -czf ${ABN}.tar.gz ${ABN}/
		)

		echo "Cleaning up [${ARTIFACT_MAIN_DIR}/${ABN}]..."
		rm -rf ${ARTIFACT_MAIN_DIR}/${ABN}
	fi
	echo "All done!"

	exit $?
fi

fi
