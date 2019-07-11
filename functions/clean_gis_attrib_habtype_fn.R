#clean GIS attribute (habitat type) data
clean_hab_type_dat <- function(dat = gis.attr){
        require(dplyr)
        d <- rownames(dat)
        #if(is.null(dat$pkey)) # there are duplcaited pkeys - as this was a column in the GIS, which got split when intersected with sbgr...think about updating the pkey in the GIS
        dat$pkey <- d
        #clean HAB_TYPE column from multiple entries
        dat$HAB_TYPE <- gsub(" or ", "/", dat$HAB_TYPE) # replace ; with / to make consistent
        dat$HAB_TYPE <- gsub(";", "/", dat$HAB_TYPE) # replace ; with / to make consistent
        dat$HAB_TYPE <- gsub("(8)", "", dat$HAB_TYPE) # remove (8) to make consistent
        dat$HAB_TYPE <- gsub(" #", "", dat$HAB_TYPE) # remove " #" to make consistent
        dat$HAB_TYPE <- gsub("\\()$", "", dat$HAB_TYPE) # remove "()" 
        dat$HAB_TYPE <- gsub("^\\.|\\.$", "", dat$HAB_TYPE) # remove "()" 
        #gsub('^\\.|\\.$', '', test)
        
        # Separate HAB_TYPE into multiple columns where "/" appears to allow for the next step
        hab.types <- dat %>%
                select(pkey, HAB_TYPE, bgr_subreg_id = SubReg_id) %>%
                tidyr::separate(HAB_TYPE, into = c("hab.1", "hab.2", "hab.3", "hab.4"), sep = "/", remove = F)
        # Remove any leading or trailing white spaces which could cause problems when matching the eunis columns between gis and database.
        hab.types <- purrr::map_df(hab.types, function(x) trimws(x, which = c("both")))
        str(hab.types) # changed integer top char for all!
        hab.types$pkey <- as.integer(hab.types$pkey)
        
        
        
        #check if there are values in all columns, and drop columns with no values
        hab.types %>%
                distinct(hab.4)
        #remove column 5 hab.4
        hab.types <- hab.types %>% 
                select(-hab.4)
        #only na values - so can be removed
        hab.types %>%
                distinct(hab.3)
        #has multiple values - keep
        hab.types
}