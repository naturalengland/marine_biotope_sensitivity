# Obtain the maximum sensitivity for each POLYGON (from the GIS habitat file)
act.sbgr.bps.gis <- sbgr.BAP.max.sens %>%
        llply(function(x){ # split the list into its dataframes (by activity), and provide a list at the end (containing dataframes) (which are eventaully piped onto bind_cols into a single dataframe /preferred over ldply as this would cause row bind, not column bind.
                require(tidyverse)
                require(stringr)
                require(tidyr)
                require(RODBC)
                require(DBI)
                source("./functions/name_column_fn.R")
                
                #join the GIS file to the dataframes coming from sbgr.BAP.max.sens to obtain the ID number for the individual polygons into the data set.
                sbgr.hab.gis <- dplyr::left_join(hab.types, x, by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis")) %>% #  composite join, e.g.: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))
                        dplyr::select(pkey, sbgr = bgr_subreg_id, eunis.code.gis = hab.1, eunis.match.assessed, ActivityCode, PressureCode, max.sens)

                
                #------------------------
                # script to associate confidence scores
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
                
                # Obtain the maximum habitat sensitivity per polygon, and retain the assessed EUNIS habitat and the assocaited confidence score of the habitat with the maximum sensitivity
                sbgr.hab.max.sens.assessed  <-  sbgr.hab.gis %>%
                        dplyr::ungroup() %>%
                        dplyr::group_by(PressureCode, pkey) %>%
                        dplyr::summarise(max.sens.consolidate = max(max.sens, na.rm=TRUE), eunis.match.assessed) 
                
                #join confidence of eunis habitats to the assessed eunis habitat
                sbgr.hab.max.sens.assessed.conf <- dplyr::left_join(sbgr.hab.max.sens.assessed, confidence_sens_eunis, by = c("PressureCode" = "PressureCode", "eunis.match.assessed" = "EUNISCode"))
                
                #--------------------------
                #Remove if below works:
                #generate a single maximum value per column (there are currently multiple sensitivity scores associated with each)
                #sbgr.hab.gis.spread  <-  sbgr.hab.gis %>%
                #        dplyr::ungroup() %>%
                #        dplyr::group_by(PressureCode, pkey) %>%
                #        dplyr::summarise(max.sens.consolidate = max(max.sens, na.rm=TRUE)) %>%
                #        tidyr::spread(key = PressureCode, value = max.sens.consolidate)
                
                #generate a single maximum value per column (there are currently multiple sensitivity scores associated with each)
                sbgr.hab.gis.spread <- sbgr.hab.max.sens.assessed.conf %>%
                        dplyr::select(PressureCode, pkey, max.sens.consolidate) %>%
                        tidyr::spread(key = PressureCode, value = max.sens.consolidate)
                sbgr.hab.gis.spread <- column_naming_fn(x = x, w= sbgr.hab.gis.spread, prfix = "sens")
                
                #catch EUNIS assessed of assessed habitat with max sensitivity
                sbgr.hab.assessed.spread  <-  sbgr.hab.max.sens.assessed.conf %>%
                        dplyr::select(PressureCode, pkey, eunis.match.assessed) %>%
                        tidyr::spread(key = PressureCode, value = eunis.match.assessed)
                sbgr.hab.assessed.spread  <- column_naming_fn(x = x, w = sbgr.hab.assessed.spread, prfix = "assessed_hab")
        
                
                # catch confidence of assessed habitat with max sensitivity
                sbgr.hab.conf.spread  <-  sbgr.hab.max.sens.assessed.conf %>%
                        dplyr::select(PressureCode, pkey, SensitivityQoE) %>%
                        tidyr::spread(key = PressureCode, value = SensitivityQoE)
                sbgr.hab.conf.spread <- column_naming_fn(x = x, w = sbgr.hab.conf.spread, prfix = "conf")
                
                #join three datasets together
                sbgr.hab.gis.tmp <- left_join(sbgr.hab.gis.spread, sbgr.hab.assessed.spread, by = "pkey")
                sbgr.hab.gis.assessed.conf.spread <- left_join(sbgr.hab.gis.tmp, sbgr.hab.conf.spread, by = "pkey")
                
                
                
#--------------------------
                
                
                
                
                #Remove below from final product/only for testing
                # Error test: there are too many NA values being produced - I am not sure why. the code below isolates a single polygon with pkey 601959 - which from the map we know appears as if missing data 
                #create subset from data
                #test.dat <- sbgr.hab.gis %>%
                #        filter(pkey == "601959")
                
                #test.dat.spread <- test.dat %>%
                #        dplyr::ungroup() %>%
                #        dplyr::group_by(PressureCode,pkey) %>%
                #        dplyr::summarise(max.sens.consolidate = max(max.sens, na.rm = TRUE)) %>%
                #        tidyr::spread(key = PressureCode, value = max.sens.consolidate)
                        
                #compare
                #sbgr.hab.gis.spread %>%
                #        filter(pkey == "532659") # seems to be correct # 601959
                
                #compare
                #test.result <- act.sbgr.bps.gis %>%
                #        filter(pkey == "601959") # seems to be correct
                
                
                # Make unique names for each dataframe so that they can be put into a single data frame at the end:
                ## Activity code based names: append activity code to the names
                #act.code <- unique(as.character(x$ActivityCode[!is.na(x$ActivityCode)])) # obtain the unique activity codes, excluding any NA values.
                #orig.names <- names(sbgr.hab.gis.spread[,-1]) # obtain the original names for the columns
                #new.names <- c(names(sbgr.hab.gis.spread[,1]),str_c(act.code, orig.names, sep = "_")) 
                #new.names.2 <- str_replace(new.names,"[.]","_") # change points to underscores to make them database compatable
                #names(sbgr.hab.gis.spread) <- new.names.2 # set the names to names 2
                ##REMOVE columns with <NA> in name
                #drop columns with NA for name (these may have arised in datasets where NA occured in the PressureCode column which were assigned NA if they were not present)
                #try(sbgr.hab.gis.spread <- sbgr.hab.gis.spread %>% select(-ends_with('<NA>'))) # this finds columns that ends with: ...<NA> and removes them
                
                
                
                
                #Add heat map values (not presently used)
                #heatmap.vls <- sbgr.hab.gis %>%
                #        dplyr::ungroup() %>%
                #        dplyr::group_by(pkey) %>%
                #        dplyr::summarise(heat.sum = sum(max.sens, na.rm=TRUE))
                
                #add activity code to names to mke it distinct for each activity
                #act_code <- str_replace(act.code,"[.]","_")
                #names(heatmap.vls) <- c("pkey", paste0("heat_vl_",act_code))
                
                
                #bind heatmap values to pressure sensitivity table
                #sbgr.hab.gis.3 <- sbgr.hab.gis.spread %>%
                #        left_join(heatmap.vls, by = "pkey") #call the dataframe to ensure tha this is what is saved in the end
                
                
                sbgr.hab.gis.assessed.conf.spread
                
        }, .progress = "text") %>% #provides an indication of progress in executing the code. 
        bind_cols() %>% # binds the results (columns) from each list, keeping the original identifier as the main id.
        dplyr::select(-one_of("pkey1", "pkey2", "pkey3", "pkey4", "pkey5", "pkey6", "pkey7","pkey8"))
