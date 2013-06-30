#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/common.sh

if [[ "${MAGICK_HOME}" == "" ]]; then
    echo "ImageMagick required, ensure MAGICK_HOME is set."
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
        hue=$(( 0x$(echo -n "${cfg_name}" | openssl md5 | cut -c1-6) % 360 ))
        color="hsl(${hue},150,130)"
    fi

    echo "Generating placeholder assets with color: $color"

    # Size and name for each image
    function eachimage {
        $1 320  480  "Default.png"
        $1 640  960  "Default@2x.png"
        $1 640  1136 "Default-568h@2x.png"
        $1 1024 748  "Default-Landscape.png"
        $1 2048 1496 "Default-Landscape@2x.png"
        $1 768  1004 "Default-Portrait.png"
        $1 1536 2008 "Default-Portrait@2x.png"
        $1 512  512  "iTunesArtwork"
        $1 57   57   "Icon.png"
        $1 114  114  "Icon@2x.png"
        $1 72   72   "Icon-ipad.png"
        $1 144  144  "Icon-ipad@2x.png"
    }

    # Helper function to create an image
    function generatelive {
        echo "    Creating $3"
        convert -size $1x$2 xc:$color "png:${live}/$3"
    }

    # Create each image
    eachimage generatelive

    exit
fi

if [[ "$1" == "--beta" ]]; then
    # Create path for beta images
    mkdir -p $beta

    tag_base=$cmn_scripts/Files/beta_tag
    tag1="${tag_base}_1.png"
    tag2="${tag_base}_2.png"
    tag3="${tag_base}_3.png"
    tag4="${tag_base}_4.png"

    echo "Composing beta assets from images at $live"

    # Pick suitable tag and top margin value for each images
    composite -gravity northeast -geometry +0+20 $tag2 "${live}/Default.png" "${beta}/Default.png"
    composite -gravity northeast -geometry +0+40 $tag3 "${live}/Default@2x.png" "${beta}/Default@2x.png"
    composite -gravity northeast -geometry +0+40 $tag3 "${live}/Default-568h@2x.png" "${beta}/Default-568h@2x.png"
    composite -gravity northeast -geometry +0+20 $tag3 "${live}/Default-Landscape.png" "${beta}/Default-Landscape.png"
    composite -gravity northeast -geometry +0+40 $tag4 "${live}/Default-Landscape@2x.png" "${beta}/Default-Landscape@2x.png"
    composite -gravity northeast -geometry +0+20 $tag3 "${live}/Default-Portrait.png" "${beta}/Default-Portrait.png"
    composite -gravity northeast -geometry +0+40 $tag4 "${live}/Default-Portrait@2x.png" "${beta}/Default-Portrait@2x.png"
    composite -gravity northeast -geometry +0+0 $tag1 "${live}/Icon.png" "${beta}/Icon.png"
    composite -gravity northeast -geometry +0+0 $tag2 "${live}/Icon@2x.png" "${beta}/Icon@2x.png"
    composite -gravity northeast -geometry +0+0 $tag1 "${live}/Icon-ipad.png" "${beta}/Icon-ipad.png"
    composite -gravity northeast -geometry +0+0 $tag2 "${live}/Icon-ipad@2x.png" "${beta}/Icon-ipad@2x.png"
    composite -gravity northeast -geometry +0+0 $tag3 "png:${live}/iTunesArtwork" "png:${beta}/iTunesArtwork"

    exit
fi

echo "Usage: img --generate [color]     : Generate placeholder assets"
echo "       img --beta                 : Compose beta assets from live assets"
exit
