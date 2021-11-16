#!/bin/bash

usage() {
    echo "Either --horizonal or --vertical must be set."
}

hc() {
    herbstclient "$@"
}

cd "${BASH_SOURCE%/*}"

./debug.sh "$0 \"$@\""

. ./monitorGeometry.sh
. ./monitorHandler.sh

TEMP=`getopt -o hv -l horizontal,vertical -- "$@"`

eval set -- "$TEMP"

while true; do
  case "$1" in
    -h|--horizontal) HORIZONTAL=1 ; shift 1 ;;
    -v|--vertical) VERTICAL=1 ; shift 1 ;;

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
newMonitors=( $(divide_vertical "$geometry") )
newMonitors=( $(divide_horizontal "${newMonitors[0]}" ) $(divide_horizontal "${newMonitors[1]}" ) )

echo "create_virtual_monitors '$monitorName' ${newMonitors[*]}"
create_virtual_monitors "$monitorName" ${newMonitors[*]}

