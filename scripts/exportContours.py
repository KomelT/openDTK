import argparse
import os
from os.path import abspath
from qgis.core import (
    QgsApplication,
    QgsProject,
    QgsVectorLayer,
    QgsVectorFileWriter,
    QgsWkbTypes,
)


parser = argparse.ArgumentParser(
    prog="exportContours.py",
    description="This script merges and exports contours from input folder to output folder and separates them into 10 and 50 meters files",
)
parser.add_argument("-o", "--output", help="Output folder", required=True)
parser.add_argument("-i", "--input", help="Input folder", required=True)
parser.add_argument("-r", action="store_true", help="Removes output folder if exists")

args = parser.parse_args()

os.system(f"cd $(pwd)")

# Check if input folder exists
if not os.path.exists(args.input):
    print(f"ERROR: Input folder '{args.input}' does not exist!")
    exit(1)

# Remove output folder if exists
if args.r:
    print(f"INFO: Removing output folder '{args.output}'")
    os.system(f"rm -rf {args.output}")

# Create output folder
if not os.path.exists(args.output):
    os.makedirs(args.output)

output_folder = abspath(args.output)
input_folder = abspath(args.input)

QgsApplication.setPrefixPath("/usr/bin/qgis", True)
qgs = QgsApplication([], False)
qgs.initQgis()


# Init project
project = QgsProject.instance()

contours_east = QgsVectorLayer(
    f"{input_folder}/DTM_SLO_RELIEF_EL_PLASTNICE_VZHOD_L_line.shp",
    "contours_east",
    "ogr",
)
contours_west = QgsVectorLayer(
    f"{input_folder}/DTM_SLO_RELIEF_EL_PLASTNICE_ZAHOD_L_line.shp",
    "contours_west",
    "ogr",
)

if not contours_east.isValid():
    print("ERROR: 'Contours East' Layer not loaded!")
    exit(1)

print("INFO: 'Contours East' Layer loaded!")
QgsProject.instance().addMapLayer(contours_east)

if not contours_west.isValid():
    print("ERROR: 'Contours West' Layer not loaded!")

print("INFO: 'Contours West' Layer loaded!")
QgsProject.instance().addMapLayer(contours_west)


# Select contours every 50 meters
print("INFO: Selecting contours every 50 meters")
m50_exp = '"Z_PLAS" % 50 = 0'
contours_east.selectByExpression(m50_exp)
contours_west.selectByExpression(m50_exp)

# Create new layer
print("INFO: Creating new layer")
transform_context = QgsProject.instance().transformContext()
save_options = QgsVectorFileWriter.SaveVectorOptions()
save_options.driverName = "ESRI Shapefile"
save_options.fileEncodings = "UTF-8"

# Create new layer
writer = QgsVectorFileWriter.create(
    f"{output_folder}/contours_combined50.shp",
    contours_east.fields(),
    QgsWkbTypes.MultiLineString,
    contours_east.crs(),
    transform_context,
    save_options,
)


# Append selected features to new layer
print("INFO: Appending selected features to new layer")
if not writer.addFeatures(contours_east.selectedFeatures()):
    print("ERROR: East features not added")
    exit(1)

if not writer.addFeatures(contours_west.selectedFeatures()):
    print("ERROR: West features not added")
    exit(1)

del writer
print("INFO: 'Contours 50m' saved!")


# Select constours every 10 meters
print("INFO: Selecting contours every 10 meters")
m50_exp = '"Z_PLAS" % 10 = 0'
contours_east.selectByExpression(m50_exp)
contours_west.selectByExpression(m50_exp)

# Create new layer
print("INFO: Creating new layer")
transform_context = QgsProject.instance().transformContext()
save_options = QgsVectorFileWriter.SaveVectorOptions()
save_options.driverName = "ESRI Shapefile"
save_options.fileEncoding = "UTF-8"

# Create new layer
writer1 = QgsVectorFileWriter.create(
    f"{output_folder}/contours_combined10.shp",
    contours_east.fields(),
    QgsWkbTypes.MultiLineString,
    contours_east.crs(),
    transform_context,
    save_options,
)


# Append selected features to new layer
print("INFO: Appending selected features to new layer")
if not writer1.addFeatures(contours_east.selectedFeatures()):
    print("East features not added")
    exit(1)

if not writer1.addFeatures(contours_west.selectedFeatures()):
    print("ERROR: West features not added")
    exit(1)

del writer1
print("INFO: 'Contours 10m' saved!")

print("INFO: Exiting QGIS")
qgs.exitQgis()
