# UI part of rg.flist.sh
# This is not even a script, stupid and can't exist alone. It is purely
# ment for beeing included.

#some defaults
FLIST_SHELL_CMD="adb shell"
FLIST_DEFAULT_DEPTH=4


function print_flist_help() {
	#clear
			cat <<EOF
Usage: $FLIST_SH_INFO [options] <start_dir>

Prints a sorted file-list under <start_dir> directory you give and a certain
depth level down. Note that at the lead level, you cant see the difference
between files and differences.


Options. Defautls within []:
  -d <depth>      Depth [${FLIST_DEFAULT_DEPTH}]
  -c <cmd>        Shell command [${FLIST_SHELL_CMD}]
                  Use this to access a certain device ID
  -h              This help

Example:
  $FLIST_SH_INFO -d6 /sys

EOF
}
	while getopts d:c:h OPTION; do
		case $OPTION in
		h)
			print_flist_help $0
			exit 0
			;;
		d)
			DIR_DEPTH=$OPTARG
			;;
		c)
			SHELL_CMD=$OPTARG
			;;
		?)
			echo "Syntax error:" 1>&2
			print_flist_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

	DIR_DEPTH=${DIR_DEPTH-"${FLIST_DEFAULT_DEPTH}"}
	SHELL_CMD=${SHELL_CMD-"${FLIST_SHELL_CMD}"}

 	unset FLIST_DEFAULT_DEPTH
 	unset FLIST_SHELL_CMD

	if [ $# != 1 ]; then
		echo "Syntax error: ${FLIST_SH_INFO}"\
			"takes exactly one argument" 1>&2
		print_flist_help $0 1>&2
		exit 2
	fi

	START_DIR=$1
