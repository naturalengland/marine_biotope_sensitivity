#Objective: Script to call main script, and rerun iterating through the list of operations
# NEED TO understand how the slots in S4 object work better e.g. hab_map@data is this one slot available for data, or are there multiple slots available which can be filled with data. the outcome will change whether we need to cycle hab_map@data

#clear workspace but leave the habitat map
#rm(list=setdiff(ls(), "hab.map")) #useful command to remove all but hte habitat map which takes long to read - useful during testing
#-----
# R libraries
## Below the list of R libraries to load into R (in sequence). If they are now already installed you will have to do so first. This can be done using the command like install.packages("RODBC"), for each of the libraries. Then load them as below.
library(RODBC)
library(DBI)
library(plyr)
library(tidyverse)
library(reshape2)
library(rgdal)
library(magrittr)
library(stringr)
library(sf)# to allow for multiple layers being written

# USER INPUT REQUIRED BELOW
#-----
# DEFINE THE FOLLOWING VARIABLES
## OR AT LEAST CHECK THAT THEY MAKE SENSE ACOCRDING TO YOUR COMPUTER CONFIGURATION!!!!

# User to specify the path to the file activiate the below and comment out the default paths
#db.path <- file.choose()
# e.g. laptop path
#db.path <- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/database/PD_AoO.accdb"
#power pc path
db.path <- "D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO.accdb"
drv.path <- "Microsoft Access Driver (*.mdb, *.accdb)" #"this relies on the driver specified above for isntallation, and will not work without it!

# USER: Provide a name for the temporary output folder. NOte that this is not permanent! files here will automatically be deleted! So do not name it the same as any folder which has valuable data in it.
folder <- "tmp_output/"

# Define variables: variable to group results by in script #11 - this should be the primary key in the gis habitat attribute file
group.by <- parse(text = "pkey") ## Set text = "ogc_fid" or any other unique identifier in the GIS file. It generates a field name taht is easy to cahnge - unique ID for polygons.

#  USER: Give the final output folder for GIS geopackage a name.
final_output <- "outputs"

#define variables
#dsn.path<- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/4_R/sensitivities_per_pressure/habitat_sensitivity_test.gpkg"#specify the domain server name (path and geodatabase name, including the extension)
dsn.path <- paste0(getwd(),"/",final_output,"/habitat_sensitivity.gpkg") # name of geopackage file in final output
driver.choice <- "GPKG" # TYPE OF GIS OUTPUT SET TO geopackage

#END OF INITIAL USER INPUT REQUIREMENT, you can now run scripts below to produce biotope sensitivity data.

# GIS file read in and working data set: these become variabel which you do not want to alter further, but can be used to provide new variabels with the data needed.
#-------------------------------
# Read GIS habitat map file

# Read geodatabase from network, it it fails read a preprocessed file (a back-up copy that should not be changed unless certain that it is working)
#status: the current network file specified is the full file - this will have to be changed to a directory where the latest preprocessed file is saved.
source(file = "./functions/read_gis_hab_lr_fn.R")

# calls the function which will read the habitat file. (This will take 10 minutes -  have a cup of tea)
hab_map <- read.network.geodatabase()  #temporarily disabled to avoid reading in the GIs file - remove the "#" to reactivate this cammand, and change top command rm...so taht the habitat map is removed ....

#------------------------------
# Clean geodata file; done from attribute table - i.e. remove the geomotry to make the file small and managable to work with.

#function that loads the GIs attributes from the GIs file (seperate it foreasier manipulation).Reads file from specified locality, or defaults to a back-up locality,
source(file = "./functions/load_gis_attributes_fn.R")
gis.attr <- load.gis.attrib()

# Cleans the HABTYPE column in the attribute, keeping on ly a single habitat type (not multiple within the same cell, as this cannot be assessed)
source(file = "./functions/clean_gis_attrib_habtype_fn.R")
hab.types <- gis.hab.bgr.dat(gis.attr)

#-------------------------------



#Below prints the list of options for the user to read, and then make a selection to enter below
#see key below
source(file = "./functions/read_access_operations_and_activities.R")
OpsAct <- read.access.op.act()
print(OpsAct)

# Choose an operation by selecting an OperationCode from the conservation advice database. Choose 1 - 14, and set the variable ops.choice to this.
#USER selection of operation code: Set the ops.number to which you are interested, e.g. ops.number <- 13
ops.number <- 11


#Run this to save your choice, and see what was saved
source(file = "./functions/set_user_ops_act_choice.R")


layer.name <- "fishing_ops" # name of layer being put




st_write(nc,     "nc.gpkg", "nc")
st_write(storms, "nc.gpkg", "storms", update = TRUE)

st_layers("nc.gpkg")

