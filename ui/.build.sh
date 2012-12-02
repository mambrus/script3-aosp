# UI part of grit.build.sh
# This is not even a script, stupid and can't exist alone. It is purely
# ment for beeing included.

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
  -x		Ignore to tar your finished output
  -a <dir>	Artifact directory.
  -V		Verbose. I.e. showcommands is passed to make which is a special target
  		to the AOSP build system
  --		Stop parsing flags for this script. Everything to the right
  		belongs to make.
  -h		Shows this help. Only flag that overides make flags.

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
	while getopts xa:Vh OPTION; do
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
		V)
			EXTRA_MAKE_CMDLINE="${EXTRA_MAKE_CMDLINE} showcommands"
			;;
# Note, this section is omitted on purpose. It needs to be to be able to pass
# flags to make
		?)
			echo "Syntax error:" 1>&2
			print_build_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

	ARTIFACT_MAIN_DIR=${ARTIFACT_MAIN_DIR-"build_artifacts"}

	IS_ATTY="yes"
	tty -s ||  IS_ATTY="no"
	if [ "X${IS_ATTY}" == "Xno" ]; then
		INPUT_FILE="-"
	fi

