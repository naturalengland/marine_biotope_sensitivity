# Project Title: Biotope sensitivity

# Objective:
# Author: Philip Haupt
# Date: 2018-08-28 to 2018-11-28

# Script name: Main script
## This is the main script which runs the support functions, sequentially, making objects available to coming/sequential functions. I.e. The user should only have to run this script

# Script source pages:
## The scripts are based in a GITHUB repository: https://github.com/naturalengland/biotope-sensitivity
## In the case of serious problems contact Philip.Haupt@naturalengland.org.uk

# Important information:
## Read the System requirements to make sure that you have the require software and data installed to run this R script (below)
## When you are sure it is correctly configured, press "Alt Cntrl R" to run the entire script. It will take a while as it has to millions and millions of calculations
## The final product is a geopackage (open source GIS file) which should be in a directory called "output" in your working directory.
## Your working directory can be seen by typing "getwd()"

# Project directory requirements
## Within the working directory "> getwd()" ensure that there is a directory called "scripts" with R scripts in it, "functions" with R files, and "outputs" which may or may not be empty
## Make sure to look at and complete the list of variables that the user HAS to DEFINE, or it maky not work if your system configuration is different (e.g. the database is housed in a new directory) at the time of writing.

#------
# System requirements
# R v3.5.1 was used to construct the code, but may work with earlier version such as 3.3.3
# Install a microsoft access driver if not already on PC/machine, available from e.g. https://www.microsoft.com/en-us/download/details.aspx?id=54920
# The driver version (64/32) has to match the system and R version 64 bit or 32 bit
# QGIS or equivalne to view the final product in the output folder when complete

#------
# Notes 
## Biotopes which have been assessed for sensitivity in the conservation Advice database only include Eunis levels 4 to 6 at this stage.
## Issues: currently only a local copy of the MS Access database is available on my working hard drive, and this needs to be pointed at the network (eventually) when approved

# START
#clear workspace
#rm(list = ls()) # this will remove all objects inthe R environment. Run this to ensure a clean start.
rm(list=setdiff(ls(), "hab_map")) #useful command to remove all but hte habitat map which takes long to read - useful during testing
#-----
# R libraries
## Below the list of R libraries to load into R (in sequence). If they are now already installed you will have to do so first. This can be done using the command like install.packages("RODBC"), for each of the libraries. Then load them as below.
library(RODBC)
library(DBI)
library(tidyverse)
library(plyr)
library(reshape2)
library(rgdal)
library(magrittr)
library(stringr)
library(sf)# to allow for multiple layers being written

# USER INPUT REQUIRED BELOW
#-----

## DEFINE THE FOLLOWING VARIABLES OR AT LEAST CHECK THAT THEY MAKE SENSE ACOCRDING TO YOUR COMPUTER CONFIGURATION!!!!

# User to specify the path to the file activiate the below and comment out the default paths
db.path <- file.choose()
# e.g. laptop path
#db.path <- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/database/PD_AoO.accdb"
#power pc path
#db.path <- "D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO.accdb"
drv.path <- "Microsoft Access Driver (*.mdb, *.accdb)" #"this relies on the driver specified above for installation, and will not work without it!

# USER: Provide a name for the temporary output folder. NOte that this is not permanent! files here will automatically be deleted! So do not name it the same as any folder which has valuable data in it.
folder <- "tmp_output/"

# Define variables: variable to group results by in script #11 - this should be the primary key in the gis habitat attribute file
group.by <- parse(text = "pkey") ## Set text = "ogc_fid" or any other unique identifier in the GIS file. It generates a field name taht is easy to cahnge - unique ID for polygons.

#  USER: Give the final output folder for GIS geopackage a name.
final_output <- "outputs"

#define variables
#dsn.path<- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/4_R/sensitivities_per_pressure/habitat_sensitivity_test.gpkg"#specify the domain server name (path and geodatabase name, including the extension)
dsn.path <- paste0(getwd(),"/",final_output,"/habitat_sensitivity_renewables") # name of geopackage file in final output
driver.choice <- "GPKG" # TYPE OF GIS OUTPUT SET TO geopackage
layer.name <- "renewables_ops" # name of layer being put

