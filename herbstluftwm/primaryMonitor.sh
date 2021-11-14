#!/bin/bash

xrandrData=$(xrandr --query | grep "primary")
if [[ $xrandrData =~ (^[-[:alnum:]_]*).* ]]; then
    echo ${BASH_REMATCH[1]}
else
    >&2 echo "Don't know"
    exit 1
fi

