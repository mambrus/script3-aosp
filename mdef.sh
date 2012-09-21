#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-09-20

if [ -z $MDEF_SH ]; then

MDEF_SH="mdef.sh"

# Lexer. Looks for start of varable asignement. Variable needs to start on
# begining of line to be considered valid.
AWK1='
	BEGIN{
		ingroup=0
		CNTR=1
		nextvalid=0
	}
	{
		if (!ingroup) {
			if (index($0,PATTERN) == 1){
				printf("%s;%d;",FNAME,CNTR);
				ingroup=1
				print $0
			
				nextvalid=0
				if (match($0,"\\\\[[:space:]]*$")){
					nextvalid=1
				} else {
					ingroup=0
					nextvalid=0
				}

			}
		} else {
			if (nextvalid) {
				#This is last iterations nextvalid
				print $0
			}
			nextvalid=0
			if (match($0,"\\\\[[:space:]]*$")){
				nextvalid=1
			} else {
				ingroup=0
				nextvalid=0
			}
		}
		CNTR++
	}
'

# No right hand value on same line. Add +1 to line number
AWK2='
	/^\./{
		#printf("\n####\n")
		printf("\n")
		if (match($0,"=[[:space:]]\\\\[[:space:]]*$")){
			print $1";"$2 + 1";"$3
		} else {
			print $0
		}
	}
	/^[[:space:]]/{
		print $0
	}
'

# Don't line-break if line ends with '\'
AWK3='
	{
		if (match($0,"\\\\[[:space:]]*$")){
			printf("%s",$0);
		} else
			print $0
	}
'

function mdef() {
	FS=$(src.mgrep.sh ${1} | cut -f1 -d":" | sort -u)
	for F in $FS
	do
		cat $F | \
			awk -vFNAME=${F} -vPATTERN=${1} "${AWK1}" | \
			awk -F";" "${AWK2}" | \
			awk "${AWK3}" | \
			sed -e 's/\\//g' | \
			sed -e 's/[[:space:]]\+/ /g' | \
			sed -e 's/[[:space:]]\+$//' | \
			awk '/[[:graph:]]/{print $0}'

#sed -ne '/[[:graph:]]/p'
#			sed -e '/^[[:space:]]*$/d' 
	done
}


source s3.ebasename.sh
source src.xgrep.sh
if [ "$MDEF_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	#mdef PRODUCT_PACKAGES
	mdef "$@"

	exit $?
fi

fi
