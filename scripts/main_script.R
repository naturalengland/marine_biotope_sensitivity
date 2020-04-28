# Project Title: Marine benthic habitat sensitivity 


# AIM: Develop sensitivity maps for the benthic substrate to a range of activities taking place in the marine environment
# Further: The pressures refer to the 36 OSPAR + 3 pressures, from a suite of activities in a single MarESA operation, e.g. Fishing.

# Author: Philip Haupt
# Date: 2018-08-28 to 2020-04-27

# Script name: Main script
## This is the main script which runs the support functions, sequentially, making objects available to coming/sequential functions. I.e. The user should only have to run this script to produce outputs.

#-------------------------------------------------
# START
# Clear workspace if not cleared! i.e. there should be nothing in the R Global Environment at this point: you will need all the RAM available to you to process the script
rm(list = ls()) # this will remove all objects inthe R environment. Run this to ensure a clean start.

# TIP: If you are editing the code, I have left commented out pieces of code, like the below, in which may be useful in future. Remove the comment and run if you know what you are doing.
# rm(list=setdiff(ls(), c("hab_map"))) # useful command to remove all but the habitat map which takes long to read - useful during testing

#-----
# R libraries
## Below the list of R libraries to load into R (in sequence). If they are not already installed on your machine you will have to do so first. This can be done using the command like install.packages("RODBC"), for each of the libraries. Then load them by running the commands below.
library(RODBC) # allows connecting to databases
library(DBI) # allows connecting to databases
library(tidyverse) # data wrangling scripts
library(plyr) # more data wrangling scripts
library(reshape2) # more data wrangling scripts
library(rgdal) # gis scripts
library(magrittr) # piping scripts, loaded again and here to ensure that some funtions run as they are written
library(stringr) # text manipulation library
library(sf) # key GI library
library(doParallel)

# Parallel processing set-up ----------------------------------------------
cl <- makeCluster(4) # set Power PC  = 8 or more, laptops about 3 (depending the number of processors available. Note that more processoirs speeds up the calculations, but the more processors you apply, the greater the amount of RAM needed.
registerDoParallel(4) # same as above
opts <- list(preschedule=TRUE)
clusterSetRNGStream(cl, 123) # for reproducible results, using a constant set "seed value".

# USER INPUT SECTION -----------------------------------------
# 1. Select the marine planning area in which you would like to work (they have different algorithms)
waters <- "offshore" # has to be "inshore" or "offshore"

# 2. Select to filter/or not to filter the potential biotopes (proxies biotopes from which sensitivity assessments scores are taken and associated with broad-scale habitats.) 
# Only enter: TRUE or FALSE: Are there MULTIPLE sub-biogeoregions in the habitat file that you are wanting to calculate sensitivity for?
sbgr_filter <- FALSE # has to be TRUE or FALSE; NB! TRUE is only available for the "inshore" waters at this stage - it will automatically be overwritten if you select offshore.

# 3. USER DEFINED OUTPUT FOLDER: Create a folder in the working directory. (To see the working directory type: 'getwd()' into the R console). Type the name of the final output folder for GIS geopackage below (it has to be exactly the same as the folder just created:) 
final_output <- "packaged_outputs" # Create an output directory and specify the name here, and place it in the working directory.
# No input required, just run this: It will check if this output subdirectory exists in your working direcotry, and create it if it does not.
ifelse(!dir.exists(file.path(getwd(), final_output)), dir.create(file.path(getwd(), final_output)), FALSE) 


# DEFINE THE FOLLOWING VARIABLES OR AT LEAST CHECK THAT THEY MAKE SENSE ACCORDING TO YOUR COMPUTER CONFIGURATION!!!!
# 4. User to specify the path to the Microsoft Access database file
db.path <- "./input/PD_AoO.accdb" # relative path entered or specify exact path, like: #D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database; OR make this your active command: #db.path <- file.choose()
drv.path <- "Microsoft Access Driver (*.mdb, *.accdb)" #"this relies on the driver specified above for installation, and will not work without it!

# User to choose Activities/operation which will be used in the model to assess habitat sensitivity
# User to choose Activities/operation which will be used in the model to assess habitat sensitivity.

