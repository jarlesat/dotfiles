#!/bin/bash

DEBUG_FILE=${DEBUG_FILE:-"debug.log"}
if [[ -e $DEBUG_FILE ]]; then
    echo "
" >> "$DEBUG_FILE"
fi
echo "Invocation started $(date)" >> "$DEBUG_FILE"
bash -x $@ 2>> "$DEBUG_FILE"
echo "Invocation ended $(date)" >> "$DEBUG_FILE"