#Below prints the list of options for the user to read, and then make a selection to enter below
#see key below
source(file = "./functions/read_access_operations_and_activities.R")
OpsAct <- read.access.op.act()
print(OpsAct)

# Choose an operation by selecting an OperationCode from the conservation advice database. Choose 1 - 18, and set the variable ops.choice to this.
#USER selection of operation code: Set the ops.number to which you are interested, e.g. ops.number <- 13
ops.number <- 10


# Run this to save your choice, and see what was saved
source(file = "./functions/set_user_ops_act_choice.R")

# END OF USER INPUT REQUIREMENT, you can now run scripts below to produce biotope sensitivity data.


#---------------------------------
# 01_connect_to_access_db.R

# Load the function that reads the Access database
source(file = "./functions/01_connect_to_ms_access_qry_data.R")

# Populate qryEUNIS_ActPressureSens using the read access function above, if it fails it will attempt to read a stored csv copy (note that this may not be the most up to date version)
qryEUNIS_ActPressSens <- try(read.access.db(db.path,drv.path)) 
if("try-error" %in% class(read.access.db(db.path,drv.path))) {
        qryEUNIS_ActPressSens <- read.csv("C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/qryhabsens/qryEUNIS_ActPressSens.txt")
}

# ensure EUNISCode is a character, as it reads converts to factor (which is incorrectand caannot join to other objects)
qryEUNIS_ActPressSens$EUNISCode <- as.character(qryEUNIS_ActPressSens$EUNISCode) 
# qryEUNIS_ActPressSens <- as.character(qryEUNIS_ActPressSens$ActSensRank)


#--------------------------------
#02
#List of sensitivity_per_pressure for each assessed EUNIS code (biotopes/fine-scale assessed habitat codes from Access database)

# add ranking of sensitivity to access database-object
source("./functions/sensitivity_rank_tbl.R")
sens.act.rank <- left_join(qryEUNIS_ActPressSens,sens.rank, by = "ActSensRank")
sens.act.rank$EUNISCode <- as.character(sens.act.rank$EUNISCode)# ensure EUNIS codes are character not factors!

# Obtain a table of the distinct EUNIS codes for which sensitivity data exists; this table will be used in joins to ensure that each EUNIs code gets checked against the Pressure Sensitivity assessments
eunis.lvl.assessed <- sens.act.rank %>% 
        select(EUNISCode) %>% 
        distinct()
eunis.lvl.assessed$EUNISCode <- as.character(eunis.lvl.assessed$EUNISCode) # ensure EUNIS codes are character not factors!


# Obtain sensitvity tables, one for each acitivty, with each EUNIS code assessed against each pressure code: 
# a list of data frames called "act.press.list" is created, which contains the unique combinations of ranked sensivities to pressure for each activity for each of the assessed biotope (i.e. from the Access database)
source(file = "./functions/unique_combs_sens_per_press_per_eunis_fn.R")

# housekeeping: remove the initial database query, and keep only the last R object
rm(qryEUNIS_ActPressSens, sens.rank)

#-------------------------------
# 03 Read GIS habitat map file

# Read geodatabase from network, it it fails read a preprocessed file (a back-up copy that should not be changed unless certain that it is working)
# status: the current network file specified is the full file - this will have to be changed to a directory where the latest preprocessed file is saved.
source(file = "./functions/read_gis_hab_lr_fn.R")

# calls the function which will read the habitat file. (This will take 10 minutes -  have a cup of tea)
hab_map <- read.network.geodatabase()  #temporarily disabled to avoid reading in the GIs file - remove the "#" to reactivate this cammand, and change top command rm...so taht the habitat map is removed ....
# TO CHANGE USING read_st(dsn = "", layer = "") as only data frame is needed at the start.

#------------------------------
#04
#Clean geodata file; done from attribute table - i.e. remove the geomotry to make the file small and managable to work with.

#function that loads the GIs attributes from the GIs file (seperate it foreasier manipulation).Reads file from specified locality, or defaults to a back-up locality,
source(file = "./functions/load_gis_attributes_fn.R")
gis.attr <- load.gis.attrib()

