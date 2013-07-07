#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/common.sh

echo "Project Configuration:"
echo "    Name:      ${cfg_name}"
echo "    Prefix:    ${cfg_prefix}"
echo "    Org:       ${cfg_org}"
echo "    Id (Beta): ${cfg_identifierbeta}"
echo "    Id (Live): ${cfg_identifierlive}"
echo ""

# Find project package in project root, assumes there's only one of each
old_project="$(ls -d ${cmn_root}/*.xcodeproj | head -1)"

# New name based on configuration setting
new_project="${cmn_root}/${cfg_name}.xcodeproj"

# Strip path, leaving only filename and extension
old_project_name="${old_project##*/}"
new_project_name="${new_project##*/}"

echo "Setting up projects and workspaces:"
echo "    Located project at: ${old_project}"

# Look for template workspace, then default Xcode workspace
default_workspace="${old_project}/project.xcworkspace"
template_workspace="$(ls -d ${cmn_root}/*.xcworkspace 2> /dev/null | head -1)"

# Prevent an error in case workspace was removed or not needed
for workspace in "${default_workspace}" "${template_workspace}"; do
    if [[ -d $workspace ]]; then
        echo "    Located workspace at: ${workspace}"

        if [[ "${old_project_name}" != "${new_project_name}" ]]; then
            echo "    Updating workspace entry ${old_project_name} to ${new_project_name}"

            contents="${workspace}/contents.xcworkspacedata"
            contents_tmp="${workspace}/tmp"

            # Replaces all instances of "Template.xcodeproj" with "MyProject.xcodeproj"
            sedeasy "${old_project_name}" "${new_project_name}" $contents > $contents_tmp

            mv $contents_tmp $contents
        fi
    fi
done

if [[ -d $template_workspace ]]; then
    new_workspace="${cmn_root}/${cfg_name}.xcworkspace"
    if [[ "${template_workspace}" != "${new_workspace}" ]]; then
        echo "    Renaming ${template_workspace} to ${new_workspace}"
        mv $template_workspace $new_workspace
    fi
fi

if [[ "${old_project}" != "${new_project}" ]]; then
    echo "    Renaming ${old_project} to ${new_project}"
    mv $old_project $new_project
fi

echo ""

# Looks for a source file whose name contains AppDelegate, e.g., /User/.../Template/GSAppDelegate.m
appdelegate="$(ls -d ${cmn_sources}/*AppDelegate* 2> /dev/null | head -1)"

if ! [[ -f $appdelegate ]]; then
    echo "Error: Couldn't locate AppDelegate file in sources directory."
    exit 1
fi

# Strip path, leaving only filename and extension, e.g., GSAppDelegate.m
appdelegate_file="${appdelegate##*/}"

# Strip everything except for the current prefix, e.g., GS
old_prefix="$(echo ${appdelegate_file} | sed -e s/AppDelegate.*//g)"

echo "Located application delegate file: ${appdelegate_file}"
echo "Assuming current prefix: ${old_prefix}"
echo ""

if [[ "${old_prefix}" != "${cfg_prefix}" ]]; then
    echo "Renaming prefixed files:"

    # Loop over all project files that start with the current prefix, e.g., /User/.../Template/GSSourceFile.h
    for path in $(find $cmn_root -type f -name ${old_prefix}*); do
        echo "    Processing: ${path}"

        # Strip path, leaving only filename and extension, e.g., GSSourceFile.h
        old_file="${path##*/}"

        # Strip extension, e.g., GSSourceFile
        old_name="${old_file%.*}"

        # Replace current prefix with new prefix, e.g., PPSourceFile
        new_name="$(echo ${old_name} | sedeasy ^${old_prefix} ${cfg_prefix})"

        echo "        Replacing ${old_name} with ${new_name}"

        # Loop over all source or project files and replace mentions of this file/class
        for target in $(find $cmn_root -type f \( -name *.m -or -name *.h -or -name *.pch \)); do
            echo "        Replacing in: ${target}"
            target_tmp="${target}_tmp"

            # Replace text, e.g., GSSourceFile to PPSourceFile
            sedeasy "${old_name}" "${new_name}" $target > $target_tmp

            mv $target_tmp $target
        done

        # New filename, e.g., PPSourceFile.h
        new_file="$(echo ${old_file} | sedeasy ^${old_name} ${new_name})"

        # Replace file references in project file
        pbx="${new_project}/project.pbxproj"
        pbx_tmp="${new_project}/tmp"
        sedeasy "${old_file}" "${new_file}" $pbx > $pbx_tmp
        mv $pbx_tmp $pbx

        # Replace file name in path to the new file name
        new_path="$(echo ${path} | sedeasy ${old_file} ${new_file})"

        echo "        Renaming ${path} to ${new_path}"
        mv $path $new_path
    done

    echo ""
fi


pbx="${new_project}/project.pbxproj"
pbx_tmp="${new_project}/tmp"

echo "Updating settings in project: ${pbx}"

echo "    Prefix set to: ${cfg_prefix}"
sed -e "s/CLASSPREFIX = ${old_prefix};/CLASSPREFIX = ${cfg_prefix};/g" $pbx > $pbx_tmp

echo "    Organization set to: ${cfg_org}"
sed -e "s/ORGANIZATIONNAME = \".*\";/ORGANIZATIONNAME = \"${cfg_org}\";/g" $pbx_tmp > $pbx

rm $pbx_tmp

echo ""

source $cmn_scripts/env.sh live
