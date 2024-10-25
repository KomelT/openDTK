#!/bin/bash

print_help () {
    echo "Custom script for export Shapefiles from .osm."
    echo "Usage: exportShp.sh -[OPTIONS] <input_directory> <output_directory>"
    echo "  -h: Display this help message"
    echo "  -d: Check dependencies"
    echo "  -r: Remove existing data"
    echo "  -s: Skip if folder exists"
}

check_dependencies () {
    # Check if ogr2ogr is installed
    if ! [ -x "$(command -v ogr2ogr)" ]; then
        echo "Error: ogr2ogr is not installed." >&2
        exit 1
    fi
}

r=false
s=false
i=null
o=null

# Parse command line arguments
while getopts "hdrss:" flag; do
 case $flag in
    h)
        print_help
        exit 0
    ;;
    d)
        check_dependencies
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

check_dependencies

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

# Remove existing data
if [ $r = true ]; then
    rm -rf $o
fi

# Create output directory
mkdir -p $o

ogr2ogr -f "ESRI Shapefile" $o $i -skipfailures