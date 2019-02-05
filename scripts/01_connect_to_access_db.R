# connect to the MS Access Conservation Advice databse (PD_AoO), and query the sensitivity per Biotope 
# this is the first file in a series of files which has to be run.

#------
# System requirements
# Install a microsoft access driver if not already on PC/machine, available from e.g. https://www.microsoft.com/en-us/download/details.aspx?id=54920
# The driver version (64/32) has to match the system and R version 64 bit or 32 bit

#------
#Notes 
#Biotopes which have been assessed for sensitivity in the conservation Advice database only include Eunis levels 4 to 6 at this stage.



rm(list = ls())
#-----
# R libraries
library(RODBC)
library(DBI)# R library to harnass ODBC, # install package RODBC if not already installed within R using the command: install.packages("RODBC")
library(tidyverse) # to use piping and other data wrangling functions.

# Define Variables
## set the path to the database #this will hoefully be a 

#if user to specify the path to the file activiate teh below and comment out the default paths
#db.path <- file.choose()

#laptop path
#db.path <- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/database/PD_AoO.accdb"

#power pc path
db.path <- "D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO.accdb"
drv.path <- "Microsoft Access Driver (*.mdb, *.accdb)" #"SQL Server"#or #
#srv.host <- "Null"#e.g. "mysqlhost"
# Issues: currently only a local copy of the MS Access database is available on my working hard drive, and this needs to be pointed at the network (eventually) when approved
#---------------------------------

#load the function that reads the Access database
source(file = "./functions/read_access_db_fn.R")

#populate qryEUNIS_ActPressureSens using the read access function above, if it fails it will attempt to read a stored csv copy (note that this may not be the most up to date version)
qryEUNIS_ActPressSens <- try(read.access.db(db.path,drv.path)) 
if("try-error" %in% class(read.access.db(db.path,drv.path))) {
        qryEUNIS_ActPressSens <- read.csv("C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/qryhabsens/qryEUNIS_ActPressSens.txt")
}

# ensure EUNISCode is a character, as it reads converts to factor (which is incorrectand caannot join to other objects)
qryEUNIS_ActPressSens$EUNISCode <- as.character(qryEUNIS_ActPressSens$EUNISCode) 

#remove housekeeping variables
rm(db.path,drv.path,srv.host)

#TEST RUN: ONLY THIS LINE
#qryEUNIS_ActPressSens <- read.csv("C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/qryhabsens/qryEUNIS_ActPressSens.txt")
