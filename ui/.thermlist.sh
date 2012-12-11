# UI part of rg.thermlist.sh
# This is not even a script, stupid and can't exist alone. It is purely
# ment for beeing included.

#some defaults
THERMLIST_SHELL_CMD="adb shell"
THERMLIST_PERIOD="500"
THERMLIST_DELIM=';'

function print_thermlist_help() {
	clear
			cat <<EOF
Usage: $THERMLIST_SH_INFO [options]

Prints /sys/class/thermal/thermal_zoneX/temp

This script will periodically poll thermal-zones and print it's temperature in
columns.

Note: to run ***the script MUST HAVE*** msleep in bash installed (for example:
'git clone git://github.com/coolaj86/msleep-commandline.git')

Note: that the script runs it's logic on host but it should equally well be able
to run on target. Just copy the script to target and use the -c option to avoid
using [${THERMLIST_SHELL_CMD}].

Options:
  -c <cmd>  Shell command. Default is [${THERMLIST_SHELL_CMD}].
            Note that this can be used to reach local host (sh) or a specific
            Android target.
  -t <ms>   Period-time in milliseconds. Default is [${THERMLIST_PERIOD}]ms
  -d <c>    Delimiter. Default is [${THERMLIST_DELIM}]
  -h        This help

Example:
  $THERMLIST_SH_INFO
  #Read temperatures from current adb target

  $THERMLIST_SH_INFO -c "" -p250
  #Read temparatures from localhost @ 4Hz

EOF
}
	while getopts hc:t:d: OPTION; do
		case $OPTION in
		h)
			print_thermlist_help $0
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
			print_thermlist_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

	SHELL_CMD=${SHELL_CMD-"${THERMLIST_SHELL_CMD}"}
	PERIOD=${PERIOD-"${THERMLIST_PERIOD}"}
	DELIM=${DELIM-"${THERMLIST_DELIM}"}

	unset THERMLIST_SHELL_CMD
	unset THERMLIST_PERIOD
	unset THERMLIST_DELIM

	if [ "X$(which usleep)" == "X" ]; then
		echo "Command not found [msleep/usleep]:" 1>&2
		print_thermlist_help $0 1>&2
		exit 2
	fi

