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

# Export contours shapefiles
python3 ./scripts/exportContours.py -r -i ./data/orig/contours/ -o ./data/out/contours

# Check if export was successful
if [ $? -ne 0 ]; then
  echo "Error while exporting contours"
  exit 1
fi

# Export Slovenia shapefiles
./scripts/exportShp.sh -r ./data/orig/slovenia-latest.osm.pbf ./data/out/slovenia/

# Check if export was successful
if [ $? -ne 0 ]; then
  echo "Error while exporting Slovenia shapefiles"
  exit 1
fi
