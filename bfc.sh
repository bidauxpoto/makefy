#/bin/bash -i 
# -i required to use history
set -e
set -o pipefail

MAKEFILE=rules.mk

usage()
{
cat << EOF
usage: $0 options MAKEFILE

This script take the last command in the hisotry and transform it in a bmake compatible rules, the append the string to the MAKEFILE [default rules.mk in the current directory].

OPTIONS:
   -h      Show this message
EOF
}

while getopts "h" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

shift $(($OPTIND - 1))
if [ ! -z $1 ]
then
	MAKEFILE=$1
fi

if [ -L $MAKEFILE ]; then
	MAKEFILE=`readlink -f $MAKEFILE`
fi

SWAP_FILE=`dirname $MAKEFILE`/.`basename $MAKEFILE`.swp
if [ -e $SWAP_FILE ]; then
	echo "ERROR: $MAKEFILE already open" >&2;
	exit 1;
fi;

history | tail -n 2 | head -n 1 | bmakefy >> $MAKEFILE
$EDITOR $MAKEFILE 
