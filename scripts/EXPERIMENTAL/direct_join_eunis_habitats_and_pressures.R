# Direct join between assessments and habitats - look slike this
library(tidyverse)


hab_types$habs

qryEUNIS_ActPressSens$EUNISCode




test <- left_join(hab_types, act.press.list[[6]], by = c("habs" = "EUNISCode"))


direct_join_eunis_habs_sens_assess <- act.press.list %>%
        llply(function(x){ # splits list into 9 lists (by activity)
                
                y <- split(x, f = x$PressureCode)
                
                y %>% 
                        llply(function(z){
                        
                                full_suit_habs <- left_join(hab_types, z, by = c("habs" = "EUNISCode"))        
                                max_sens_habs <- full_suit_habs %>% as.tibble(y) %>% 
                                        group_by(pkey) %>% 
                                        dplyr::filter(rank.value == min(rank.value)) %>% #the lowest rank number has the highest sensitivity in the Access database - so, this was changed from a max filter to a min filter! (I used supply a custom table, but now it is being read from the Access db to avoid not detecting a change in the system)
                                        ungroup() %>% 
                                        arrange(pkey)
                                
                        })
                        
        }, .progress = "text")
                