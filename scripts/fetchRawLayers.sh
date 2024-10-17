#!/bin/bash

print_help () {
    echo "Custom script for fetching raw contour lines and OSM data for Slovenia."
    echo "Usage: fetchRawLayers.sh -[OPTIONS] <output_directory>"
    echo "  -h: Display this help message"
    echo "  -r: Remove existing data"
    echo "  -s: Skip if folder exists"
    echo "  -c: Skip contour lines"
    echo "  -m: Skip OSM data"
}

r=false
s=false
c=false
m=false
o=null

# Parse command line arguments
while getopts "hrscmm:" flag; do
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
    c)
        c=true
    ;;
    m)
        m=true
    ;;
    \?)
        print_help
        exit 0
    ;;
 esac
done

# Get output directory
o=${@:$OPTIND:1}

# Check if output directory is specified
if [ "$o" = null ] || [ "$o" = "" ]; then
    echo "Error: Output directory not specified." >&2
    print_help
    exit 1
fi

# Change to user's working directory
cd $(pwd)

# Check output directory
ls $o &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Output directory does not exist." >&2
    exit 1
fi

# Check if osmfilter is installed
if ! [ -x "$(command -v osmfilter)" ]; then
    echo "Error: osmfilter is not installed." >&2
    echo "Install: wget -O - http://m.m.i24.cc/osmfilter.c |cc -x c - -O3 -o osmfilter" >&2
    exit 1
fi

# Check if wget is installed
if ! [ -x "$(command -v wget)" ]; then
    echo "Error: wget is not installed." >&2
    exit 1
fi

# Check if curl is installed
if ! [ -x "$(command -v curl)" ]; then
    echo "Error: curl is not installed." >&2
    exit 1
fi

# Check if jq is installed
if ! [ -x "$(command -v jq)" ]; then
    echo "Error: jq is not installed." >&2
    exit 1
fi

# Check if unzip is installed
if ! [ -x "$(command -v unzip)" ]; then
    echo "Error: unzip is not installed." >&2
    exit 1
fi




# Check if folder exists
if [ $s = true ]; then
    if [ -d $o ]; then
        echo "Error: Output directory already exists." >&2
        exit 1
    fi
fi

# Remove existing data
if [ $r = true ]; then
    rm -rf $o
fi

# Create output directory
mkdir -p $o

# Change to output directory
cd $o




# Check if contour lines should be downloaded
if [ "$c" == true ]; then
    echo "Skipping contour lines..."
else
    # Download contour data
    echo "Downloading contour data...  "

    # Extract link to zip file
    url=$(curl -s "https://ipi.eprostor.gov.si/jgp-service-api/display-views/groups/85/composite-products/346/file?filterParam=DRZAVA&filterValue=1" | jq -r '.url')

    # Download zip file
    wget $url -O ./DTM_SLO_RELIEF.zip

    if [ $? -ne 0 ]; then
        echo "Failed"
        exit 1
    fi
    echo -e "Done\n"

    # Extract plastnice data
    echo -n "Extracting plastnice data...  "
    unzip ./DTM_SLO_RELIEF.zip -d ./DTM_SLO_RELIEF
    unzip ./DTM_SLO_RELIEF/DTM_SLO_RELIEF_EL_PLASTNICE_VZHOD_L_* -d ./plastnice
    unzip ./DTM_SLO_RELIEF/DTM_SLO_RELIEF_EL_PLASTNICE_ZAHOD_L_* -d ./plastnice

    if [ $? -ne 0 ]; then
        echo "Failed"
        exit 1
    fi

    # Clean up
    rm -rf DTM_SLO_RELIEF DTM_SLO_RELIEF.zip
    echo -e "Done\n"
fi




# Check if OSM data should be downloaded
if [ "$m" == true ]; then
    echo "Skipping OSM data..."
else
    # Download OSM data
    echo "Downloading OSM data...  "
    wget https://download.geofabrik.de/europe/slovenia-latest.osm.pbf -O slovenia-latest.osm.pbf

    if [ $? -ne 0 ]; then
        echo "Failed"
        exit 1
    fi
    echo -e "Done\n"
fi