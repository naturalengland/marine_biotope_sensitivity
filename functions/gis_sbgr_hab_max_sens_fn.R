# Associate the maximum sensitivity, confidence score and biotope to the habitat type of each polygon (from the GIS habitat file)

act.sbgr.bps.gis <- sbgr.BAP.max.sens %>%
        llply(function(x){ # split the list into its dataframes (by activity), and provide a list at the end (containing dataframes) (which are eventaully piped onto bind_cols into a single dataframe /preferred over ldply as this would cause row bind, not column bind.
                require(tidyverse)
                require(stringr)
                require(tidyr)
                require(RODBC)
                require(DBI)
                source("./functions/name_column_fn.R") # this is function that renames the columns in a bespoke way
                
                
                # Background note: The "sbgr.BAP.max.sens" is passed through as variable "x", one data from from the list at a time. for example sbgr.BAP.max.sens[[1]]
                
                #------------
                # Clean incoming data
                
                # Generates a list of unassessed biotope associations fro mmissing pressures codes:
                Unassessed.biotopes <- x %>% filter(is.na(PressureCode))
                
                # To remove them:
                x %<>% filter(!is.na(PressureCode)) #removes the NA pressure group; # Note that the data has unassessed biotopes that have been assocaited with habitats, they will show up as NA in database, and not be expanded to include all the PressureCodes per Activity
                #------------
                
                # JOIN TO GIS HABITAT INFO:
                # Join the (previously prepared) GIS based habitat information to the (sbgr-biotope-activity-pressure-sensitivity-assessments) dataframes coming from sbgr.BAP.max.sens (x) to obtain the ID number (pkey) for the individual polygons into the data set.
                sbgr.hab.gis <- dplyr::left_join(hab.types, x, by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis")) %>% #  composite join, e.g.: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))
                        dplyr::select(pkey, sbgr = bgr_subreg_id, eunis.code.gis = hab.1, eunis.match.assessed, ActivityCode, PressureCode, max.sens)
                # NB! note: at this point there are multiple sensitivity values associated with each polygon pkey, becuase there are multiple potential biotopes which could have sens assessments and be associated to mapped habitats per sbgr.
                
                #------------
                
                # DATA PRE-PROCESSING:

                # Introduce dummy variable for values that are missing becuase the habitat has not been assessed.
                sbgr.hab.gis$eunis.match.assessed[is.na(sbgr.hab.gis$eunis.match.assessed)] <- "no_biotope_assigned"
                sbgr.hab.gis$PressureCode[is.na(sbgr.hab.gis$PressureCode)] <- "not_assessed"
                sbgr.hab.gis$max.sens[is.na(sbgr.hab.gis$max.sens)] <- "not_assessed"
                
                #-------------
                
                # OBTAIN SINGLE MAXIMUM SENSITIVITY PER POLYGON/PRESSURE:
                
                # Filter rows keeping the ones associated with the maximum value for sensitivity (for each polygon/pressure), retaining the additional row information (such as assessed habitat)
                sbgr.hab.max.sens.assessed  <-  sbgr.hab.gis %>%
                        dplyr::ungroup() %>%
                        dplyr::group_by(PressureCode, pkey) %>%# Point of error: this is where the polygons are removed - see tests.! we need to assign dummy values for NA or they will be removed!
                        dplyr::filter(max.sens == min(max.sens)) %>% #Note that the minimum rank value represents the highest sensitivity level 1 = high, 6 = not sensitive
                        dplyr::rename(max.sens.consolidate = max.sens) # at this point, there should be only one maximum sensitivity associated with each of the unique combinations of pkey, pressure
                
                #------------------------
                # ASSOCIATE CONFIDENCE SCORES WITH SENSITIVITY ASSESSMENTS:
                
                # Set connection to database
                
                # set pathways to database and driver software:
                db.p  <-  db.path #this was originally specified in the main script by the user
                drv.p <-  drv.path #this was originally specified in the main script by the user
                
                # sset the connection variables to the MS Access database, based on the variables supplied by the user - see above
                connection.path <- paste0("Driver={",drv.path,"};DBQ=",db.path)#server=",srv.host,"; #server may need to be defined for other SQL database formats
                
                # Connect to MS Access db to allow reading the data into R environment.
                conn <- odbcDriverConnect(connection.path)
                
                #sql statements to translate Microsoft Access table into R objects - these will be needed make joined tables to arrive at the required datatable
                tblEUNISPressure <- sqlQuery(conn, paste("SELECT tblEUNISPressure.*
                                       FROM tblEUNISPressure;"))
                tblEUNISPressure <- as.data.frame(sapply(X = tblEUNISPressure, FUN = as.character), stringsAsFactors=FALSE)
                
                #select only the fields of interest around the confidence assessments rom the database table to make the data easier to work with:
                confidence_sens_eunis <- tblEUNISPressure %>%
                        dplyr::select(EUNISCode, PressureCode, SensitivityQoE) %>%
                        distinct()
                
                #remove the database table
                rm(tblEUNISPressure)
                
                # Note: The "confidence_sens_eunis" is the object containing the confiedence assessments that will be passed on.
                
                #------------------------------------
                
                # Join confidence of eunis habitats to the assessed eunis habitat:
                sbgr.hab.max.sens.assessed.conf <- dplyr::left_join(sbgr.hab.max.sens.assessed, confidence_sens_eunis, by = c("PressureCode" = "PressureCode", "eunis.match.assessed" = "EUNISCode")) # confidence of sensitivity varies with only the pressure - so only these two are needed as grouping variables.
                rm(sbgr.hab.max.sens.assessed) # remove pre-curser (no longer needed), sbgr.hab.max.sens.assessed.conf is passed onto next steps
                
                #------------------------------------
                
                # GENERATE A TABLE WITH NO REPLICATION OF THE PKEY
                
                # ...so that it can be joined to the GIS files as a flat file (i.e. no replication of pkey which will be used to associate with the GIS file.
                # The output should be a SINGLE MAXIMUM VALUE PER PRESSURE/PKEY COMBINATION.
                # it was made from the "sbgr.hab.max.sens.assessed.conf" which contains only one maximum sensitivity per pressure/pkey combination.
                
                sbgr.hab.gis.spread <- sbgr.hab.max.sens.assessed.conf %>%
                        dplyr::select(PressureCode, pkey, max.sens.consolidate) %>% # keep the column id (pressure), row id (pkey), and the value that we want to populate into the table
                        tidyr::spread(key = PressureCode, value = max.sens.consolidate) # this reorganises the data according to the above comment - see the tidyr function for the details
                sbgr.hab.gis.spread <- column_naming_fn(x = x, w= sbgr.hab.gis.spread, prfix = "sens") # this runs, and provides the data for the function to rename the columns. see the function read in a tthe start fo rhow this works
                
                # Repeating the above, but the EUNIS assessed of assessed habitat with max sensitivity, as opposed to the maximum sensitivity itself
                sbgr.hab.assessed.spread  <-  sbgr.hab.max.sens.assessed.conf %>% # this reorganises the data according to the above comment - see the tidyr function for the details
                        dplyr::select(PressureCode, pkey, eunis.match.assessed) %>% # keep the column id (pressure), row id (pkey), and the value that we want to populate into the table
                        tidyr::spread(key = PressureCode, value = eunis.match.assessed) # this runs, and provides the data for the function to rename the columns. see the function read in a tthe start fo rhow this works
                sbgr.hab.assessed.spread  <- column_naming_fn(x = x, w = sbgr.hab.assessed.spread, prfix = "assessed_hab")
        
                
                # Repeating again...this time for the confidence of assessed habitat with max sensitivity
                sbgr.hab.conf.spread  <-  sbgr.hab.max.sens.assessed.conf %>% # see the comments from the previous two paragraphs - it works the same
                        dplyr::select(PressureCode, pkey, SensitivityQoE) %>%
                        tidyr::spread(key = PressureCode, value = SensitivityQoE)
                sbgr.hab.conf.spread <- column_naming_fn(x = x, w = sbgr.hab.conf.spread, prfix = "conf")
                
                rm(sbgr.hab.max.sens.assessed.conf) #house-keeping, no longer need this.
                
                # REMOVED  CODE - kept here for legacy sake, but can remove in master copy
                #--------------------------
                # Calculate HEAT MAP values - sum of all pressures maximum sensitivity scores (per activity) (not presently used, as the additivity of these pressures is questionable)
                #heatmap.vls <- sbgr.hab.max.sens.assessed.conf %>%
                #        dplyr::ungroup() %>%
                #        dplyr::group_by(pkey) %>%
                #        dplyr::summarise(heat.sum = sum(max.sens, na.rm=TRUE))
                #--------------------------------
                
                # JOIN THE SENSITIVITY ASSESSMENTS, CONFIDENCE & BIOTOPES ASSESSED INTO A TABLE
                
                sbgr.hab.gis.tmp <- left_join(sbgr.hab.gis.spread, sbgr.hab.assessed.spread, by = "pkey") # tip: this are temporary file containing sensitivity assesments and the confidence assessments, which is only used to join to the next
                sbgr.hab.gis.assessed.conf.spread <- left_join(sbgr.hab.gis.tmp, sbgr.hab.conf.spread, by = "pkey") # now it contains sensitivity assessments, confidence assesments, and biotopes assessed.
                
                rm(sbgr.hab.gis.spread, sbgr.hab.assessed.spread, sbgr.hab.conf.spread, sbgr.hab.gis.tmp) #house-keeping, no longer need this.
                
                # NB TIP! Call the final result as the las tline of the code in the function becase this is what gets stored as output from the function.
                sbgr.hab.gis.assessed.conf.spread
                
        }, .progress = "text") %>% # provides an indication of progress in executing the code. 
        bind_cols() %>% # binds the results (columns) from each list, keeping the original identifier as the main id.
        dplyr::select(-one_of("pkey1", "pkey2", "pkey3", "pkey4", "pkey5", "pkey6", "pkey7","pkey8"))





