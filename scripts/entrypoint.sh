#!/bin/bash

# Export styles
python3 ./scripts/exportStyles.py -i ./dtk.qgs -o ./geoserver.d/workspaces/OpenDTK/styles/

# Check if styles export was successful
if [ $? -ne 0 ]; then
  echo "Error while exporting styles"
  exit 1
fi

# Exit if contours and slovenia exports already exist
if [ -d "./data/out/contours" ] && [ -d "./data/out/slovenia" ]; then
  echo "Contours and Slovenia exports already exist"
  exit 0
fi

# Remove data directory
rm -rf ./data

# Fetch data
./scripts/fetchRawLayers.sh -r ./data/orig

# Check if fetch was successful
if [ $? -ne 0 ]; then
  echo "Error while fetching data"
  exit 1
fi

# Convert OSM to OSM XML
echo -n "Converting OSM to OSM XML... "
osmconvert ./data/orig/slovenia-latest.osm.pbf --out-osm -o=./data/orig/slovenia-latest.osm
echo -e "Done\n"

# Check if conversion was successful
if [ $? -ne 0 ]; then
  echo "Error while converting OSM to OSM XML"
  exit 1
fi

rm -rf ./data/orig/slovenia-latest.osm.pbf

# Filter OSM XML
echo -n "Filtering OSM XML... "
osmfilter ./data/orig/slovenia-latest.osm --drop-version --drop-relations --drop-author >> ./data/orig/custom-slovenia-latest.osm
echo -e "Done\n"

# Check if filtering was successful
if [ $? -ne 0 ]; then
  echo "Error while filtering OSM XML"
  exit 1
fi

rm -rf ./data/orig/slovenia-latest.osm

# Export contours shapefiles
python3 ./scripts/exportContours.py -r -i ./data/orig/contours/ -o ./data/out/contours

# Check if export was successful
if [ $? -ne 0 ]; then
  echo "Error while exporting contours"
  exit 1
fi

# Export Slovenia shapefiles
./scripts/exportShp.sh -r ./data/orig/custom-slovenia-latest.osm ./data/out/slovenia/

# Check if export was successful
if [ $? -ne 0 ]; then
  echo "Error while exporting Slovenia shapefiles"
  exit 1
fi

rm -rf ./data/orig/
