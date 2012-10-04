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

function build() {
	make "$@"
}


source s3.ebasename.sh
if [ "$BUILD_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	set -e

	if [ "X${ANDROID_PRODUCT_OUT}" == "X" ] || \
	   [ $(basename $(echo $ANDROID_PRODUCT_OUT)) == "generic" ]; then
		echo "Error: Did you lunch?" 1>&2
		exit 1
	fi
	if [ "X${ARM_EABI_TOOLCHAIN}" == "X" ] || [ ! -d ${ARM_EABI_TOOLCHAIN} ]; then
		echo "Error: Did you 'source build/envsetup.sh'?" 1>&2
		exit 1
	fi

	if [ -z AOSP_BUILD_SURPRESS_FULL ]; then
		AOSP_BUILD_SURPRESS_FULL="no"
	fi

	set -u

	TS=$(date '+%y%m%d_%H%M%S')
	GRCAT_FILE="$( ebasename $0 )_${TS}"
	ARTIFACT_DIR="build_artifacts/$(hostname)_${TS}"
	NPROPS=$(grep processor /proc/cpuinfo | wc -l)
	NJ=$(( NPROPS + (NPROPS/2) ))

	which grcat > /dev/null && HAS_GRCAT="yes"
	if [ ! -d "${ARTIFACT_DIR}" ]; then
		mkdir -p "${ARTIFACT_DIR}"
	fi

	grit.cstat_manifest.sh "${ARTIFACT_DIR}/manifest.xml"

	if [ "X${HAS_GRCAT}" == "Xyes" ]; then
		print_build_crcat_conf > "${HOME}/.grc/${GRCAT_FILE}"
		(build "-j${NJ}" "$@" 2>&1 ) | \
			tee ${ARTIFACT_DIR}/buildlog | \
			grcat "${GRCAT_FILE}" \
		&& (
			echo -n "Build finished: "
			date
			echo
		)
		rm -f "${HOME}/.grc/${GRCAT_FILE}"
	else
		(build "-j${NJ}" "$@" 2>&1 ) | \
			tee ${ARTIFACT_DIR}/buildlog \
		&& (
			echo -n "Build finished: "
			date
			echo
		)
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
		tar -cf ${ANDROID_BUILD_TOP}/${ARTIFACT_DIR}/symbols.tar symbols
		mkdir -p ${ANDROID_BUILD_TOP}/images
		echo "Storing flashable images..."
		cp -dp * ${ANDROID_BUILD_TOP}/images
	)
	(
		echo "Compressing into filename build_artifacts/$(hostname)_${TS}.tar.gz..."
		cd build_artifacts
		tar -czf $(hostname)_${TS}.tar.gz $(hostname)_${TS}/
	)

	exit $?
fi

fi
