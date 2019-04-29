library(RODBC)
library(DBI)
library(tidyverse)

#Below prints the list of options for the user to read, and then make a selection to enter below
#see key below
db.p  <-  db.path
drv.p <-  drv.path

#specificy the connection to the database
connection.path <- paste0("Driver={",drv.path,"};DBQ=",db.path)#server=",srv.host,"; #server may need to be defined for other SQL database formats

# Connect to Access db to allow reading the data into R environment.
conn <- odbcDriverConnect(connection.path)

# Get individual data tables
#----------------------------------------------------------------------------------------
#sql statements to translate Microsoft Access table into R objects - these will be needed make joined tables to arrive at the required datatable
tblEUNISPressure <- sqlQuery(conn, paste("SELECT tblEUNISPressure.*
                                       FROM tblEUNISPressure;"))
tblEUNISPressure <- as.data.frame(sapply(X = tblEUNISPressure, FUN = as.character), stringsAsFactors=FALSE)
confidence_sens_eunis <- tblEUNISPressure %>%
        dplyr::select(EUNISCode, PressureCode, SensitivityQoE) %>%
        distinct()

confidence <- dplyr::left_join(x, confidence_sens_eunis, by = c("PressureCode" = "PressureCode", "EUNISCode" = "eunis.code.gis"))

#for each activity, do
#sbgr.BAP.max.sens.conf <- sbgr.BAP.max.sens %>%
#        llply(function(x){
#                sbgr.BAP.max.sens.conf.tmp <- dplyr::left_join(x, confidence_sens_eunis, by = c("PressureCode" = "PressureCode", "EUNISCode" = "eunis.code.gis"))
#                
#                
#        }
#)



close(conn)