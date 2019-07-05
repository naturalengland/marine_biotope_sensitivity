# join the pressure to a sbgr-consolidated data set: This code joins pressures within sbgr within an activity, as opposed to activity within sbgr.

xap.ls <- act.press.list %>% 
        plyr::llply(function(y){
                
                
                tidy.p <- y 
                
                sbgr.bap <- sbgr.matched.btpt.w.rpl %>% 
                        plyr::llply(function(x) { 
                                
                                #to reorder the data, and then compile a dataframe
                                
                                # find the position of columns based on their names
                                sbgr.pos <- grep("sbgr", colnames(x))
                                total.columns <- ncol(x)
                                
                                
                                x.df <- x %>% dplyr::select(eunis.code.gis, sbgr, 1:eval(sbgr.pos), eval(sbgr.pos):eval(total.columns)) %>%
                                        tidyr::gather(3:eval(total.columns),key = "eunis.assessed",value = "eunis.gis") %>%
                                        filter(eunis.gis != "<NA>" | eunis.gis != "NA") %>%
                                        select(sbgr, eunis.code.gis, eunis.match.assessed = eunis.assessed) %>%
                                        arrange(sbgr, eunis.code.gis,eunis.match.assessed)
                                
                                
                                xp.df <- right_join(x.df, tidy.p, by = c("eunis.match.assessed" = "EUNISCode"))
                                
                        })
                
                
                return(sbgr.bap)
        }, .progress = "text")
