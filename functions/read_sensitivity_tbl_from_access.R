read_sensitivity_lut <- function(db_p = db.path, drv_p = drv.path){
        require(dplyr)
        
        #specificy the connection to the database
        connection_path <- paste0("Driver={",drv_p,"};DBQ=",db_p)#server=",srv.host,"; #server may need to be defined for other SQL database formats
        
        # Connect to Access db to allow reading the data into R environment.
        conn <- odbcDriverConnect(connection_path)
        
        #-------------------
        #define the query to select all columns and values
        tblSensitivityLUT <- sqlQuery(conn , paste("SELECT *
                                                  FROM tblSensitivityLUT;")) 
        
        tbl_sensitivity_lut <- tblSensitivityLUT %>% dplyr::select(rank.value = SensPriority,
                                            ActSensRank)
        
}
