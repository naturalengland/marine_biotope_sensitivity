#clean GIS attribute (habitat type) data
clean_hab_type_dat <- function(dat = gis.attr){
        require(dplyr)
        d <- rownames(dat)
        #if(is.null(dat$pkey)) # there are duplcaited pkeys - as this was a column in the GIS, which got split when intersected with sbgr...think about updating the pkey in the GIS
        dat$pkey <- d
        # ensure HAB_TYPE is character
        dat$HAB_TYPE <- as.character(dat$HAB_TYPE)
        
        #The below line has been disabled as it was decided to reaplce these with "A"...asign no_data to NA in HAB_TYPe column, to allow filtering to remove NA records where no mosiac records occur, but keep na data supplied and thereby retaining the polygon key (pkey) - thi soccurs further down the line
        #dat <- dat %>% mutate_at(vars(contains("HAB_TYPE")), ~replace(., is.na(.), "na_hab"))
        
        #clean HAB_TYPE column from multiple entries
        dat$HAB_TYPE <- gsub(" or ", "/", dat$HAB_TYPE) # replace ; with / to make consistent
        dat$HAB_TYPE <- gsub(".A", "/A", dat$HAB_TYPE) #replace instances where a dot "." preceedes a letter "A" - these are often used in Mosaic habitats - which needs seperating
        dat$HAB_TYPE <- gsub(".B", "/B", dat$HAB_TYPE) #replace instances where a dot "." preceedes a letter "B" - these are often used in Mosaic habitats - which needs seperating
        #dat$HAB_TYPE <- gsub(" /1", "/A1", dat$HAB_TYPE) #replace instances where a 1 follows a dash nca't be sure if it should be A or B though so ignore for now.
        dat$HAB_TYPE <- str_replace_all(dat$HAB_TYPE, "(\\/1)", "\\/A1") # replace instances like: "A1.1122/A1.213A/1.123" with "A1.1122/A1.213A/A1.123"
        dat$HAB_TYPE <- str_replace_all(dat$HAB_TYPE, "(\\/ )", "\\/") # replace instances like: A2.2232/ A2.241 with A2.2232/A2.241 (remove sapce between)
        dat$HAB_TYPE <- gsub(";", "/", dat$HAB_TYPE) # replace ; with / to make consistent
        dat$HAB_TYPE <- gsub("(8)", "", dat$HAB_TYPE) # remove (8) in brackets to make consistent
        dat$HAB_TYPE <- gsub(" #", "", dat$HAB_TYPE) # remove " #" to make consistent
        dat$HAB_TYPE <- gsub("\\()$", "", dat$HAB_TYPE) # remove "()" 
        dat$HAB_TYPE <- gsub("^\\.|\\.$", "", dat$HAB_TYPE) # remove "()" 
        dat$HAB_TYPE <- str_replace_all(dat$HAB_TYPE, "(\\ Mosaic)", "\\")# drops the  space_Mosaic suffix
        dat$HAB_TYPE <- str_replace_all(dat$HAB_TYPE, "(\\ MOSAIC)", "\\")# as above
        dat$HAB_TYPE <- str_replace_all(dat$HAB_TYPE, "(\\ //)", "\\/") #as below
        dat$HAB_TYPE <- str_replace_all(dat$HAB_TYPE, "(\\//)", "\\/") #turns double forward slashes into signles
        
        #gsub('^\\.|\\.$', '', test)
        
        #test %>% # handy to replace wierd instances
        #mutate(., text2 = str_replace_all(text, "(\\w+)", "alias.\\1"))
        
        # Separate HAB_TYPE into multiple columns where "/" appears to allow for the next step
        hab.types <- dat %>%
                select(pkey, HAB_TYPE, bgr_subreg_id = SubReg_id) %>%
                tidyr::separate(HAB_TYPE, into = c("hab_1", "hab_2", "hab_3", "hab_4"), sep = "/", remove = F)
        #tidyr::separate(HAB_TYPE, into = c("hab.1", "hab.2", "hab.3", "hab.4"), sep = "/", remove = F)
        
        # Remove any leading or trailing white spaces which could cause problems when matching the eunis columns between gis and database.
        hab.types <- purrr::map_df(hab.types, function(x) trimws(x, which = c("both")))
        
        #str(hab.types) # changed integer top char for all!
        hab.types$pkey <- as.integer(hab.types$pkey)
              
        #check if there are values in all columns, and drop columns with no values
        hab.types %>%
                distinct(hab_4)
        #remove column 5 hab.4
        hab.types <- hab.types %>% 
                select(-hab_4)
        #only na values - so can be removed
        hab.types %>%
                distinct(hab_3)
        #has multiple values - keep
        hab.types
}
