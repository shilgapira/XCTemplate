#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/common.sh

if [[ "$(which convert)" == "" ]]; then
    echo "ImageMagick required, ensure the convert utility is accessible via PATH."
    exit
fi

live=$cmn_scripts/Files/Live/Resources/Images
beta=$cmn_scripts/Files/Beta/Resources/Images

if [[ "$1" == "--generate" ]]; then
    # Create path for generated images
    mkdir -p $live

    # Use color from command line or generate one from project name
    color="$2"
    if [[ "$color" == "" ]]; then
        hash=$(echo -n "${cfg_name}" | openssl md5 | cut -c12-18)
        hue=$(( 0x$(echo "$hash" | cut -c1-3) % 360 ))
        sat=$(( 130 + (0x$(echo "$hash" | cut -c4-5) % 50) ))
        light=$(( 110 + (0x$(echo "$hash" | cut -c6-7) % 50) ))
        color="hsl($hue,$sat,$light)"
    fi

    echo "Generating placeholder assets for live builds:"
    echo "   Color:  $color"
    echo "   Folder: $live"
    echo ""

    # Size and name for each image
    function eachimage {
        $1 320  480  "Default.png"
        $1 640  960  "Default@2x.png"
        $1 640  1136 "Default-568h@2x.png"
        $1 1024 768  "Default-Landscape.png"
        $1 2048 1536 "Default-Landscape@2x.png"
        $1 768  1024 "Default-Portrait.png"
        $1 1536 2048 "Default-Portrait@2x.png"
        $1 512  512  "iTunesArtwork"
        $1 1024 1024 "iTunesArtwork@2x"
        $1 57   57   "Icon.png"
        $1 120  120  "Icon@2x.png"
        $1 76   76   "Icon-ipad.png"
        $1 152  152  "Icon-ipad@2x.png"
    }

    # Helper function to create an image
    function generatelive {
        echo "Creating $3"
        convert -size $1x$2 xc:$color "png:${live}/$3"
    }

    # Create each image
    eachimage generatelive

    echo ""
    echo "Done. Use the env script to copy assets to the project."

    exit
fi

if [[ "$1" == "--beta" ]]; then
    # Create path for beta images
    mkdir -p $beta

    tag_base=$cmn_scripts/Files/beta
    tag_normal="${tag_base}.png"
    tag_retina="${tag_base}@2x.png"

    echo "Composing beta assets from live assets:"
    echo "    Source: $live"
    echo "    Target: $beta"
    echo ""

    echo "Composing icons"
    composite -gravity northeast -geometry +0+0 $tag_normal "${live}/Icon.png" "${beta}/Icon.png"
    composite -gravity northeast -geometry +0+0 $tag_retina "${live}/Icon@2x.png" "${beta}/Icon@2x.png"
    composite -gravity northeast -geometry +0+0 $tag_normal "${live}/Icon-ipad.png" "${beta}/Icon-ipad.png"
    composite -gravity northeast -geometry +0+0 $tag_retina "${live}/Icon-ipad@2x.png" "${beta}/Icon-ipad@2x.png"

    echo "Copying images"
    cp "${live}"/{Default*,iTunesArtwork*} "${beta}"

    echo ""
    echo "Done. Use the env script to copy assets to the project."

    exit
fi

echo "Usage: img --generate [color]     : Generate placeholder assets"
echo "       img --beta                 : Compose beta assets from live assets"
exit
