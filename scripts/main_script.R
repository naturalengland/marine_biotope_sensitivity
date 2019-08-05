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
rm(list = ls()) # this will remove all objects inthe R environment. Run this to ensure a clean start.
#rm(list=setdiff(ls(), c("hab_map"))) #useful command to remove all but hte habitat map which takes long to read - useful during testing

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
library(sf)
library(sp)# to allow for multiple layers being written - not sure tha tthis is being used any longer.


# USER INPUT REQUIRED BELOW
#-----
#PHIL TO REMOVE THIS FROM USER INPUT
# No user input required if happy with the polygons being assigned an id called pkey. Define variables: variable to group results by in script #11 - this should be the primary key in the gis habitat attribute file
group.by <- parse(text = "pkey") ## Set text = "ogc_fid" or any other unique identifier in the GIS file. It generates a field name taht is easy to cahnge - unique ID for polygons.

# TO DO: Phil remove this user input - and provide the user with a message of where the folder is.
#  USER: Create a folder in the working directory. (to see the working directory type: 'getwd()' into the R console). type the name of the final output folder for GIS geopackage below (it has to be exactly the same as the folde just created:) 
final_output <- "outputs"



## DEFINE THE FOLLOWING VARIABLES OR AT LEAST CHECK THAT THEY MAKE SENSE ACCORDING TO YOUR COMPUTER CONFIGURATION!!!!

# setwd("F:/projects/marine_biotope_sensitivity")



# User to specify the path to the database file activate the below and comment out the default paths
#db.path <- file.choose()
# e.g. laptop path
#db.path <- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/database/PD_AoO.accdb"
#power pc path specified below
db.path <- "D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO.accdb"
drv.path <- "Microsoft Access Driver (*.mdb, *.accdb)" #"this relies on the driver specified above for installation, and will not work without it!

# Define gis input for habitat map(s)
input_habitat_map <- "D:\\projects\\fishing_displacement\\2_subprojects_and_data\\2_GIS_DATA\\marine_habitat\\hab_clip_to_mmo_plan_areas\\marine_habitat_bsh_internal_evidence_inshore_multiple_sbgrs.gpkg"#this directory is for the clipped sbgrs.
# Run this to see the available layers in the gis file
sf::st_layers(input_habitat_map)
# Now supply the layer name that you are interest in
input_gis_layer <- "marine_habitat_bsh_internal_evidence_inshore_multiple_sbgrs"



## USER DEFINED OUTPUT

# USER: Provide a name for the temporary output folder. NOte that this is not permanent! files here will automatically be deleted! So do not name it the same as any folder which has valuable data in it.
folder <- "tmp_output/"

# NB! USER DEFINED VARIABLE: GIS output file name. Please specify one per activity: The idea is to house all activities for a sub-biogeoregion in one file, and to have four layers within that structure: 1) containing the original habitat data, 2) the sensitivity assessments, 3) confidence assessments and 4) the biotope assessed. this structure is supported by geopackages, and may well be in a number of others like geodatabases
#dsn.path<- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/4_R/sensitivities_per_pressure/habitat_sensitivity_test.gpkg"#specify the domain server name (path and geodatabase name, including the extension)
dsn_path_output <- paste0(getwd(),"/",final_output,"/habitat_sensitivity_fishing_multiple_sbgr") # name of geopackage file in final output
driver.choice <- "GPKG" # TYPE OF GIS OUTPUT SET TO geopackage, chosen here as it is open source and sopports the file struture which may be effecient for viewing o laptops


#set the THREE (of the four) layer names
#1 sensitivity
sens_layer_name_output <- "inshore_fishing_ops_multiple_sbgr_sens" # name of layer being produced (final output layer name)


