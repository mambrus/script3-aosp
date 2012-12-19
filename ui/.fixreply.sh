# UI part of rg.fixreply.sh
# This is not even a script, stupid and can't exist alone. It is purely
# ment for beeing included.


function print_fixreply_help() {
	clear
			cat <<EOF
Usage: $FIXREPLYS_SH_INFO [options]

Fixes bad characters comming from adb.

Works on std-in/out

Options. Defautls within []:
  -h              This help

Example:
  $FIXREPLYS_SH_INFO

EOF
}
	while getopts p:df:x:t:w:Fc:h OPTION; do
		case $OPTION in
		h)
			print_fixreply_help $0
			exit 0
			;;
		?)
			echo "Syntax error:" 1>&2
			print_fixreply_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

