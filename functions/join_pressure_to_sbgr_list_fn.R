# join the pressure to a sbgr-consolidated data set: This code joins pressures within sbgr within an activity, as opposed to activity within sbgr.


xap.ls <- act.press.list %>% # the below statement splits the activitiy_pressure_list (act.press.lst) - so as to be able to treat each sbgr at a time - and then in the end merges them back into a list of dataframes.
        plyr::llply(function(y){
                
                
                tidy.p <- y # passes y (see above) to a named R object before it goes into the next statement - not sure it is 100 % neccessary, but this way I can be sure that it is retaining the correct values
                
                sbgr.bap <- sbgr.matched.btpt.w.rpl %>% # the below statement splits the list of biotopes-mated-tomapped-eunis-habitat-codes-within-sbgr into each sbgr - so that it can be treated one sbgr at a time. In then end of this, it merges the sbgrs back into a list of dataframes, which are nested within the list started above
                        plyr::llply(function(x) { 
                                
                                # to reorder the data (biotopes-matched-to-mapped-eunis-habitat-codes-within-sbgr) {one dataframe at a time} - I did this becuase it was odd having the GIS columns at the end, and makes it awkward calling later in the script.
                                
                                # In order to reorder the columns, I need to be able to specify the position of olumns and the total number of columns
                                sbgr_pos <- grep("sbgr", colnames(x)) #find the position of columns based on their names (which is the EUNIS codes for the biotope (eunis lvl 4,5 or 6))
                                total_columns <- ncol(x)-2  # find the total number of columns in the dataframe. We -2 to get rid of the h.lvl and l.lvl columns no longer needed.
                                
                                
                                x.df <- x %>% dplyr::select(-h_lvl, -l_lvl) %>% #drop the h.lvl and l.lvl columns as they are no longer needed, and will cuase problems if carried forward
                                        dplyr::select(eunis_code_gis, sbgr, 1:eval(sbgr_pos), eval(sbgr_pos):eval(total_columns)) %>% #select columns in the order in which I want them, putting eunis.code.gis, sbgr first. (using eval command to detect the name as set above to detect its position, and using it to denote from:to in the slect command)
                                        tidyr::gather(3:eval(total_columns),key = "eunis.assessed",value = "eunis.gis") %>% # this makes the data "tidy" 
                                        filter(eunis.gis != "<NA>" | eunis.gis != "NA") %>% #this removes NA values in the MAPPED eunis GIs column - becuase they cannot be assigned biotopes - they are unknown afterall
                                        select(sbgr, eunis_code_gis, eunis.match.assessed = eunis.assessed) %>%
                                        arrange(sbgr, eunis_code_gis,eunis.match.assessed)
                                
                                #----------------------------
                                #Join the reordered dataframe to the activity-pressure dataframe based on the EUNIs code (which was selected ) (Note this happens multiple times - i.e. for each of the dataframes in the list)
                                xp.df.p <- right_join(x.df, tidy.p, by = c("eunis.match.assessed" = "EUNISCode")) %>% # As the final command in this plyr-loop, this value is then attributed to sbgr.bap. It is repeated for each dataframe in the list.
                                        dplyr::distinct() #removes any duplciates that may arise from joining processes
                        })
                
                
                return(sbgr.bap) #sbgr.bap is again nested within a plyr loop, and therefore needs calling here to ensure that this value is passed into xap.ls as a dataframe. It is repeated for each dataframe in the list.
        }, .progress = "text")
