library(tidyverse)

##-----------check after correcting dplyr- stil a problem so will have to redo as started below
act.sbgr.bps.gis$Z10_5_D6[act.sbgr.bps.gis$pkey == "144663"]



#check hab type
hab.types$hab.1[hab.types$pkey == "158108"]

names(xap.ls$Z10.5$`4a`)

#test errors
xap.ls$Z10.5$`4a` %>% 
        filter(eunis.code.gis == "A4.13", grepl("A4.13", eunis.match.assessed, fixed = TRUE), PressureCode == "D6", ActivityCode == "Z10.5") %>%
        group_by(eunis.match.assessed) %>%
        summarise(max.sens = max(rank.value))
# i.e. should be 6 not NA!


sbgr.BAP.max.sens[[5]] %>%
        select(ActivityCode, PressureCode, eunis.code.gis, eunis.match.assessed, max.sens) %>%
        filter(eunis.code.gis == "A4.13", grepl("A4.13", eunis.match.assessed, fixed = TRUE), PressureCode == "D6", ActivityCode == "Z10.5") #%>%
 
sbgr.hab.gis %>% 
        filter(eunis.code.gis == "A4.13", grepl("A4.13", eunis.match.assessed, fixed = TRUE), ActivityCode == "Z10.5") #%>%
        

#problem in script!! it 
#generate a single maximum value per column (there are currently multiple sensitivity scores associated with each)
sbgr.hab.gis.2  <-  sbgr.hab.gis %>%
        ungroup() %>%
        select(-(2:5)) %>% # remove not immediately relevant columns
        group_by(pkey) %>% # group the results by a unique identifier for polygon: "pkey"
        summarise_all(max) #%>% # summarise (obtain the maximum) ALL the remaining columns (according to the grouping); this was key to ensuring that dynamic names operate; if columns 2:5 were needed that could be bound after the fact, as these variables cannot be summarised as they are not numerical
        #select(-(pkey)) #remove the surpuflous variable created from using parse/eval functions.

sbgr.hab.gis.2 %>% 
        filter(pkey == "144663") #%>%



# WORK IN PROGRESS!!!!
### THE JOIN IS A PROBLEM!!! it does not join correctly as tehre are values missing from the database set which activity becomes NA
#join the GIS file to the dataframes coming from sbgr.BAP.max.sens to obtain the ID number for the individual polygons into the data set.
sbgr.hab.gis <- left_join(hab.types, x, by = c("bgr_subreg_id" = "sbgr", "hab.1" = "eunis.code.gis")) %>% #  composite join, e.g.: left_join(d1, d2, by = c("x" = "x2", "y" = "y2"))
        select(pkey, sbgr = bgr_subreg_id, eunis.code.gis = hab.1, eunis.match.assessed, ActivityCode, PressureCode, max.sens) #%>%



#adds column to ID problematic GIS codes
sbgr.hab.gis$missing[is.na(sbgr.hab.gis$eunis.match.assessed)] <- "missing"
sbgr.hab.gis$missing[!is.na(sbgr.hab.gis$eunis.match.assessed)] <- "present"

#to test code QA:
sbgr.hab.gis %>% 
        filter(eunis.code.gis == "A4.13", grepl("A4.13", eunis.match.assessed, fixed = TRUE), ActivityCode == "Z10.5") #%>%


#carry on: 
sbgr.hab.gis.max.long  <-  sbgr.hab.gis %>%
        dplyr::ungroup() %>%
        dplyr::group_by(ActivityCode, PressureCode, sbgr, pkey) %>%
        dplyr::summarise(max.sens.consolidate = max(max.sens, na.rm=TRUE)) %>%
        tidyr::spread(key = PressureCode, value = max.sens.consolidate)
   
#to test code QA:
sbgr.hab.gis.max.long %>% 
        filter(pkey == "144663")

    

#Develop error dataframe to check with James et al
err.join.test <- sbgr.hab.gis %>%
        filter(is.na(eunis.match.assessed)) %>%
        distinct(eunis.code.gis) #%>%
err.join.test <- err.join.test %>% dplyr::rename(EUNISCode = eunis.code.gis)

err.which.hab <- dplyr::left_join(err.join.test, qryEUNIS_ActPressSens, by = "EUNISCode")
#write.csv(err.which.hab, "F:/scratch/tmp/missing_assessments.csv")



