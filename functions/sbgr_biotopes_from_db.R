read.sbgr.db <- function(db.p = db.path, drv.p = drv.path){
        
        #user defined operation filter (move this to the main script, global variables such that the user choooses the operation in teh beginning)
        operation <- as.character(ops.number)
        
        #specificy the connection to the database
        connection.path <- paste0("Driver={",drv.path,"};DBQ=",db.path)#server=",srv.host,"; #server may need to be defined for other SQL database formats
        
        # Connect to Access db to allow reading the data into R environment.
        conn <- odbcDriverConnect(connection.path)
        
        #new-------
        #add sbgr 
        tbl_eunis_sbgr <- sqlQuery(conn, paste("SELECT tblEUNISBiogeoRegion.*
                                                  FROM tblEUNISBiogeoRegion;"))
        tbl_eunis_sbgr <- as.data.frame(sapply(X = tbl_eunis_sbgr, FUN = as.character), stringsAsFactors=FALSE)
        
        
        # read tblBiogeoRegionLUT
        tbl_sbgr <- sqlQuery(conn, paste("SELECT tblBiogeoRegionLUT.*
                                         FROM tblBiogeoRegionLUT;"))
        tbl_sbgr <- as.data.frame(sapply(X = tbl_sbgr, FUN = as.character), stringsAsFactors=FALSE)
        
        
        key_sbgr_codes <- list("1a", "1b", "2a", "2b", "2c", "3a", "3b", "3c","4a", "4b", "4c", "4d", "5")
        #filter key sbgr codes (remove combined sbgr categories - they are not needed, as operations are carried out for individual sbgrs only!)
        tbl_unique_sbgr <- tbl_sbgr %>% 
                filter(SRCode %in% key_sbgr_codes)
        
        #join the unique codes to allow the subregion codes to be joined, then filtered
        tbl_eunis_jn_unique_sbgr <- tbl_eunis_sbgr %>% 
                left_join(tbl_unique_sbgr,
                                     by = "BGRCode")
        
        #filter/remove rows that do not have a subbiogeoregion values (these are empty we removed the combined SR Codes earlier - we do not want these are they represent amalgamations not neccessary for this operation)
        tbl_filtered_eunis_sbgr <- tbl_eunis_jn_unique_sbgr %>%
                filter(!is.na(SRCode))
}
