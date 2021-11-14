#!/bin/bash

. ./monitorGeometry.sh
. ./monitorHandler.sh

usage() {
    echo "Either --horizonal or --vertical must be set."
}

hc() {
    herbstclient "$@"
}


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
if [[ -n $VERTICAL ]]; then
    newMonitors=( $(divide_vertical "$geometry") )
elif [[ -n $HORIZONTAL ]]; then
    newMonitors=( $(divide_horizontal "$geometry") )
else
    usage
    exit 1
fi
echo "create_virtual_monitors '$monitorName' ${newMonitors[*]}"
create_virtual_monitors "$monitorName" ${newMonitors[*]}

