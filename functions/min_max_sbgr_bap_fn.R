#Establish the maximum and minimum values for each eunis code by finding the min and max values of the of the "assessed" eunis codes within each: Done by activity/sbgr
# Active code: in double list
sbgr.BAP.max.sens <- xap.ls %>%
        llply(function(x){ # splits list into 9 lists (by activity)
                x %>%
                        llply(function(y){ #splits list into (13) dataframes by sub_biogeoregion
                                max.sens.tbl <- as.tibble(y) %>% 
                                        dplyr::group_by(eunis.code.gis, PressureCode) %>% # want to obtain the minimum and maximum values (comparing betwween eunis.match.assessed) for each for each eunis.code.gis within its sbgr (data is grouped by sbgr, so no need to group_by sbgr here)
                                        dplyr::mutate(max.sens = max(rank.value))%>%
                                        select(ActivityCode, sbgr, PressureCode, eunis.code.gis, eunis.match.assessed, max.sens)%>%#, # maximum sensitivity value, done using mutate to preserve the "eunis.match.assessed" column
                                        slice(1)%>%
                                        ungroup()
                                
                                
                                #max.sens.tbl.2 <- max.sens.tbl %>% dplyr::group_by(eunis.code.gis, PressureCode) %>%
                                #        slice(1)%>%#, # maximum sensitivity value, done using mutate to preserve the "eunis.match.assessed" column
                                #        arrange(ActivityCode, sbgr, PressureCode, eunis.code.gis, eunis.match.assessed, max.sens)
                                
                                #min.sens = min(rank.value[rank.value > 3]),
                                #min.sens.na = min(rank.value)) %>% # minimum sensitity value
                                
                                # keeps only the top value /selects row by position, done to preserve eunis.match.assessed code
                                
                        })
        }, .progress = "text") %>% #now we can reshape the data as follows:
        llply(function(x){#splits by activity, and returns a list split by activity - becuase each activity will be mapped separately
                x %>%
                        ldply(function(y){ #splits list by sub_biogeoregion - and returns a dataframe (per activity - see above), becuase we want to match the senstivities to GIS in one go for all biogeoregions (per activity)
                                y
                        })
        }, .progress = "text")