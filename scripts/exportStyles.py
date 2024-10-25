import argparse
import os
from os.path import abspath
from qgis.core import QgsApplication, QgsProject


def check_dependencies():
    QgsApplication.setPrefixPath("/usr/bin/qgis", True)
    qgs = QgsApplication([], False)
    qgs.initQgis()


parser = argparse.ArgumentParser(
    prog="exportStyles.py",
    description="This script exports styles from QGIS project to SLD files",
)
parser.add_argument("-o", "--output", help="Output folder", required=True)
parser.add_argument("-i", "--input", help="Qgis project file", required=True)
parser.add_argument("-r", action="store_true", help="Removes output folder if exists")
parser.add_argument("-d", action="store_true", help="Check dependencies")

args = parser.parse_args()

if args.d:
    check_dependencies()
    exit(0)

# Check if input folder exists
if not os.path.exists(args.input):
    print(f"ERROR: Input file '{args.input}' does not exist!")
    exit(1)

# Remove output folder if exists
if args.r:
    print(f"INFO: Removing output folder '{args.output}'")
    os.system(f"rm -rf {args.output}")

# Create output folder
if not os.path.exists(args.output):
    os.makedirs(args.output)

output_folder = abspath(args.output)
input_file = abspath(args.input)

# Init QGIS
QgsApplication.setPrefixPath("/usr/bin/qgis", True)
qgs = QgsApplication([], False)
qgs.initQgis()

# Load project
project = QgsProject.instance()
project.read(input_file)

# Load layers
contours_50 = project.mapLayersByName("CONTOURS_50")[0]
contours_10 = project.mapLayersByName("CONTOURS_10")[0]

errM50, err50 = contours_50.saveSldStyle(f"{output_folder}/contours_50.sld")
errM10, err10 = contours_10.saveSldStyle(f"{output_folder}/contours_10.sld")

if err50 != True:
    print(f"ERROR: Could not save style for contours_50: {errM50}")
    exit(1)

if err10 != True:
    print(f"ERROR: Could not save style for contours_10: {errM10}")
    exit(1)