## 5. Below prints the list of options for the user to read, and then makes a selection to enter below
source(file = "./functions/read_access_operations_and_activities.R") # Note that this list is obtained from the database specified above – no user input required
OpsAct <- try(suppressWarnings(read.access.op.act()))
if("try-error" %in% class(OpsAct)){print("Choice could not be set. Make sure your Access Driver software is set-up correctly. Defaulting to 11. Fishing (Z10)")}
if(!"try-error" %in% class(OpsAct)){print(OpsAct)}
# USER: Choose an operation by entering one OperationCode (an integer number ranging from 1 - 18) which corresponds to the operation numbers just printed on the screen. These reflect the ID number assigned to activities in the Microsoft Access conservation advice database (PD_AoO.accdb).
# e.g. ops.number <- 10 (renewable energy)# 13 oil spill # 11 fishing
ops.number <- 13

# END OF USER INPUT REQUIREMENT

# RUN ALL THE SCRIPTS IN THE SEQUENCE THAT THEY ARE WRITTEN FROM HERE ON TO THE END IF YOU WANT A GIS OUTPUT.
# Press "Control + ENTER" repeatedly to run each command, one at a time (this needs doing if an error occurs so you can find the mistake). Alternatively press "Cntrl + Alt + ENTER" to run from start to finish.

#-------------------------------------------------
# Programmed variables - no need for user to change this, but can be altered (with care) if required:

# 6. Run this to save your choice, and see what was saved
source(file = "./functions/set_user_ops_act_choice.R")

# 7. No user input required if happy with the polygons being assigned an id called pkey. Define variables: variable to group results by in script #11 - this should be the primary key in the gis habitat attribute file
group.by <- parse(text = "pkey") ## Set text = "ogc_fid" or any other unique identifier in the GIS file. It generates a field name that is easy to change - unique ID for polygons.

# 8.  Specify the habitat map/geodata input files based on the inshore offshore boundary and sub-biogeoregional specified by the user 
source(file = "./functions/specify_dir_for_habitat_map_on_user_input_of_boundaries_and_filter.R")

# 9. Name for the temporary output folder. Note that this is not permanent! Files here will automatically be deleted! So do not name it the same as any folder which has valuable data in it.
folder <- "tmp_output/" # this folder will be created in your working directory - files will go into it temporarily, and then be deleted. You may delete the empty folder if you like after completing the running of the scripts if you like.

# 10. GIS output file name. 
driver.choice <- "GPKG" # TYPE OF GIS OUTPUT SET TO geopackage, chosen here as it is open source and sopports the file struture which may be effecient for viewing on laptops
source("./functions/file_name_choice.R") #running this bit simplifies the name coming from the database and cleans punctuation so that it can be used in a filename.
dsn_path_output <- paste0(getwd(),"/",final_output,"/","BenthicHabitatSensitivity_",file_name_choice,"_wgs84") # name of geopackage file in final output

# 11. Provide an OUTPUT layer name within the Geopackage specified above# 11. Provide an OUTPUT layer name within the the Geopackage specified above
sens_layer_name_output <- paste0("BenHabSens_",file_name_choice,"_",if(sbgr_filter == TRUE) {"Filtered"} else {"Unfiltered"}, "_", waters) # name of geopackage file in final output"BHS_Fishing_Offshore_Unfiltered" # name of layer being produced (final output layer name)

# 12. print User selected variables
cat(paste0("Message for the user to check: The Habitat Sensitivity model is set to run for ", eval(as.character(choice[[2]]))," activities in ", waters, " waters. The model will apply the sub-biogeoregional filter: ", sbgr_filter, ".",
           " The input habitat file used is:", input_habitat_map, " using layer: ", input_gis_layer,".",
           " The output file is ",dsn_path_output, " and the output layer name is: ", sens_layer_name_output, "."))
#---------------------------------
# 13. Connect to the MS Access conservation Advice database, and read in the relevant tables.
# Load the function that reads the Access database (the function is run within an If statement below)
source(file = "./functions/read_access_db.R")

# 14. Populate qryEUNIS_ActPressureSens using the read access function above, if it fails it will attempt to read a stored csv copy (note that this may not be the most up to date version)
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
# 14 DISTINCT EUNIS CODES in  SENS ASSESS:

