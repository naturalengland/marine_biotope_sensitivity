#Descriptive Statisticalanalysis for habitat sensitivity
#offshore/inshore
library(tidyverse)
# Number of map stats
sens_maps <- act.sbgr.bps.gis %>%
        select(contains("sens_")) %>%
        dim()
        

# Area stats
dat_an <- hab_map@data %>% 
        select(pkey,
               shape_area = Shape_Area,
               sens = sens_Z10_5_D6, 
               SubReg_id)
total_area <- sum(dat_an$shape_area, na.rm = TRUE)

sens_area <- dat_an %>%
        group_by(sens) %>%
        summarise(area_sens = (sum(shape_area))*12379.77)

saveRDS(sens_area, "./report/sens_area_tbl.RDS")
#Proportion by sub biogeoregion
prop.area.sbgr <- dat_an %>%
        group_by(sens, SubReg_id) %>%#, SubReg_id
        summarise(prop_area_sens = (sum(shape_area))/total_area) %>%
        rename(Sensitivity = sens, Proportion_area = prop_area_sens) 


#Proportion per sensitivity
prop.area <- dat_an %>%
        group_by(sens) %>%#, SubReg_id
        summarise(prop_area_sens = (sum(shape_area))/total_area) %>%
        rename(Sensitivity = sens, Proportion_area = prop_area_sens) 

prop.area$Proportion_area <- round(prop.area$Proportion_area, 4)
#obtain table sens rank previous generated
source("./functions/09_sensitivity_rank.R")

prop_area_tbl <- left_join(sens.rank, prop.area, by = c("rank.value"= "Sensitivity"))
prop_area_tbl <- dplyr::select(prop_area_tbl, Sensitivity = ActSensRank, Proportion_area)
saveRDS(prop_area_tbl, "./report/prop_area_tbl.RDS")
#compare the number of assessed habitats that match HAB_TYPE (i.e. hab.1 - see what it is called - it may undergo a name change and become eunis.gis.code)


#Proportion
largest_sens_poly <- dat_an %>%
        group_by(sens) %>%
        filter(shape_area == max(shape_area)) %>%
        arrange(desc(sens))
