#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/common.sh

case "$1" in
    "mit"|"xcode"|"none")
        type="$1"
        ;;
    *)
        echo "Usage: header ( mit | xcode | none )      : Set headers for all source files"
        exit
        ;;
esac

header="${cmn_scripts}/Files/header_${type}"
header_tmp="${header}_tmp"

# Loop over each source or test file
for file in $(find $cmn_root -type f \( -name *.m -or -name *.h \)); do

    # Count how many commented lines the file has at the top
    lines=0
    for i in $(cat $file | grep -n // | cut -c-4 | sed -e s/:.*//g); do
        if [[ $i != $(($lines + 1)) ]]; then
            break
        fi
        lines=$i
    done

    file_tmp="${file}_tmp"
    touch $file_tmp

    # Append new header to temp file if needed
    if [[ "$type" != "none" ]]; then
        filename=${file##*/}

        cat $header | sedeasy "__FILE__" "${filename}" | sedeasy "__YEAR__" "$(date +%Y)" | sedeasy "__ORGANIZATION__" "${cfg_org}" | sedeasy "__DATE__" "$(date +%d/%b/%Y)" | sedeasy "__AUTHOR__" "${cfg_author}" > $header_tmp

        cat $header_tmp >> $file_tmp
        rm $header_tmp
    fi

    # Append contents of file starting after last line of existing header
    start=$(($lines + 1))
    tail -n +$start $file >> $file_tmp

    mv $file_tmp $file
done
