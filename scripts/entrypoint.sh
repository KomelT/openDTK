#!/bin/bash

# Check dependencies
python3 ./scripts/exportStyles.py -d
./scripts/fetchRawLayers.sh -d
python3 ./scripts/exportContours.py -d

# Check if osmconvert is installed
if ! command -v osmconvert &> /dev/null
then
    echo "osmconvert could not be found"
    exit 1
fi

# Check if osmfilter is installed
if ! command -v osmfilter &> /dev/null
then
    echo "osmfilter could not be found"
    exit 1
fi

# Check if osm2pgsql is installed
if ! command -v osm2pgsql &> /dev/null
then
    echo "osm2pgsql could not be found"
    exit 1
fi

# Check if shp2pgsql is installed
if ! command -v shp2pgsql &> /dev/null
then
    echo "shp2pgsql could not be found"
    exit 1
fi



# Export styles
python3 ./scripts/exportStyles.py -i ./dtk.qgs -o ./geoserver.d/workspaces/OpenDTK/styles/

# Check if styles export was successful
if [ $? -ne 0 ]; then
  echo "Error while exporting styles"
  exit 1
fi


# Fetch data
./scripts/fetchRawLayers.sh ./data/orig

# Check if fetch was successful
if [ $? -ne 0 ]; then
  echo "Error while fetching data"
  exit 1
fi


# Convert OSM to OSM XML
echo "Converting OSM to OSM XML... "
osmconvert ./data/orig/slovenia-latest.osm.pbf --out-osm -o=./data/orig/slovenia-latest.osm
echo -e "Done\n"

# Check if conversion was successful
if [ $? -ne 0 ]; then
  echo "Error while converting OSM to OSM XML"
  exit 1
fi

# Filter OSM XML
echo "Filtering OSM XML... "
osmfilter ./data/orig/slovenia-latest.osm --drop-version --drop-author --keep="landuse=forest" >> ./data/orig/custom-slovenia-latest.osm
echo -e "Done\n"

# Check if filtering was successful
if [ $? -ne 0 ]; then
  echo "Error while filtering OSM XML"
  exit 1
fi

# Export contours shapefiles
python3 ./scripts/exportContours.py -r -i ./data/orig/contours/ -o ./data/out/contours

# Check if export was successful
if [ $? -ne 0 ]; then
  echo "Error while exporting contours"
  exit 1
fi

# Upload OSM data to PostGIS
osm2pgsql -S ./scripts/compatible.lua -O flex -d postgresql://geoserver:geoserver@postgis:5432/geoserver ./data/orig/custom-slovenia-latest.osm

# Upload Contours to PostGIS
shp2pgsql -s 3794 ./data/out/contours/contours10.shp contours10 | psql -q -d postgresql://geoserver:geoserver@postgis:5432/geoserver
shp2pgsql -s 3794 ./data/out/contours/contours50.shp contours50 | psql -q -d postgresql://geoserver:geoserver@postgis:5432/geoserver