# Obtain a table of the distinct EUNIS codes for which sensitivity data exists; this table will be used in joins to ensure that each EUNIs code gets checked against the Pressure Sensitivity assessments
eunis.lvl.assessed <- qryEUNIS_ActPressSens %>% 
        select(EUNISCode) %>% 
        distinct()
eunis.lvl.assessed$EUNISCode <- as.character(eunis.lvl.assessed$EUNISCode) # ensure EUNIS codes are character not factors!

#-----------------------------
# 15 ASSIGN EUNIS LEVELS
# Assign EUNIS levels based on number of characters in EUNISCode
#EUNIS level
eunis.lvl.assessed$level <- nchar(as.character(eunis.lvl.assessed$EUNISCode), type = "chars", allowNA = T, keepNA = T)-1 # THIS NEEDS TO BE + 1

#specify the function to run: columns of levels with Eunis codes under themn
source(file = "./functions/eunis_code_per_level_fn.R")
#output is eunis.lvl.assessed

#specify temporary variable into which the data is stored before being bound to EunisAssessed
ind.eunis.lvl.tmp <- eunis.levels()

#bind data into a single dataframe
EunisAssessed <- cbind(eunis.lvl.assessed, ind.eunis.lvl.tmp)
#assign names to columns in the dataframe
names(EunisAssessed) <- c(names(eunis.lvl.assessed), names(ind.eunis.lvl.tmp))
#housekeeping, remove unused object
#rm(eunis.lvl.assessed, ind.eunis.lvl.tmp)


#--------------------------------
# 16 sensitivity tables for each activity pressure combination
# Obtain sensitivity tables, one for each activity, with each EUNIS code assessed against each pressure code: 
# a list of data frames called "act.press.list" is created, which contains the unique combinations of ranked sensitivities to pressure for each activity for each of the assessed biotope (i.e. from the Access database)
source(file = "./functions/unique_combs_sens_per_press_per_eunis_fn.R")


#-------------------------------
# 17 Read GIS habitat map file
# Read geodatabase from network, if it fails read a pre-processed file (a back-up copy that should not be changed unless certain that your new version is working)
source(file = "./functions/read_gis_hab_input.R") # note that the file specify_dir_for_habitat_map_on_user_input_of_boundaries_and_filter.R is currently set to read off the PowerPC - so please change the file specify_dir_for_habitat_map_on_user_input_of_boundaries_and_filter.R to read from the network first, and then the back-up location.

# calls the function which will read the habitat file.
hab_map <- read_hab_map()  # reads in the habitat map specified by the user
# TO CHANGE USING read_st(dsn = "", layer = "") as only data frame is needed at the start.

#------------------------------
# 18 CLEAN DATA
# Clean geodata file; done from attribute table - i.e. remove the geometry to make the file small and manageable to work with.
# Cleans the HAB_TYPE column in the attribute, keeping only a single habitat type (not multiple within the same cell, as this cannot be assessed)

source(file = "./functions/clean_gis_attrib_habtype_fn.R")
gis.attr <- hab_map #create a copy of hab_map, which we can remove the geometry column from
gis.attr$geom <- NULL #remove geometry column, so that it is easier to work with the data frame object rather than an S4 or sf object.
# assign attribute to sbgr id only if not a multiple sbgr layers
if(sbgr_filter == FALSE) {
        gis.attr$SubReg_id <- waters
}


hab.types <- suppressWarnings((clean_hab_type_dat(gis.attr))) # adds_hab_type to the environment which is the cleaned habitat codes data.
rm(gis.attr)


#-------------------------------
# 19 MOSAIC HABITATS
# Gather the habitat types into a single column with hab_1 (1st listed habitat) and second and third habitats listed to allow incorporation of mosaic habitats
# The script also ads "A" to all HAB_TYPES with NO information in the HAB_TYPE column. This is not going to be correct for ALL the polygons on the map - but as they lack any sort of code - they either need to be completely excluded from the map at the start, or have some sort of EUNIS code. To address this inconsistency temporarily, I have changed these to "A" Marine.

