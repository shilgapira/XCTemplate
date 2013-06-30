#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/common.sh

case "$1" in
    "beta")
        identifier="${cfg_identifierbeta}"
        directory="${cmn_scripts}/Files/Beta"
        ;;
    "live")
        identifier="${cfg_identifierlive}"
        directory="${cmn_scripts}/Files/Live"
        ;;
    *)
        echo "Usage: env ( beta | live)     : Configure project for beta or live build"
        exit
        ;;
esac

echo "Updating info.plist: ${cmn_plist}"

echo "    Setting bundle identifier: ${identifier}"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${identifier}" $cmn_plist

echo "    Copying files from: ${directory}"
cp -R $directory/ $cmn_root

echo ""

version="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ${cmn_plist})"
build="$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ${cmn_plist})"

summary="${cfg_name}, $1 build, version ${version} (${build})"

echo "Summary: ${summary}"

#  >_>
# echo "${summary}" | say -vz &
