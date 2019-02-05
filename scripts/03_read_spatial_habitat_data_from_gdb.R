#Read GIS habitat map file

#Libraries
library(rgdal)


# Read geodatabase from network, it it fails read a preprocessed file (a back-up copy that should not be changed unless certain that it is working)
#status: the current network file specified is the full file - this will have to be changed to a directory where the latest preprocessed file is saved.
source(file = "./functions/read_gis_hab_lr_fn.R")

# calls the function which will read the habitat file.
hab.map <- read.network.geodatabase() 

####ONLY RUN BELOW FOR TEST SMALL TEST FILE
#smaller test map
#hab.map <- readOGR(dsn = "\\\\SAMVW3-GIREP02\\NEWorkingData\\GIS_Working_Data\\Marine\\Phil_Haupt\\Fishing_effort_displacement\\2_Data\\1_QGIS\\test_habmap_for_R.gpkg", layer = "test_habmap_for_R")
#hab.map <- readOGR(dsn = "C:\\Users\\M996613\\Phil\\PROJECTS\\Fishing_effort_displacement\\2_subprojects_and_data\\2_GIS_DATA\\tmp_test\\test_habmap_for_R.gpkg", layer = "test_habmap_for_R")
#hab.map$SubReg_id <- "3a"