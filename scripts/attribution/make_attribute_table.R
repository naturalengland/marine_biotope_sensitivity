# Layer attribution
# Obtain the infomration of each Activity Pressure combintation to supply the layer attribution file: This is a file that describes what goes into each column in the data

# Libraries
## Below the list of R libraries to load into R (in sequence). If they are not already installed on your machine you will have to do so first. This can be done using the command like install.packages("RODBC"), for each of the libraries. Then load them by running the commands below.
library(RODBC) # allows connecting to databases
library(DBI) # allows connecting to databases
library(tidyverse) # data wrangling scripts
library(plyr) # more data wrangling scripts

# Variables from Main script - used as input to decide which GI file to read:

# Database: Senstivity assessments
## Define Path to Access database on Power pc specified below
db.path <- "D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO.accdb"
drv.path <- "Microsoft Access Driver (*.mdb, *.accdb)" #"this relies on the driver specified above for installation, and will not work without it!

# 9. Below prints the list of options for the user to read, and then make a selection to enter below
source(file = "./functions/read_access_operations_and_activities.R")
OpsAct <- try(suppressWarnings(read.access.op.act())) #suppressWarnings(expr) turns warnigns off, as this warning will just tell you which data were not selected, and may be unneccessarily confusing.
if("try-error" %in% class(OpsAct)){print("Choice could not be set. Make sure your your Access Driver software is set-up correctly. Defaulting to 11. Fishing (Z10)")}
if(!"try-error" %in% class(OpsAct)){print(OpsAct)}
#see key below

# 10. NB! Choose an operation by selecting an OperationCode from the conservation advice database. Choose 1 - 18, and set the variable ops.choice to this.
#USER selection of operation code: Set the ops.number to which you are interested, e.g. ops.number <- 13
ops.number <- 11

# 11. Run this to save your choice, and see what was saved
source(file = "./functions/set_user_ops_act_choice.R")



# sbgr_filter <- FALSE
# waters <- "offshore" # has to be "inshore" or "offshore"
# final_output <- "outputs"
# driver.choice <- "GPKG"
# dsn_path_output <- paste0("/",final_output,"/",waters,"_habitat_sensitivity_")
# sens_layer_name_output <- "inshore_hab_sens_dredging_delete_test"
# 
# # read in the output GIS atribute table
# # sens_dat <- read_sf(dsn = paste0(dsn_path_output, ".GPKG", sep = ''), layer = sens_layer_name_output)
# sens_dat <- read_sf(dsn = "F:/projects/marine_biotope_sensitivity/outputs/habitat_sensitivity_fishing_mosaic_unfiltered.GKPG")


# Read in the Senstivity Assessments (MS Access table) with activities and pressures

# Load the function that reads the Access database
# ** This was added to error check  - line below - which overwrites the orignial function in the line above - remove if not happy
source(file = "./functions/read_access_db.R") # #beta version: removes the filters and adds two variables !

# Populate qryEUNIS_ActPressureSens using the read access function above, if it fails it will attempt to read a stored csv copy (note that this may not be the most up to date version)
qryEUNIS_ActPressSens <- try(read.access.db(db.path,drv.path))
if("try-error" %in% class(qryEUNIS_ActPressSens)) {
        qryEUNIS_ActPressSens <- read.csv("./input/qryEUNIS_ActPressSens.txt") # should find an older copy of the query for the fishing activity from the database to replaceC:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/qryhabsens
        cat(paste0("The R script that obtains the senstivity data appears was UNABLE to connect to the database from the specified file location ",db.path, ", in the user input section above."))
        cat("An older back-up copy stored as a text file was read in, and is limited to sensititivity to Fishing operations data only! The text file is:", (Sys.time() - file.info("./input/qryEUNIS_ActPressSens.txt")$mtime), "days old. Make sure you are using the latest version if you are updating formal outputs.")
}
if(class(qryEUNIS_ActPressSens) == "data.frame") {
        cat(paste0("The R script that obtains the senstivity data appears to have connected and read the senstivity data from the specified file location ",db.path, ", created: ", file.info(db.path)$ctime, ", selected according to the user input section above."))
        cat("The Access database file is:", (Sys.time() - file.info(db.path)$mtime), "days old. Make sure you are using the latest version if you are updating formal outputs.")
}

# ensure EUNISCode is a character, as it reads converts to factor (which is incorrectand cannot join to other objects)
qryEUNIS_ActPressSens$EUNISCode <- as.character(qryEUNIS_ActPressSens$EUNISCode) # ensure EUNIS codes are character not factors, as this will cause trouble when joining to other tables with a mismatch in the number of eunis codes
# rename SensPriority: When sens.act.rank was dropped by simply keeping this column, it no longer needed joining to the sensitivty table - but the old code used rank.value as the field name - and to keep it consistent 
qryEUNIS_ActPressSens <- qryEUNIS_ActPressSens %>% 
        dplyr::rename(rank.value = SensPriority) #this renaming is legacy issue from code developement: coudl be kept as SensPriority - but then needs to be checked and changed back to this throughout all code

# Make table of unique combinations of Activity and Pressure
activity_pressure_combs <- qryEUNIS_ActPressSens %>% dplyr::select(ActivityCode,
                                        ActivityName,
                                        PressureCode,
                                        PressureName) %>% 
        dplyr::distinct()

# Append the rest of characters to the codes to allow joining this table with a table of column names
source("./functions/name_column_fn.R")

# Establish a correlation between the GIS and SEnstivity Assessments names

   