#Below prints the list of options for the user to read, and then make a selection to enter below
#see key below
source(file = "./functions/read_access_operations_and_activities.R")
OpsAct <- try(suppressWarnings(read.access.op.act())) #suppressWarnings(expr) turns warnigns off, as this warning will just tell you which data were not selected, and may be unneccessarily confusing.
if("try-error" %in% class(OpsAct)){print("Choice could not be set. Make sure your your Access Driver software is set-up correctly. Defaulting to 11. Fishing (Z10)")}
if(!"try-error" %in% class(OpsAct)){print(OpsAct)}

# Choose an operation by selecting an OperationCode from the conservation advice database. Choose 1 - 18, and set the variable ops.choice to this.
#USER selection of operation code: Set the ops.number to which you are interested, e.g. ops.number <- 13
ops.number <- 11

# Run this to save your choice, and see what was saved
source(file = "./functions/set_user_ops_act_choice.R")

# END OF USER INPUT REQUIREMENT, you can now run scripts below to produce biotope sensitivity data.

#---------------------------------
# 01_connect_to_access_db.R

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

#--------------------------------
#02

# Obtain a table of the distinct EUNIS codes for which sensitivity data exists; this table will be used in joins to ensure that each EUNIs code gets checked against the Pressure Sensitivity assessments
eunis.lvl.assessed <- qryEUNIS_ActPressSens %>% 
        select(EUNISCode) %>% 
        distinct()
eunis.lvl.assessed$EUNISCode <- as.character(eunis.lvl.assessed$EUNISCode) # ensure EUNIS codes are character not factors!

#--------------------------------
#03
# Obtain sensitvity tables, one for each acitivity, with each EUNIS code assessed against each pressure code: 
# a list of data frames called "act.press.list" is created, which contains the unique combinations of ranked sensivities to pressure for each activity for each of the assessed biotope (i.e. from the Access database)
source(file = "./functions/unique_combs_sens_per_press_per_eunis_fn.R")

# housekeeping: remove the initial database query, and keep only the last R object
rm(qryEUNIS_ActPressSens)

#-------------------------------
# 04 Read GIS habitat map file

# Read geodatabase from network, it it fails read a preprocessed file (a back-up copy that should not be changed unless certain that it is working)
# status: the current network file specified is the full file - this will have to be changed to a directory where the latest preprocessed file is saved.
source(file = "./functions/read_gis_hab_input.R")

# calls the function which will read the habitat file. (This will take 10 minutes -  have a cup of tea, or read some email)
hab_map <- read_hab_map()  #temporarily set to a sample dataset to minimise processing time, go to the funciton and replace the sample layer with the actual layer you want to read in.
# TO CHANGE USING read_st(dsn = "", layer = "") as only data frame is needed at the start.

#------------------------------
#05
# Clean geodata file; done from attribute table - i.e. remove the geometry to make the file small and managable to work with.

# Cleans the HABTYPE column in the attribute, keeping on ly a single habitat type (not multiple within the same cell, as this cannot be assessed)
source(file = "./functions/clean_gis_attrib_habtype_fn.R")
gis.attr <- hab_map #create a copy of hab_map, which we can remove the geomoetry column from
gis.attr$geom <- NULL #remove geometry column, so that it is easier to work with the data frame object rather than an S4 or sf object.
hab.types <- clean_hab_type_dat(gis.attr)
rm(gis.attr)

#-------------------------------
#06 
# Assign EUNIS levels based on number of characters in EUNISCode
#EUNIS level
eunis.lvl.assessed$level <- nchar(as.character(eunis.lvl.assessed$EUNISCode), type = "chars", allowNA = T, keepNA = T)-1 # THIS NEEDS TO BE + 1

#specify the function to run: columns of levels with Eunis codes under themn
source(file = "./functions/eunis_code_per_level_fn.R")

