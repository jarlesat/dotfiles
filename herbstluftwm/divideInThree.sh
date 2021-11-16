#!/bin/bash

usage() {
    echo "Either --left, --right, --top or --bottom must be set."
}

hc() {
    herbstclient "$@"
}

cd "${BASH_SOURCE%/*}"

./debug.sh "$0 \"$@\""

. ./monitorGeometry.sh
. ./monitorHandler.sh


TEMP=`getopt -o lrtb -l left,right,top,bottom -- "$@"`

eval set -- "$TEMP"

while true; do
  case "$1" in
    -l|--left) LEFT=1 ; shift 1 ;;
    -r|--right) RIGHT=1 ; shift 1 ;;
    -t|--top) TOP=1 ; shift 1 ;;
    -b|--bottom) BOTTOM=1 ; shift 1 ;;

    -- ) shift ; break ;;
#    * ) printf "Args: '$1'" ; shift ;;
  esac
done
shift $(expr $OPTIND - 1)
monitorName="$1"

if [[ -z $monitorName ]]; then
    usage
    exit 1
fi

remove_virtual_monitors
geometry=$(extract_geometry "$1")
if [[ -n $LEFT ]]; then
    newMonitors=( $(divide_vertical "$geometry") )
    newMonitors=( ${newMonitors[1]} $(divide_horizontal "${newMonitors[0]}" ) )
elif [[ -n $TOP ]]; then
    newMonitors=( $(divide_horizontal "$geometry") )
    newMonitors=( ${newMonitors[1]} $(divide_vertical "${newMonitors[0]}" ) )
elif [[ -n $RIGHT ]]; then
    newMonitors=( $(divide_vertical "$geometry") )
    newMonitors=( ${newMonitors[0]} $(divide_horizontal "${newMonitors[1]}" ) )
elif [[ -n $BOTTOM ]]; then
    newMonitors=( $(divide_horizontal "$geometry") )
    newMonitors=( ${newMonitors[0]} $(divide_vertical "${newMonitors[1]}" ) )
else
    usage
    exit 1
fi


echo "create_virtual_monitors '$monitorName' ${newMonitors[*]}"
create_virtual_monitors "$monitorName" ${newMonitors[*]}

