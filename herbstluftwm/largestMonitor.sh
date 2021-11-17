#!/bin/bash

monitors=()
while read m; do
    if [[ $m =~ (^[-[:alnum:]_]*)[^[:digit:]]*([[:digit:]]+)x([[:digit:]]+)\+[[:digit:]]+\+[[:digit:]]+ ]]; then
        size=$( expr ${BASH_REMATCH[2]} \* ${BASH_REMATCH[3]} )
        thisMonitor="$size,${BASH_REMATCH[1]}"
        monitors+=($thisMonitor)
    fi
done <<< $(xrandr --query | grep " connected")
if [[ ${#monitors[@]} -gt 1 ]]; then
    IFS=$'\n' monitors=($(sort -b -n -r -t , -k 1 <<<"${monitors[*]}")); unset IFS
fi
if [[ ${monitors[0]} =~ [[:digit:]]*,(.*) ]]; then
    echo ${BASH_REMATCH[1]}
else
    >&2 echo "Don't know"
    exit 1
fi