#specify temporary variable into which the data is tored before being bound to EunisAssessed
ind.eunis.lvl.tmp <- eunis.levels()
#bind data into a singel dataframe
EunisAssessed <- cbind(eunis.lvl.assessed, ind.eunis.lvl.tmp)
#assign names to columns in the dataframe
names(EunisAssessed) <- c(names(eunis.lvl.assessed), names(ind.eunis.lvl.tmp))
#housekeeping, remove unused object
rm(eunis.lvl.assessed, ind.eunis.lvl.tmp)

#----------------------------
# 07 Imports a table of valid biotopes in each sub-Biogeoregion from the Access database
source("./functions/sbgr_biotopes_from_db.R")
tbl_eunis_sbgr <- read.sbgr.db(db.path,drv.path) # this tbl is fed into the match_eunis_to_biotope_fn.R where it filters out invalid combinations of biotope and sbgr:

#-------------------------------
#08 Match biotopes (using the sbgr filter imported above)
source("./functions/match_eunis_to_biotope_fn.R") # loads function that will match the biotopes
#this function will be passed through a loop below to repeat it for each Activity grup

# THE NEEDS TO BE FURTHER FUNCTIONALISED: but currently runs as a long section of code

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


#The below function is the main part to work on!
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
        #determine the number of characters for substring limit to feed into substring statement (5 characters = EUNIs level 4, and so on)
        sbstr.nchr <- unique(nchar(as.character(x.dfs.lst[[g]]$EUNISCode)))
        #Obtain the EUNIs code by copying only the number of characters at the level assessed.
        x <- substr(as.character(x.dfs.lst[[g]]$EUNISCode), 1,sbstr.nchr)
        
        #obtain the EUNIS level:
        mx.lvl <- unique(x.dfs.lst[[g]]$level)
        
        #r obj to save results per level (generates a named matrix with length 1, in which the column names are the assessed EUNIS Codes for all levels; it adds sbgr, h.lvl (assessed eunis code-level); l.lvl (mapped eunis code-level). and the eunis.code.gis; eunis code is the mapped eunis code level which will come from hab.type; e.g. file output name: subBGR_2a_match_biotope_eunis_high_5_eunis_mapped_2)
        level.result.tbl[[g]] <- data.frame(matrix(ncol = length(x)+4), stringsAsFactors = FALSE) # +4 to cater for the added columns, sbgr, etc
        names(level.result.tbl[[g]]) <- c(as.character(x.dfs.lst[[g]][[1]]),"sbgr", "h.lvl", "l.lvl","eunis.code.gis") #names should be x (highest level assessed against) 
        
        
        # specify a large table into which results can be written outside of for loops
        
        match_eunis_to_biotopes_fn(x,bgr.dfs.lst,mx.lvl) # this calls the FUNCTION which generates the results tables which are written to CSV - this should rather be stored as R objects which can be removed in due course than saving files - but needs further work
        
        #level.result.tbl[[g]] <- out # this does not yet work...
        #OUTPUT: at this stage all results are being wriiten to Results table csv(s) and then read back in later as result.files
}
setwd(file.path(mainDir))
#getwd()
#rm(mainDir, subDir, bgr.dfs.lst)



#---------------
#09 populate the sbgr biotope codes and replacing NA values with eunis codes in a sequential order, starting at eunis level 6, then 5 then 4, leaving the rest as NA. this is becuase the sensitivity assessments typically only include eunis levels 6,5,4 only.
# loads and runs the function: read in all the restuls generated in a single file as lists of dataframes: r object output name: results.files
source(file = "./functions/read_temporary_sbgr_results_fn.R")
# Output stored as result.files (note that this contains biotope candidates for EUNIS levels 4,5,6 which are cross-tabulated with the GIS habitat type, BUT ONLY ones which are knwon to occur within each of the sub-biogeoregions (sbgr))

#Take each dataframe in the list, and split it again according the finest eunis level that has been assessed (high level indicates this, or h.lvl), then amalgamate the high level results keeping only the highest level
source(file = "./functions/sqntl_eunis_lvl_code_replacement_fn.R")
# Output stored as: sbgr.matched.btpt.w.rpl

