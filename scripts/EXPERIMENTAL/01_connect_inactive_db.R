library(RODBC)
library(DBI)
library(plyr)
library(tidyverse)
library(reshape2)
library(rgdal)
library(magrittr)
library(stringr)

#path to inactive database
db.ia.path <- "D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO_inactive 190214/PD_AoO_inactive.accdb"
drv.path <- "Microsoft Access Driver (*.mdb, *.accdb)" #"this relies on the driver specified above for isntallation, and will not work without it!


read.access.ia.db <- function(db.p = db.ia.path, drv.p = drv.path){
        
        #specificy the connection to the database
        connection.path <- paste0("Driver={",drv.path,"};DBQ=",db.ia.path)#server=",srv.host,"; #server may need to be defined for other SQL database formats
        
        # Connect to Access db to allow reading the data into R environment.
        conn <- odbcDriverConnect(connection.path)
        

        ## Inspect data
        ## List of Tables
        subset(sqlTables(conn), TABLE_TYPE == "TABLE") %>%
                arrange(TABLE_NAME)
        ## List of VIEW queries
        subset(sqlTables(conn), TABLE_TYPE == "VIEW")%>%
                arrange(TABLE_NAME)
        
        
        # Get individual data tables
        #----------------------------------------------------------------------------------------
        #sql statements to translate Microsoft Access table into R objects - these will be needed make joined tables to arrive at the required datatable
        tbl_ia_eunis_lut <- sqlQuery(conn, paste("SELECT tblEUNISLUT_inactive.* 
                                            FROM tblEUNISLUT_inactive;"))

        
        tblEUNISPressure_inactive <- sqlQuery(conn, paste("SELECT tblEUNISPressure_inactive.*
                                                 FROM tblEUNISPressure_inactive;"))
        tblEUNISPressure_inactive <- as.data.frame(sapply(X = tblEUNISPressure_inactive, FUN = as.character), stringsAsFactors=FALSE)        
        