source("./functions/gather_hab_types_by_mosaic_habs.R")
#this leaves a new variable hab_types, which is different from hab.types, as it includes ALL the habitats, including mosaic habitats. This was done to allow processing all the said habitats and compare their sensitivities within a polygon following the same process as previous.



#----------------------------
# 20 FILTER BIOTOPE CANDIDATES

# Determine the list of BIOTOPES which may be assocaited to mapped habitats in the next steps using the SUB-BIOREGIONAL filter OR No filter

# NB! This below checks user input parameters, and overwrites sbgr_filter to FALSE if offshore waters were selected (waters = offshore), as there is no offshore sbgr filter at present.
if(waters == "offshore") {
        sbgr_filter <- FALSE
}
# NB! This will have to be changed along with teh filtering codes when the JNCC offshore biotope filter becomes available.

# Function with if else statements to call call one of the two biotope reading functions (with or without filter). (this allows having all the scripts in the same place - i.e. no seperate script is needed for the offshore any longer.)
source("./functions/direct_analysis_filter.R")
tbl_eunis_sbgr <- read_biotopes_with_or_without_filter(apply_filter = sbgr_filter) # sbgr_filter was set by the user in the first at the start of the main script.
# The internal functions imports a table of valid biotopes in each sub-Biogeoregion from the Access database (or all the biotopes wihtout using a sub-bioregional filter)
# Output stored as tbl_eunis_sbgr

#-------------------------------
# 21 Match biotopes

# THE NEEDS TO BE FURTHER FUNCTIONALISED: but currently runs as a long section of code

# input data
# SPATIAL data for join (y):
# y - from spatial data; all possible EUNIS codes per BGR
# in order to do so, define the EUNIS level of the hab_1 column
eunis.lvl.less.2 <- nchar(as.character(hab_types$habs), type = "chars", allowNA = T, keepNA = T)
eunis.lvl.more.2 <- nchar(as.character(hab_types$habs), type = "chars", allowNA = T, keepNA = T)-1
hab_types$level <- ifelse(nchar(as.character(hab_types$habs), type = "chars", allowNA = T, keepNA = T) > 2, eunis.lvl.more.2, eunis.lvl.less.2) #only using the first stated habitat, could be made to include others later on

#hab_types$level[hab_types$HAB_TYPE == "na_habs"] <- 5 # remove - no longer neccesary to assign a level to missing habitats as these have been assigned to "A"
rm(eunis.lvl.less.2, eunis.lvl.more.2) # housekeeping remove temporary vars


# Define (unique) benthic habitats to allow the join between the GIS spatial mapped data and the sensitivity assessments (by EUNIS codes)
distinct_mapped_habt_types <- hab_types %>%
        distinct(habs,bgr_subreg_id, level) %>% drop_na() # hab_1 contains the worked/processed HAB_TYPE data (1st column)

#generate multiple dataframes in a list, for the various habitat types within subBGRs, per hab level. this holds the gis data used to generate cross tabulated data matrices in the "match_eunis_to_biotope_fn"
bgr_dfs_lst <- split(distinct_mapped_habt_types, distinct_mapped_habt_types$bgr_subreg_id)


#The below function is the main part to work on!
# All EUNIS Biotopes that have been assessed 
#this list of data tables holds the assessed level data from the Access database - all habitats assessed per habitat level. this will be used with the above to generate the cross tabulate matrices in the "match_eunis_to_biotope_fn"
x_dfs_lst <- split(EunisAssessed,f = EunisAssessed$level)

level_result_tbl <- vector("list", length(x_dfs_lst))
names(level_result_tbl) <- paste0("h.lvl_",names(x_dfs_lst))

# Loads function that will match the biotopes
source("./functions/match_eunis_to_biotope_fn.R") 
# this function will be passed through a loop below to repeat it for each Activity group

# Genreate a diroctory save temporary output files into
mainDir <- getwd()#"C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/4_R/sensitivities_per_pressure"
subDir <- "tmp_output/"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)
setwd(file.path(mainDir, subDir))

