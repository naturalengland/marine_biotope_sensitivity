# Establish the maximum values for each eunis code by finding the min and max values of the of the "assessed" eunis codes within each: Done by activity/sbgr
# Active code: in double list
sbgr.BAP.max.sens <- xap.ls %>%
        llply(function(x){ # splits list into 9 lists (by activity)
                x %>%
                        llply(function(y){ #splits list into (13) dataframes by sub_biogeoregion

                                        
                                #Assign eunis level to (sensitivity assessed) biotope to deal with cases where multiple biotopes have the same level of sensitivity.
                                y$biotope_level <- nchar(as.character(y$eunis.match.assessed), type = "chars", allowNA = T, keepNA = T)-1 # THIS NEEDS TO BE + 1
                                
                                #filter for maximum sensitivity        
                                all_sens_per_mapped_eunis <- as.tibble(y) %>% 
                                        group_by(eunis.code.gis, PressureCode) %>% 
                                        dplyr::filter(rank.value == max(rank.value)) %>%
                                        ungroup() %>% 
                                        select(ActivityCode, sbgr, PressureCode, eunis.code.gis, eunis.match.assessed, max.sens = rank.value, biotope_level)%>%#, # maximum sensitivity value, done using mutate to preserve the "eunis.match.assessed" column
                                        arrange(PressureCode, eunis.code.gis, eunis.match.assessed)
                                
                                # filter by assessed biotope of lowest EUNIS level - as this will make fewer assumption when being assigned.
                                max.sens.tbl <- all_sens_per_mapped_eunis %>% 
                                        filter(!is.na(eunis.code.gis)) %>% 
                                        group_by(PressureCode, eunis.code.gis, max.sens) %>% 
                                        dplyr::filter(biotope_level == min(biotope_level)) %>% 
                                        slice(1) %>% 
                                        ungroup() 
                                
                        })
        }, .progress = "text") %>% #now we can reshape the data as follows:
        llply(function(x){#splits by activity, and returns a list split by activity - becuase each activity will be mapped separately
                x %>%
                        ldply(function(y){ #splits list by sub_biogeoregion - and returns a dataframe (per activity - see above), becuase we want to match the senstivities to GIS in one go for all biogeoregions (per activity)
                                y
                        })
        }, .progress = "text")


#REMOVE - this produced incorrect result - the slice method to obtain one record per grouping cuased problems - the max_sens was not the corresponding value with the biotope selected
#max.sens.tbl <- as.tibble(y) %>% 
#        dplyr::group_by(eunis.code.gis, PressureCode) %>% # want to obtain the minimum and maximum values (comparing betwween eunis.match.assessed) for each for each eunis.code.gis within its sbgr (data is grouped by sbgr, so no need to group_by sbgr here)
#        dplyr::mutate(max.sens = max(rank.value))%>%
#        select(ActivityCode, sbgr, PressureCode, eunis.code.gis, eunis.match.assessed, max.sens)%>%#, # maximum sensitivity value, done using mutate to preserve the "eunis.match.assessed" column
#        slice(1)%>%
#       ungroup() %>% 
