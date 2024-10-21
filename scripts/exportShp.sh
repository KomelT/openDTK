#!/bin/bash

print_help () {
    echo "Custom script for fetching raw contour lines and OSM data for Slovenia."
    echo "Usage: fetchRawLayers.sh -[OPTIONS] <input_directory> <output_directory>"
    echo "  -h: Display this help message"
    echo "  -r: Remove existing data"
    echo "  -s: Skip if folder exists"
}

r=false
s=false
i=null
o=null

# Parse command line arguments
while getopts "hrss:" flag; do
 case $flag in
    h)
        print_help
        exit 0
    ;;
    r)
        r=true
    ;;
    s)
        s=true
    ;;
    \?)
        print_help
        exit 0
    ;;
 esac
done

read -ra paths <<<"${@:$OPTIND:2}"

# Get input directory
i=$(realpath "${paths[0]}")

# Get output directory
mkdir -p "${paths[1]}"
o=$(realpath "${paths[1]}")


# Check if input directory is specified
if [ "$i" = null ] || [ "$i" = "" ]; then
    echo "Error: Input directory not specified." >&2
    print_help
    exit 1
fi

# Check if output directory is specified
if [ "$o" = null ] || [ "$o" = "" ]; then
    echo "Error: Output directory not specified." >&2
    print_help
    exit 1
fi

# Check if ogr2ogr is installed
if ! [ -x "$(command -v ogr2ogr)" ]; then
    echo "Error: ogr2ogr is not installed." >&2
    exit 1
fi

# Remove existing data
if [ $r = true ]; then
    rm -rf $o
fi

# Create output directory
mkdir -p $o

ogr2ogr -f "ESRI Shapefile" $o $i -skipfailures