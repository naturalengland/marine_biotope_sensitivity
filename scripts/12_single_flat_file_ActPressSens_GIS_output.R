#read geospatial and habitat data, join that to (activity-pressure-sensitivity per subbiogeoregion per polygon = "act.sbgr.bps.gis"), and 
# and write to geopackage
library(rgdal)
library(tidyverse)

#define variable
#name of output folder - default "output"
final_output <- "output"

#define variables
#dsn.path<- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/4_R/sensitivities_per_pressure/habitat_sensitivity_test.gpkg"#specify the domain server name (path and geodatabase name, including the extension)
dsn.path <- paste0(getwd(),"/",final_output,"/habitat_sensitivity_fishing.gpkg")
layer.name <- "sensitivity_fishing_ops"
driver.choice <- "GPKG"


# attach sensitivity results to the habitat map's geodatabase
hab.map@data <- cbind(hab.map@data, act.sbgr.bps.gis) 

# write the sensitivity data to the geodatabase/geopackage
writeOGR(hab.map, dsn = dsn.path, layer = layer.name, driver = driver.choice, overwrite_layer = TRUE)
