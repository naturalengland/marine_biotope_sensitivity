# Obtain the maximum sensitivity for each POLYGON (from the GIS habitat file)
act.sbgr.bps.gis <- sbgr.BAP.max.sens %>%
        llply(function(x){ # split the list into its dataframes (by activity), and provide a list at the end (containing dataframes) (which are eventaully piped onto bind_cols into a single dataframe /preferred over ldply as this would cause row bind, not column bind.
                require(stringr)
                require(dplyr)
                require(tidyr)
                
                #join the GIS file to the dataframes coming from sbgr.BAP.max.sens to obtain the ID number for the individual polygons into the data set.
                sbgr.hab.gis <- dplyr::left_join(hab.types, x, by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis")) %>% #  composite join, e.g.: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))
                        dplyr::select(pkey, sbgr = bgr_subreg_id, eunis.code.gis = hab.1, eunis.match.assessed, ActivityCode, PressureCode, max.sens)

                
                
                #generate a single maximum value per column (there are currently multiple sensitivity scores associated with each)
                sbgr.hab.gis.2  <-  sbgr.hab.gis %>%
                        dplyr::ungroup() %>%
                        dplyr::group_by(PressureCode, pkey) %>%
                        dplyr::summarise(max.sens.consolidate = max(max.sens, na.rm=TRUE)) %>%
                        tidyr::spread(key = PressureCode, value = max.sens.consolidate)
                
                
                # Make unique names for each dataframe so that they can be put into a single data frame at the end:
                ## Activity code based names: append activity code to the names
                act.code <- unique(as.character(x$ActivityCode[!is.na(x$ActivityCode)])) # obtain the unique activity codes, excluding any NA values.
                orig.names <- names(sbgr.hab.gis.2[,-1]) # obtain the original names for the columns
                new.names <- c(names(sbgr.hab.gis.2[,1]),str_c(act.code, orig.names, sep = "_")) 
                new.names.2 <- str_replace(new.names,"[.]","_") # change points to underscores to make them database compatable
                names(sbgr.hab.gis.2) <- new.names.2 # set the names to names 2
                #print("Activity code: ", act.code," should have the same number of rows as the there are polygons in the habitat map. Check this value matches the expected number of rows", nrow(sbgr.hab.gis.2)) # error checking: if more than 804043 - there are duplicates records remaining in the dataframes - this is what needs fixing to complete it!
                
                
                ##REMOVE columns with <NA> in name
                #drop columns with NA for name (these may have arised in datasets where NA occured in the PressureCode column which were assigned NA if they were not present)
                try(sbgr.hab.gis.2 <- sbgr.hab.gis.2 %>% select(-ends_with('<NA>'))) # this finds columns that ends with: ...<NA> and removes them
                
                #Add heat map values (not presently used)
                #heatmap.vls <- sbgr.hab.gis %>%
                #        dplyr::ungroup() %>%
                #        dplyr::group_by(pkey) %>%
                #        dplyr::summarise(heat.sum = sum(max.sens, na.rm=TRUE))
                
                #add activity code to names to mke it distinct for each activity
                #act_code <- str_replace(act.code,"[.]","_")
                #names(heatmap.vls) <- c("pkey", paste0("heat_vl_",act_code))
                
                
                #bind heatmap values to pressure sensitivity table
                #sbgr.hab.gis.3 <- sbgr.hab.gis.2 %>%
                #        left_join(heatmap.vls, by = "pkey") #call the dataframe to ensure tha this is waht is saved in the end
                
                
                sbgr.hab.gis.2
                
        }, .progress = "text") %>% #provides an indication of progress in executing the code. 
        bind_cols() %>% # binds the results (columns) from each list, keeping the original identifier as the main id.
        dplyr::select(-one_of("pkey1", "pkey2", "pkey3", "pkey4", "pkey5", "pkey6", "pkey7","pkey8"))