# below is a for loop in which the EUNIsAssessed is split into a list of dataframes 1st being the most detailed biotope level (6), and then down to the broadest biotope level (4) that were assessed in the PD_AoO access database: outnames:bgr.dfs.lst is a list of habtypes within each subbgr, and the eunis level from the gis - it is used wihtin the for loop to write the sbgr file which is the match between gis and database
for (g in seq_along(x_dfs_lst)) {
        #determine the number of characters for substring limit to feed into substring statement (5 characters = EUNIs level 4, and so on)
        sbstr.nchr <- unique(nchar(as.character(x_dfs_lst[[g]]$EUNISCode)))
        #Obtain the EUNIs code by copying only the number of characters at the level assessed.
        x <- substr(as.character(x_dfs_lst[[g]]$EUNISCode), 1,sbstr.nchr)
        
        #obtain the EUNIS level:
        mx_lvl <- unique(x_dfs_lst[[g]]$level)
        
        #r obj to save results per level (generates a named matrix with length 1, in which the column names are the assessed EUNIS Codes for all levels; it adds sbgr, h.lvl (assessed eunis code-level); l.lvl (mapped eunis code-level). and the eunis.code.gis; eunis code is the mapped eunis code level which will come from hab.type; e.g. file output name: subBGR_2a_match_biotope_eunis_high_5_eunis_mapped_2)
        level_result_tbl[[g]] <- data.frame(matrix(ncol = length(x)+4), stringsAsFactors = FALSE) # +4 to cater for the added columns, sbgr, etc
        names(level_result_tbl[[g]]) <- c(as.character(x_dfs_lst[[g]][[1]]),"sbgr", "h.lvl", "l.lvl","eunis.code.gis") #names should be x (highest level assessed against) 
        
        
        # specify a large table into which results can be written outside of for loops
        
        match_eunis_to_biotopes_fn(x,bgr_dfs_lst,mx_lvl) # this calls the FUNCTION which generates the results tables which are written to CSV - this should rather be stored as R objects which can be removed in due course than saving files - but needs further work
        
        #level.result.tbl[[g]] <- out # this does not yet work...
        #OUTPUT: at this stage all results are being wriiten to Results table csv(s) and then read back in later as result.files
}
setwd(file.path(mainDir))
#getwd()
#rm(mainDir, subDir, bgr.dfs.lst)

#---------------
# 22. Populate the sbgr biotope codes and replacing NA values with eunis codes in a sequential order, starting at eunis level 6, then 5 then 4, leaving the rest as NA. this is becuase the sensitivity assessments typically only include eunis levels 6,5,4 only.
# loads and runs the function: read in all the restuls generated in a single file as lists of dataframes: r object output name: results.files
source(file = "./functions/read_temporary_sbgr_results_fn.R")
# Output stored as result.files (note that this contains biotope candidates for EUNIS levels 4,5,6 which are cross-tabulated with the GIS habitat type, BUT ONLY ones which are knwon to occur within each of the sub-biogeoregions (sbgr))

#---------------
# Step 23 – Generate replacement biotope data
#Take each dataframe in the list, and split it again according the finest eunis level that has been assessed (high level indicates this, or h.lvl), then amalgamate the high level results keeping only the highest level
source(file = "./functions/sqntl_eunis_lvl_code_replacement_fn.R")
# Output stored as: sbgr.matched.btpt.w.rpl

#CAUTION: THIS WILL REMOVE ALL FILES IN THE SPECIFIED DIRECTORY!!! remove all the csv files written - this is a temporary work-around. If the results table can be stored as a R object rather than tables, this would not be neccessary
do.call(file.remove, list(list.files(paste(getwd(),folder, sep = "/"), full.names = TRUE)))
#rm(results.files, folder)

#--------------------------
# 24: UNCERTAINTY ESTIMATE

# uncertainty of assigning (multiple) biotopes to mapped habitats per sub-bioregion (which differ according to their EUNIS levels)

source("./functions/uncertainty_calcs_biotope_proxies.R")

