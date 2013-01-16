# UI part of rg.restore.sh
# This is not even a script, stupid and can't exist alone. It is purely
# ment for beeing included.


function print_restore_help() {
	clear
			cat <<EOF
Usage: $RESTORE_SH_INFO [options]

Fixes bad characters comming from adb.

Works on std-in/out

Options. Defautls within []:
  -h              This help

Example:
  $RESTORE_SH_INFO

EOF
}
	while getopts h OPTION; do
		case $OPTION in
		h)
			print_restore_help $0
			exit 0
			;;
		?)
			echo "Syntax error:" 1>&2
			print_restore_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