# Cleans the HABTYPE column in the attribute, keeping on ly a single habitat type (not multiple within the same cell, as this cannot be assessed)
source(file = "./functions/clean_gis_attrib_habtype_fn.R")
hab.types <- gis.hab.bgr.dat(gis.attr)

#-------------------------------
#05 
# Assign EUNIS levels based on number of characters in EUNISCode
#EUNIS level
eunis.lvl.assessed$level <- nchar(as.character(eunis.lvl.assessed$EUNISCode), type = "chars", allowNA = T, keepNA = T)-1 # THIS NEEDS TO BE + 1

#specify he function to run: columns of levels with Eunis codes under themn]
source(file = "./functions/eunis_code_per_level_fn.R")

#specify temporary variable into which the data is tored before being bound to EunisAssessed
ind.eunis.lvl.tmp <- eunis.levels()
#bind data into a singel dataframe
EunisAssessed <- cbind(eunis.lvl.assessed, ind.eunis.lvl.tmp)
#assign names to columns in the dataframe
names(EunisAssessed) <- c(names(eunis.lvl.assessed), names(ind.eunis.lvl.tmp))
#housekeeping, remove unused object
rm(ind.eunis.lvl.tmp)

#----------------------------
#06
source("./functions/match_eunis_to_biotope_fn.R") # load function that will match the biotopes
# THIS NEEDS TO BE FUNCTIONALISED: but currenbtly runs as a long section of code

# input data

# SPATIAL data for join (y):
# y - from spatial data; all possible EUNIS codes per BGR
# in order to do so, define the EUNIS level of the hab.1 column
eunis.lvl.less.2 <- nchar(as.character(hab.types$hab.1), type = "chars", allowNA = T, keepNA = T)
eunis.lvl.more.2 <- nchar(as.character(hab.types$hab.1), type = "chars", allowNA = T, keepNA = T)-1
hab.types$level <- ifelse(nchar(as.character(hab.types$hab.1), type = "chars", allowNA = T, keepNA = T) > 2, eunis.lvl.more.2, eunis.lvl.less.2) #only using the first stated habitat, could be made to include others later on
rm(eunis.lvl.less.2, eunis.lvl.more.2) # housekeeping remove temporary vars


# Define (unique) benthic habitats to allow the join between the GIS spatial mapped data and the sensitivity assessments (by EUNIS codes)
distinct.mapped.habt.types <- hab.types %>%
        distinct(hab.1,bgr_subreg_id, level) %>% drop_na() # hab.1 contains the worked/processed HAB_TYPE data (1st column)

#generate multiple dataframes in a list, for the various habitat types within subBGRs, per hab level. this holds the gis data used to generate cross tabulated data matrices in the "match_eunis_to_biotope_fn"
bgr.dfs.lst <- split(distinct.mapped.habt.types, distinct.mapped.habt.types$bgr_subreg_id)


# All EUNIS Biotopes that have been assessed 
#this list of data tables holds the assessed level data from the Access database - all habitats assessed per habitat level. this will be used with the above to generate the cross tabulate matrices in the "match_eunis_to_biotope_fn"
x.dfs.lst <- split(EunisAssessed,f = EunisAssessed$level)

level.result.tbl <- vector("list", length(x.dfs.lst))
names(level.result.tbl) <- paste0("h.lvl_",names(x.dfs.lst))

#Genreate a diroctory save temporary output files into
mainDir <- getwd()#"C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/4_R/sensitivities_per_pressure"
subDir <- "tmp_output/"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)
setwd(file.path(mainDir, subDir))