# this is to counter the case where only inshore or offshore result in a matrix/list rather than a data.frame output
if (class(uncertainty_of_biotope_proxy) == "matrix") {
uncertainty_of_biotope_proxy <- data.frame(matrix(unlist((uncertainty_of_biotope_proxy)), nrow=length(uncertainty_of_biotope_proxy[[1]]), byrow=F), stringsAsFactors = FALSE)
names(uncertainty_of_biotope_proxy) <- c("sbgr","eunis_code_gis","uncertainty_sim")
uncertainty_of_biotope_proxy$uncertainty_sim <- as.numeric(uncertainty_of_biotope_proxy$uncertainty_sim)
} else paste0("The uncertainty output, uncertainty_of_biotope_proxy, is a ", class(uncertainty_of_biotope_proxy))
#output: uncertainty_of_biotope_proxy and should be a dataframe

#-------------
# 25 JOIN ACTIVITY-PRESSURE TO SENSITIVITY ASESSMENTS

#loads and runs script to join pressures to sbgr generated above
source(file = "./functions/join_pressure_to_sbgr_list_fn.R")
# Output stored as xap.ls 
# Consider saving the output into a database - from here minimum, range etc can be calculated (and should be more or less in line with the process that JNCC followed to aggeregate its EUNIS data.

# housekeeping: remove objects no longer required
rm(sbgr.matched.btpt.w.rpl)

#----------------
# 26: MAXIMUM SENSITIVITY PER POLYGON

# compare the biotope sensitivity assessment values associated with each broad-scale habitat, and keep only maximum values for each biotope-pressure-activity-sub-biogeographic region combination.
# Below reads and runs the function
source(file = "./functions/max_sens_sbgr_bap_fn.R")#recently (2019-07-10) renamed this to be more accurate reflection of the function.
# Output stored as: sbgr.BAP.max.sens - key output - this can be translated into min, max, range etc. NE is currently only taking the MAXIMUM value forward, but this can be changed inside of this function/or preferbaly creating a new function based on this one.

#housekeeping
rm(x_dfs_lst, bgr_dfs_lst, results.files, distinct_mapped_habt_types, level_result_tbl, OpsAct, EunisAssessed)

#--------------
# 27: ASSOCIATE MAXIMUM SENSITIVITY WITH GIS 

#Associate maximum sensitivity with gis polygon Ids (and the habitat type assessed and the confidence of the assessments)
system.time(source(file = "./functions/gis_sbgr_hab_max_sens_fn.R") )# this takes a while - get a cup of tea.
# The output file name is: act.sbgr.bps.gis

#housekeeping
rm(sbgr.BAP.max.sens)

#--------------
# 28. JOIN CONFIDENCE OF BIOTOPE ASSIGNMENT TO HABITAT ATTRIBUTES

# Join uncertainty to hab.types - may need a line to IF not hab_1 then hab.2 then... for mosaic habs?
hab.types.unc <- left_join(hab.types, uncertainty_of_biotope_proxy, by = c("bgr_subreg_id" = "sbgr", "hab_1" = "eunis_code_gis"))
#hab.types.unc <- left_join(hab_types, uncertainty_of_biotope_proxy, by = c("bgr_subreg_id" = "sbgr", "habs" = "eunis_code_gis"))
#--------------
# 29. JOIN HABITAT ATTRIBUTES TO SENSITIVITY ASSESSMENTS

# Joins the habitat type information (with confidence scores) to the sensitivity assessments
sens_dat <- hab.types.unc %>% 
        left_join(act.sbgr.bps.gis, by = "pkey")

#------------------------
# 30. Make and save attribution description table 
# run file attribution main script - this makes the attribution data file that descibes the columns for the habitatsenstivity outputs
source("./scripts/attribution/make_attribute_table.R")

#---------------
# 31 PROVIDE GEOMETRY DATA 

#attach the geometry column from hab_map to the sens_dat variable: this allows us to map the outputs (and is possble as we have preserved the id of the polygons, named "pkey")
sens_dat$geom <- st_geometry(obj = hab_map, value = hab_map$geom, x = sens_dat)

#---------------
# 32. WRITE GIS OUTPUT

# TIP: sf::st_layers(paste0(dsn_path_output, ".GPKG", sep = '')) # run this to check which layers have been completed, if you have already saved layers to the same file.

# write the sens_dat to file, stored in the output folder in the R project file
sf::st_write(sens_dat, dsn = paste0(dsn_path_output, ".GPKG", sep = ''), layer = sens_layer_name_output, update = TRUE)

# the end---------------------------





