#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/config.sh

#
# Layout
#

cmn_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cmn_sources="${cmn_root}/Sources"
cmn_resources="${cmn_root}/Resources"
cmn_scripts="${cmn_root}/Scripts"
cmn_tests="${cmn_root}/Tests"
cmn_libraries="${cmn_root}/Libraries"

cmn_plist="${cmn_resources}/Info.plist"


#
# Utils
#

function sedeasy {
    sed -e "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

