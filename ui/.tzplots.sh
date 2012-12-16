# UI part of rg.tzplots.sh
# This is not even a script, stupid and can't exist alone. It is purely
# ment for beeing included.

#some defaults
TZPLOTS_PERIOD_SCS="1"
TZPLOTS_XGEOMETRY="600x350+0+0"
TZPLOTS_XWITDTH_SCS="60"
TZPLOTS_XOFFS_SCS="20.0"
TZPLOTS_XWIDTH_SCS="60.0"
TZPLOTS_SHELL_CMD="adb shell"


function print_tzplots_help() {
	#clear
			cat <<EOF
Usage: $TZPLOTS_SH_INFO [options]

Plopts thermal_zones and cpu frequencies.

Utilizes gluplot and feedgnuplot, the latter can be installed from source at

'git clone git://github.com/dkogan/feedgnuplot'

More details:
https://github.com/dkogan/feedgnuplot

Options. Defautls within []:
  -p <sec>        Replot period [${TZPLOTS_PERIOD_SCS}]s
  -x <geometry>   X-dispaly geometry string [${TZPLOTS_XGEOMETRY}]
  -t <ofs>        Relative timestamp offset [${TZPLOTS_XOFFS_SCS}]s
                  Trim this from kernel log from when first sample arrives
  -w <secs>       Sweep time (x-width) [${TZPLOTS_XWIDTH_SCS}]s
  -F              Frequency in Hz, default is %
  -f <file>       Save a copy the plot data in file when finished
  -c <cmd>        Shell command [${TZPLOTS_SHELL_CMD}]
                  Note that this can be used to reach local host (sh)
				  or a specific Android target.
  -h              This help

Example:
  $TZPLOTS_SH_INFO

EOF
}
	while getopts p:df:x:t:w:Fc:h OPTION; do
		case $OPTION in
		h)
			print_tzplots_help $0
			exit 0
			;;
		p)
			PERIOD_SCS=$OPTARG
			;;
		x)
			XGEOMETRY=$OPTARG
			;;
		t)
			XOFFS_SCS=$OPTARG
			;;
		w)
			XWIDTH_SCS=$OPTARG
			;;
		F)
			FRQ_HZ="yes"
			;;
		f)
			FILENAME=$OPTARG
			;;
		c)
			SHELL_CMD=$OPTARG
			;;
		d)
			DEBUG="yes"
			;;
		?)
			echo "Syntax error:" 1>&2
			print_tzplots_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

	PERIOD_SCS=${PERIOD_SCS-"${TZPLOTS_PERIOD_SCS}"}
	XGEOMETRY=${XGEOMETRY-"${TZPLOTS_XGEOMETRY}"}
	XWIDTH_SCS=${XWIDTH_SCS-"${TZPLOTS_XWITDTH_SCS}"}
	XOFFS_SCS=${XOFFS_SCS-"${TZPLOTS_XOFFS_SCS}"}
	FRQ_HZ=${FRQ_HZ-"no"}
	SHELL_CMD=${SHELL_CMD-"${TZPLOTS_SHELL_CMD}"}
	FILENAME=${FILENAME-""}
	DEBUG=${DEBUG-"no"}

 	unset TZPLOTS_PERIOD_SCS
 	unset TZPLOTS_XGEOMETRY
 	unset TZPLOTS_XWITDTH_SCS
 	unset TZPLOTS_XOFFS_SCS
 	unset TZPLOTS_XWIDTH_SCS
	unset TZPLOTS_SHELL_CMD

	if [ "X$(which gnuplot)" == "X" ]; then
		echo "Error: Gnuplot not installed:" 1>&2
		exit 2
	fi
	if [ "X$(which feedgnuplot)" == "X" ]; then
		echo "Error: Feedgnuplot not installed:" 1>&2
		delay 3
		print_tzsample_help $0 1>&2
		exit 2
	fi

	if [ "X$(echo $XOFFS_SCS | grep '.')" != "X${XOFFS_SCS}" ]; then
		XOFFS_SCS="${XOFFS_SCS}.0"
	fi
	if [ "X$(echo $XWIDTH_SCS | grep '.')" != "X${XWIDTH_SCS}" ]; then
		XWIDTH_SCS="${XWIDTH_SCS}.0"
	fi
