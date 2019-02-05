#link the sbgr.BAP.min.max.sens to the GIS, producing a single flat file with all pressures from a set of activities stored as individual attributes.

library(plyr)
library(tidyverse)
library(stringr)

# Define variables:
group.by <- parse(text = "pkey") ## Set text = "ogc_fid" or any other unique identifier in the GIS file. It generates a field name taht is easy to cahnge - unique ID for polygons.


# Obtain the maximum sensitivity for each POLYGON (from the GIs habitat file)
act.sbgr.bps.gis <- sbgr.BAP.max.sens %>%
        llply(function(x){ # split the list into its dataframes, and provide a list at the end (containing dataframes) (which are eventaully piped onto bind_cols into a single dataframe /preferred over ldply as this would cause row bind, not column bind.
                
                
                #Test code - remove once the script is working:#test code only - to test a single matrix at a time
                #x <- sbgr.BAP.max.sens[[1]] 
                
                #join the GIS file to the dataframes coming from sbgr.BAP.max.sens to obbtain the ID number for the individual polygons into the data set.
                sbgr.hab.gis <- left_join(hab.types, x, by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis")) %>% #  composite join, e.g.: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))
                        select(pkey, sbgr = bgr_subreg_id, eunis.code.gis = hab.1, eunis.match.assessed, ActivityCode, PressureCode, max.sens) %>%
                        spread(key = PressureCode, value = max.sens)
                
                #drop columns with NA for name (these may have arised in datasets where NA occured in the PressureCode column which were assigned NA if they were not present)
                sbgr.hab.gis <- sbgr.hab.gis %>% select(-("<NA>"))
                
                #generate a single maximum value per column (there are currently multiple sensitivity scores associated with each)
                sbgr.hab.gis.2  <-  sbgr.hab.gis %>%
                        select(-(2:5)) %>% # remove not immediately relevant columns
                        group_by(eval(group.by)) %>% # group the results by a unique identifier for polygon: "pkey"
                        summarise_all(max) %>% # summarise (obtain the maximum) ALL the remaining columns (according to the grouping); this was key to ensuring that dynamic names operate; if columns 2:5 were needed that could be bound after the fact, as these variables cannot be summarised as they are not numerical
                        select(-(`eval(group.by)`)) #remove the surpuflous variable created from using pasre/eval functions.
                
                
                # Make unique names for each dataframe so that they can be put into a single data frame at the end:
                ## Activity code based names: append activity code to the names
                act.code <- unique(as.character(x$ActivityCode[!is.na(x$ActivityCode)])) # obtain the unique activity codes, excluding any NA values.
                orig.names <- names(sbgr.hab.gis.2[,-1]) # obtain the original names for the columns
                new.names <- c(names(sbgr.hab.gis.2[,1]),str_c(act.code, orig.names, sep = "_")) 
                new.names.2 <- str_replace(new.names,"[.]","_") # change points to underscores to make them database compatable
                names(sbgr.hab.gis.2) <- new.names.2 # set the names to names 2
                sbgr.hab.gis.2 #call the dataframe to ensure that this is waht is saved in the end
                
                
                
                
        }, .progress = "text") %>% #provides an indication of progress in executing the code. 
        bind_cols() # binds the results (columns) from each list, keeping the original identifier as the main id.

rm(hab.types)
#check that the number of observations match the number of observations in the hab.map which whoudl also be the sam eas the gis.attr and hab.types