# below is a for loop in which the EUNIsAssessed is split into a list of dataframes 1st being the most detailed biotope level (6), and then down to the broadest biotope level (4) that were assessed in the PD_AoO access database: outnames:bgr.dfs.lst is a list of habtypes within each subbgr, and the eunis level from the gis - it is used wihtin the for loop to write the sbgr file which is the match between gis and database
for (g in seq_along(x.dfs.lst)) {
        #determine the number of characters for substring limit to feed into substring statement
        sbstr.nchr <- unique(nchar(as.character(x.dfs.lst[[g]]$EUNISCode)))
        #Obtain the EUNIs code by copying only the number of characters at the level assessed.
        x <- substr(as.character(x.dfs.lst[[g]]$EUNISCode), 1,sbstr.nchr)
        #obtain the EUNIS level:
        mx.lvl <- unique(x.dfs.lst[[g]]$level)
        
        #r obj to save results per level
        level.result.tbl[[g]] <- data.frame(matrix(ncol = length(x)+4), stringsAsFactors = FALSE) # +4 to cater for the added columns, sbgr, etc
        names(level.result.tbl[[g]]) <- c(as.character(x.dfs.lst[[g]][[1]]),"sbgr", "h.lvl", "l.lvl","eunis.code.gis") #names should be x (highest level assessed against) 
        
        
        # specify a large table into which results can be written outside of for loops
        
        match_eunis_to_biotopes_fn(x,bgr.dfs.lst,mx.lvl) # this calls the FUNCTION which generates the results tables which are written to CSV - this should rather be stored as R objects which can be removed in due course than saving files - but needs further work
        
        #level.result.tbl[[g]] <- out # this does not yet work...at this stage all results are being wriiten to Results table csv and then read back in later
}
setwd(file.path(mainDir))
#getwd()
rm(mainDir, subDir, bgr.dfs.lst)



#---------------
#07 populate the sbgr biotope codes and replacing NA values with eunis codes in a sequential order, starting at eunis level 6, then 5 then 4, leaving the rest as NA. this is becuase the sensitivity assessments typically only include eunis levels 6,5,4 only.
# loads and runs the function: read in all the restuls generated in a single file as lists of dataframes: r object output name: results.files
source(file = "./functions/read_temporary_sbgr_results_fn.R")
# Outstored as result.files

#Take each dataframe in the list, and split it again according the finest eunis level that has been assessed (high level indicates this, or h.lvl), then amalgamate the h level resutls keeping onl;y the highest level
source(file = "./functions/sqntl_eunis_lvl_code_replacement_fn.R")
# Output stored as: sbgr.matched.btpt.w.rpl

#CAUTION: THIS WILL REMOVE ALL FILES IN THE SPECIFIED DIRECTORY!!! remove all the csv files written - this is a temporary work-around. If the results table can be stored as a R object rather than tables, this would not be neccessary
do.call(file.remove, list(list.files(paste(getwd(),folder, sep = "/"), full.names = TRUE)))
rm(results.files, folder)

#-------------
#08
#loads and runs script to join pressures to sbgr generated above
source(file = "./functions/join_pressure_to_sbgr_list_fn.R")
# Output stored as xap.ls

#housekeeping: remove objects no longer required
rm(sbgr.matched.btpt.w.rpl)

#----------------
#09
# compare and keep only maximum values for each biotope-pressure-activity-sub-biogeographic region combination.
# reads and runs the function
source(file = "./functions/min_max_sbgr_bap_fn.R")
# Output stored as: sbgr.BAP.max.sens

#housekeeping - remove temporary object (list) now
rm(xap.ls)

#housekeeping
rm(hab_map, x.dfs.lst, level.result.tbl, gis.attr, choice, OpsAct, EunisAssessed, eunis.lvl.assessed,sens.act.rank)

#--------------
#10 assocaite maximum sensitivity with gis polygon Ids (and the habitat type assessed and the confidence of the assessments)

source(file = "./functions/gis_sbgr_hab_max_sens_fn.R")
# Output stored as: act.sbgr.bps.gis

#housekeeping
rm(sbgr.BAP.max.sens, sbgr.hab.gis.assessed.conf.spread, hab_types)

#--------------
#11
#save singel GIS file as final output
# attach sensitivity results to the habitat map's geodatabase
hab_map@data <- cbind(hab_map@data, act.sbgr.bps.gis) 
writeRDS(act.sbgr.bps.gis, "./act.sbgr.bps.gis.R", compress = FALSE) # save the data as an object for analysis - it contains the shape_area field which can be used with sensitivity codes to do analysis.
rm(act.sbgr.bps.gis)

# write the sensitivity data to the geodatabase/geopackage Or #driver.choice <- "ESRI Shapefile" #to do: save as shapefile
#rm(list=setdiff(ls(), "hab_map", "driver.choice", "layer.name"))
writeOGR(hab_map, dsn = dsn.path, layer = layer.name, driver = driver.choice, overwrite_layer = TRUE)


