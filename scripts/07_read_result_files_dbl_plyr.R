# Aims: Overarching aim is to consolidate the sensitivity assessments of the biotopes which occur within braoder habitats wihtin each subbiogeographic region, respectively.
# Remember that each braoder benthic habitat, e.g. A.1.2 could have multiple biotopes occuring within it, and we need to know all of the, and at which eunis level the ASSESSMENT WAS CARRIED OUT. 
# 1) Read all previously generated "MATCHED DATABASE AND GIS BIOTOPE" dataframes, currently stored as csv files, as a list of dataframes which are split by the sub-biogeographic region (sbgr) in which they occur.
# 2) generate a list and consolidate the multiple levels of biotope sensitivities per sub-biogeographic region into a single sub-biogeogrpahical region dataframe. finally, put all the consolidated dataframes (per sbgr) into a list


#Rlibraries
library(plyr)
library(dplyr)
library(magrittr)

#set the folder so that it is easy to refer to it, may need to change this more dynamically
#uses relative file path from working directory (= project directory)
folder <- "tmp_output/"

# loads and runs the function: read in all the restuls generated in a single file as lists of dataframes
source(file = "./functions/read_temporary_sbgr_results_fn.R")

#Take each dataframe in the list, and split it again according the finest eunis level that has been assessed (high level indicates this, or h.lvl), then amalgamate the h level resutls keeping onl;y the highest level
source(file = "./functions/sqntl_eunis_level_code_replacement_fn.R")
#CAUTION: THIS WILL REMOVE ALL FILES IN THE SPECIFIED DIRECTORY!!! remove all the csv files written - this is a temporary work-around. If the results table can be stored as a R object rather than tables, this would not be neccessary
do.call(file.remove, list(list.files(paste(getwd(),folder, sep = "/"), full.names = TRUE)))
rm(results.files, folder)
