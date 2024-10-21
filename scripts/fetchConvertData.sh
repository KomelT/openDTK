#!/bin/bash

rm -rf ./data

./scripts/fetchRawLayers.sh -r ./data/orig
python ./scripts/exportContours.py -i ./data/orig/contours/ -o ./data/out/contours -r