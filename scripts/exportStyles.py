from qgis.core import QgsApplication, QgsProject, QgsSldExportContext, QgsVectorLayer


QgsApplication.setPrefixPath("/usr/bin/qgis", True)
qgs = QgsApplication([], False)
qgs.initQgis()

# Load project ./dtk.qgs
project = QgsProject.instance()
project.read("dtk.qgs")

print(project.mapLayers())

# Load layers
contours_50 = project.mapLayersByName("CONTOURS_50")[0]
contours_10 = project.mapLayersByName("CONTOURS_10")[0]

if not contours_50.isValid():
    print("ERROR: 'Contours 50' Layer not loaded!")
    exit(1)

export_context = QgsSldExportContext()
export_context.exportFilePath = "./contours_50.sld"
contours_50.saveSldStyleV2(export_context)