#CAUTION: THIS WILL REMOVE ALL FILES IN THE SPECIFIED DIRECTORY!!! remove all the csv files written - this is a temporary work-around. If the results table can be stored as a R object rather than tables, this would not be neccessary
do.call(file.remove, list(list.files(paste(getwd(),folder, sep = "/"), full.names = TRUE)))
#rm(results.files, folder)

#-------------
#10
#loads and runs script to join pressures to sbgr generated above
source(file = "./functions/join_pressure_to_sbgr_list_fn.R")
# Output stored as xap.ls 
# Consider saving the output into a database - from here minimum, range etc can be calculated (and should be more or less in line with the process that JNCC followed to aggeregate its EUNIS data.

# housekeeping: remove objects no longer required
#rm(sbgr.matched.btpt.w.rpl)

#----------------
# 11
# compare the biotope sensitivity assessment values associated with each broad-scale habitat, and keep only maximum values for each biotope-pressure-activity-sub-biogeographic region combination.
# Below reads and runs the function
source(file = "./functions/max_sens_sbgr_bap_fn.R") #recently (2019-07-10) renamed this to be more accurate reflection of the function.
# Output stored as: sbgr.BAP.max.sens - key output - this can be translated into min, max, range etc. NE is currently only taking the MAXIMUM value forward, but this can be changed inside of this function/or preferbaly creating a new function based on this one.

# housekeeping - remove temporary object (list) now
#rm(xap.ls)

#housekeeping
#rm(x.dfs.lst, level.result.tbl, gis.attr, choice, OpsAct, EunisAssessed, eunis.lvl.assessed,sens.act.rank)

#--------------
#12 associate maximum sensitivity with gis polygon Ids (and the habitat type assessed and the confidence of the assessments)

source(file = "./functions/gis_sbgr_hab_max_sens_fn.R") # this takes a while - get a cup of tea, read emails,or stare out the window.
# Output stored as: act.sbgr.bps.gis



#housekeeping
rm(sbgr.BAP.max.sens)

#--------------
#11 remove not assessed columns to reduce the size of the data
#not_all_na <- function(x) any(!is.na(x))
#not_any_na <- function(x) all(!is.na(x))
#act.sbgr.bps.gis.clean <- act.sbgr.bps.gis %>% 
#        dplyr::select_if(not_all_na) %>% 
#        dplyr::select(-contains("not_assessed"))

#--------------
#12
# Joins the habitat type information to the sensitivity assessments
sens_dat <- hab.types %>% 
        left_join(act.sbgr.bps.gis, by = "pkey")

#attach the geometry column from hab_map
sens_dat$geom <- st_geometry(obj = hab_map, value = hab_map$geom, x = sens_dat)


sf::st_layers(paste0(dsn_path_output, ".GPKG", sep = '')) # run this to check which ones have been completed
#write the sens_dat to file, stored in the output folder in the R project file
sf::st_write(sens_dat, dsn = paste0(dsn_path_output, ".GPKG", sep = ''), layer = sens_layer_name_output, update = TRUE)



# If seperate layer are required for each, the following can be used: # separate the three components (sensitivity score, confidence assessment and the assessed biotope) into three data.frames to allow binding them as seperate layers to the geopackage - for easier opening.

#sens_dat <- act.sbgr.bps.gis.clean %>% 
#        dplyr::select(pkey, contains("sens"))
#qoe_dat <- act.sbgr.bps.gis.clean %>% 
#        dplyr::select(pkey, contains("conf"))
#hab_info <- hab.types %>% 
#        select(HAB_TYPE,pkey) %>% 
#        filter(!is.na(HAB_TYPE)) %>%
#        distinct() %>% arrange(pkey)

#biotope_dat <- act.sbgr.bps.gis.clean %>% 
#        dplyr::select(pkey, contains("assessed")) #%>%



