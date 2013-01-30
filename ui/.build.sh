# UI part of rg.build.sh
# This is not even a script, stupid and can't exist alone. It is purely
# ment for beeing included.

DEF_ARTIFACT_DIR="./build_artifacts"

function print_build_help() {
	cat <<EOF
Usage: $BUILD_SH_INFO [special_options] [make_options] [targets] [env_var]

This script is used for building AOSP sources. It calls make, but also does
other stuff for you like colorizing output & create packages with symbos and
frozen manifests for you. It has only a limited set op options as most options
must be reserved for make. These options are called special_options above.

More info about the AOSP build-system:
http://elinux.org/Android_Build_System

Environment variables:
A whole chapter can be written about this, as a rule of thumb this is the safest
way: http://www.gnu.org/software/make/manual/html_node/Environment.html

However, a special form understood by make are environment variables given on the
command-line. These *must* have an assignement operator, or they will be treated
as targets.

Special options:
  -x        Ignore to tar your finished output
  -a <dir>  Artifact directory. Default dir is [${DEF_ARTIFACT_DIR}]
  -V        Verbose. I.e. showcommands is passed to make which is a special target
            to the AOSP build system.
  -z        Compress binaries and symbols into one .tar.gz file and place in
            artifact directory, see -a flag. Default is "no"
  -j <nr>   Same as the -j flag in gmake. Used to override the automatically
            calculated optimal value and must be used here (i.e. shouldn't be
            passed as a parameter to make or make vill get the same flag
            twice)
  --        Stop parsing flags for this script. Everything to the right
            belongs to make.
  -h        Shows this help. Only flag that overides make flags.

Example:
  $BUILD_SH_INFO -x
  # Build with 'showcommands'

  $BUILD_SH_INFO -x -a mybuilds -- -w kernel libdir=mydir
  # Builds the AOSP build-target "kernel" printing directories as we go and
  # assigning the environment variable libdir, which becomes a make variable, the
  # value "mydir".

  $BUILD_SH_INFO OUT_DIR=new_out


EOF
}
	while getopts xa:zVhj: OPTION; do
		case $OPTION in
		h)
			clear
			print_build_help $0
			exit 0
			;;
		x)
			AOSP_BUILD_SURPRESS_FULL="yes"
			;;
		a)
			ARTIFACT_MAIN_DIR=$OPTARG
			;;
		j)
			NJ=$OPTARG
			;;
		z)
			SURPRESS_COMPRESS_AND_TIDY="yes"
			;;
		V)
			EXTRA_MAKE_CMDLINE="${EXTRA_MAKE_CMDLINE} showcommands"
			;;
		?)
			echo "Syntax error:" 1>&2
			print_build_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

	ARTIFACT_MAIN_DIR=${ARTIFACT_MAIN_DIR-${DEF_ARTIFACT_DIR}}
	AOSP_BUILD_SURPRESS_FULL=${AOSP_BUILD_SURPRESS_FULL-"no"}
	SURPRESS_COMPRESS_AND_TIDY=${SURPRESS_COMPRESS_AND_TIDY-"no"}
	NJ=${NJ-""}

	IS_ATTY="yes"
	tty -s ||  IS_ATTY="no"
	if [ "X${IS_ATTY}" == "Xno" ]; then
		INPUT_FILE="-"
	fi

	unset DEF_ARTIFACT_DIR

