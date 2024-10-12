#!/bin/bash

# Check if osmfilter is installed
if ! [ -x "$(command -v osmfilter)" ]; then
    echo "Error: osmfilter is not installed." >&2
    exit 1
fi

# Check if wget is installed
if ! [ -x "$(command -v wget)" ]; then
    echo "Error: wget is not installed." >&2
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

# Create data directory
mkdir -p data
cd data



# Check if ./plastnice directory exists
if [ -d "./plastnice" ]; then
    echo "Plastnice data already exists. Skipping download."
else
    # Download plastnice data
    echo "Downloading plastnice data...  "
    # extract link to zip file
    url=$(curl -s "https://ipi.eprostor.gov.si/jgp-service-api/display-views/groups/85/composite-products/346/file?filterParam=DRZAVA&filterValue=1" | jq -r '.url')
    # download zip file
    wget $url -O DTM_SLO_RELIEF.zip

    if [ $? -ne 0 ]; then
        echo "Failed"
        exit 1
    fi
    echo -e "Done\n"

    # Extract plastnice data
    echo -n "Extracting plastnice data...  "
    unzip DTM_SLO_RELIEF.zip -d ./DTM_SLO_RELIEF
    unzip ./DTM_SLO_RELIEF/DTM_SLO_RELIEF_EL_PLASTNICE\* -d ./plastnice

    if [ $? -ne 0 ]; then
        echo "Failed"
        exit 1
    fi

    rm -rf DTM_SLO_RELIEF DTM_SLO_RELIEF.zip
fi



# Check if ./slovenia-latest.osm exists
if [ -f "./slovenia-latest.osm" ]; then
    echo "OSM data already exists. Skipping download."
else
    # Download OSM data
    echo "Downloading OSM data...  "
    wget https://download.geofabrik.de/europe/slovenia-latest.osm.bz2 -O slovenia-latest.osm.bz2

    if [ $? -ne 0 ]; then
        echo "Failed"
        exit 1
    fi
    echo -e "Done\n"

    # Extract OSM data
    echo -n "Extracting OSM data...  "
    bzip2 -d slovenia-latest.osm.bz2

    if [ $? -ne 0 ]; then
        echo "Failed"
        exit 1
    fi
    echo -e "Done\n"
fi



# Define which OSM tags to keep
keep_aerialway="aerialway"
keep_amenity="amenity=grave_yard"
keep_barrier="barrier=cable_barrier =wall"
keep_building="building"
keep_highway="highway"
keep_historic="historic=wayside_cross =wayside_shrine"
keep_landuse="landuse=forest =forest =vineyard =cemetery"
keep_man_made="man_made=bridge =goods_conveyor"
keep_place="place"
keep_power="power"
keep_railway="railway=rail"
keep="$keep_aerialway $keep_amenity $keep_barrier $keep_building $keep_highway $keep_historic $keep_landuse $keep_man_made $keep_place $keep_power $keep_railway"

echo -n "Exporting OSM data...  "
osmfilter slovenia-latest.osm --keep="${keep}" --drop-version --drop-relations --drop-author > custom-slovenia-latest.osm
echo -e "Done\n"
