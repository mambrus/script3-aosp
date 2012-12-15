# UI part of rg.tzsample.sh
# This is not even a script, stupid and can't exist alone. It is purely
# ment for beeing included.

#some defaults
TZSAMPLE_SHELL_CMD="adb shell"
TZSAMPLE_PERIOD="500"
TZSAMPLE_DELIM=';'

function print_tzsample_help() {
	clear
			cat <<EOF
Usage: $TZSAMPLE_SH_INFO [options]

Prints /sys/class/thermal/thermal_zoneX/temp

This script will periodically poll thermal-zones and print it's temperature in
columns.

Note: to run ***the script MUST HAVE*** msleep in bash installed (for example:
'git clone git://github.com/coolaj86/msleep-commandline.git')

Note: that the script runs it's logic on host but it should equally well be able
to run on target. Just copy the script to target and use the -c option to avoid
using [${TZSAMPLE_SHELL_CMD}].

Options:
  -c <cmd>  Shell command. Default is [${TZSAMPLE_SHELL_CMD}].
            Note that this can be used to reach local host (sh) or a specific
            Android target.
  -t <ms>   Period-time in milliseconds. Default is [${TZSAMPLE_PERIOD}]ms
  -d <c>    Delimiter. Default is [${TZSAMPLE_DELIM}]
  -h        This help

Example:
  $TZSAMPLE_SH_INFO
  #Read temperatures from current adb target

  $TZSAMPLE_SH_INFO -c "" -p250
  #Read temparatures from localhost @ 4Hz

EOF
}
	while getopts hc:t:d: OPTION; do
		case $OPTION in
		h)
			print_tzsample_help $0
			exit 0
			;;
		c)
			SHELL_CMD=$OPTARG
			;;
		t)
			PERIOD=$OPTARG
			;;
		d)
			DELIM=$OPTARG
			;;
		?)
			echo "Syntax error:" 1>&2
			print_tzsample_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

	SHELL_CMD=${SHELL_CMD-"${TZSAMPLE_SHELL_CMD}"}
	PERIOD=${PERIOD-"${TZSAMPLE_PERIOD}"}
	DELIM=${DELIM-"${TZSAMPLE_DELIM}"}

	unset TZSAMPLE_SHELL_CMD
	unset TZSAMPLE_PERIOD
	unset TZSAMPLE_DELIM

	if [ "X$(which usleep)" == "X" ]; then
		echo "Command not found [msleep/usleep]:" 1>&2
		print_tzsample_help $0 1>&2
		exit 2
	fi

