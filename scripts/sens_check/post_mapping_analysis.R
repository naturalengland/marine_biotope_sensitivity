# AIM: quantify the area per senstivity category and plot these
#rm(list=setdiff(ls(), c("map_dat")))

library(sf)
library(tidyverse)
#library(data.table)
library(cowplot)
library(units)

#read mapped outputs into R
filtered_biotope_sens <- read_sf("./outputs/habitat_sensitivity_fishing_multiple_sbgr_mosaic.gpkg")
unfiltered_biotope_sens_inshore <- read_sf(dsn = "./outputs/habitat_sensitivity_fishing_mosaic_unfiltered.gpkg", layer = "inshore_fishing_ops_inshore_sens_unfiltered")
unfiltered_biotope_sens_offshore <- read_sf(dsn = "./outputs/habitat_sensitivity_fishing_mosaic_unfiltered.gpkg", layer = "offshore_fishing_ops_inshore_sens_unfiltered")
#st_layers(dsn ="./outputs/habitat_sensitivity_fishing_mosaic_unfiltered.gpkg")
# 
map_dat <- filtered_biotope_sens # USER INPUT: DECIDE WHICH ONE TO PROCESS
#rm(unfiltered_biotopte_sens, filtered_biotopte_sens)




# ANALYSIS - basic area sums and polygon counts
# select columns of interest - here column splus dredging outputs

map_dat <- map_dat %>% dplyr::select(pkey, 
                                     HAB_TYPE, 
                                     hab_1 = hab.1, 
                                     hab_2 = hab.2, 
                                     hab_3 = hab.3, 
                                     sbgr = bgr_subreg_id,
                                     uncertainty_sim,
                                     contains("Z10_5_"))

# add area to data
# add area calculation (km squared)
map_dat$area_m2 <- st_area(map_dat) %>% set_units(km^2)
map_dat <- map_dat %>% dplyr::rename(area_km2 = area_m2)
map_dat$area <- as.numeric(map_dat$area_km2)
#map_dat$level <- as.integer(map_dat$level)

#area calcs
total_area <- sum(map_dat$area_km2)

total_areas_D2D5D6 <- map_dat %>% 
        dplyr::select(sens_Z10_5_D2, sens_Z10_5_D5, sens_Z10_5_D6, area_km2) %>% 
        st_set_geometry(NULL)
#%>% 
#        dplyr::group_by(sens_Z10_5_D2) %>% 
#        dplyr::summarise(total_areas_km2 = sum(area_km2))

total_areas_D2D5D6$sens_Z10_5_D2[is.na(total_areas_D2D5D6$sens_Z10_5_D2)] <- 0       
total_areas_D2D5D6$sens_Z10_5_D5[is.na(total_areas_D2D5D6$sens_Z10_5_D5)] <- 0       
total_areas_D2D5D6$sens_Z10_5_D6[is.na(total_areas_D2D5D6$sens_Z10_5_D6)] <- 0       
total_areas_D2D5D6$sens_Z10_5_D2 <- as.factor(total_areas_D2D5D6$sens_Z10_5_D2)
total_areas_D2D5D6$sens_Z10_5_D5 <- as.factor(total_areas_D2D5D6$sens_Z10_5_D5)
total_areas_D2D5D6$sens_Z10_5_D6 <- as.factor(total_areas_D2D5D6$sens_Z10_5_D6)

#
total_areas_gathered <- gather(total_areas_D2D5D6, key = "sens_cat", value = "sens_score", -area_km2)
total_areas_gathered$area <- as.numeric(total_areas_gathered$area_km2)

total_areas_gathered$pressure <- ""
total_areas_gathered$pressure[total_areas_gathered$sens_cat == "sens_Z10_5_D2"] <- "Penetration"
total_areas_gathered$pressure[total_areas_gathered$sens_cat == "sens_Z10_5_D5"] <- "Siltation"
total_areas_gathered$pressure[total_areas_gathered$sens_cat == "sens_Z10_5_D6"] <- "Abrasion"

source("./scripts/end_result_analysis/labels_colour_pallette.R")
total_areas_gathered_w_labs <- left_join(total_areas_gathered, labels_df, by = c("sens_score"="value"))


#plot the result
ggplot2::ggplot(data = total_areas_gathered_w_labs, aes(x = label,# values that goes on x-axis
                                                        y = area, # values that goes on y-axis
                                                        )) +
        geom_col(aes(fill = label ))+ #the fill colour depends on the label -value
        xlab("Habitat sensitivity category")+ #x axis title
        ylab("Area (square km)")+ # y-axis title
        scale_fill_manual(values = as.vector(labels_df$color),  #colour values to associate with with categories (colour pallette) - this wil lapear in the legend title (and should match with the x-axis)
                          name = "Habitat sensitivity cateogry:")+ # legend title
                          #labels = as.vector(labels_df$label))+
        # the below positions the axes labels
        theme(axis.text.x = element_text(angle = 60,
                                        hjust = 1,
                                        vjust = 0.98,
                                        margin = margin(t = 0, r= 0, b = 5, l = 0)))+
        theme(axis.text.y = element_text(hjust = 1,
                                         vjust = 0.98,
                                         margin = margin(t = 0, r= 2, b = 0, l = 5)))+
        facet_wrap(~pressure) # splits graph according to pressures



#--------------------------
# proportion of area that is senstive (per pressure category {remove the ",label" for group averages})
total_areas_gathered_w_labs %>% 
        #dplyr::filter(sens_score == 1|sens_score == 2 | sens_score == 3) %>% 
        dplyr::group_by(pressure, label) %>% 
        summarise(prop_area = sum(area)/(as.numeric(total_area)))

total_area_inshore <- total_area
overall_total_area <- total_area_offshore + total_area_inshore
#-----------------------
        
#function to repalce all na values with zero
replace_all_na_with_0 <- function(x){
        is.na(x) <- 0
}

purrr::map_dbl(total_areas_D2D5D6, replace_all_na_with_0)

for (i in seq_along(total_areas_D2D5D6)) {
        replace_all_na_with_0()        
}


#total_areas_D2 %>% st_set_geometry(NULL)
summed_areas_D2 <- total_areas_D2D5D6 %>% dplyr::group_by(sens_Z10_5_D2) %>% 
                dplyr::summarise(total_areas_km2 = sum(area_km2))
#total_areas_D2 %>% st_set_geometry(NULL)
summed_areas_D5 <- total_areas_D2D5D6 %>% dplyr::group_by(sens_Z10_5_D5) %>% 
        dplyr::summarise(total_areas_km2 = sum(area_km2))
#total_areas_D2 %>% st_set_geometry(NULL)
summed_areas_D6 <- total_areas_D2D5D6 %>% dplyr::group_by(sens_Z10_5_D6) %>% 
        dplyr::summarise(total_areas_km2 = sum(area_km2))



prop_areas_D2 <- summed_areas_D2 %>% 
        group_by(sens_Z10_5_D2) %>% 
        summarise(area_percent =total_areas_km2/eval(total_area)*100)
prop_areas_D5 <- summed_areas_D5 %>% 
        group_by(sens_Z10_5_D5) %>% 
        summarise(area_percent =total_areas_km2/eval(total_area)*100)
prop_areas_D6 <- summed_areas_D6 %>% 
        group_by(sens_Z10_5_D6) %>% 
        summarise(area_percent =total_areas_km2/eval(total_area)*100)
join_tmp <- full_join(prop_areas_D2, prop_areas_D5, by = c("sens_Z10_5_D2" = "sens_Z10_5_D5"))
prop_areas_D2D5D6 <- full_join(join_tmp, prop_areas_D6, by = c("sens_Z10_5_D2" = "sens_Z10_5_D6")) %>% 
        dplyr::rename(sens_category = sens_Z10_5_D2,
                      area_percent_D2 = area_percent.x,
                      area_percent_D5 = area_percent.y,
                      area_percent_D6 = area_percent)




#change display - for easier reading of percentages
options("scipen" = 10)
options()$scipen
prop_areas_D2

write.csv(prop_areas_D2D5D6, "./percent_area_senstivity_cat_filtered_inshore_D2D5D6.csv")

#poly calcs

(total_poly <- map_dat %>%
                tally())

(total_polys <- map_dat %>% 
                group_by(sens_Z10_5_D2) %>% 
                dplyr::tally())

prop_poly <- total_polys %>% 
        dplyr::group_by(level) %>% 
        dplyr::summarise(percent_poly = (n/eval(total_poly$n))*100)

#eunis mapped habitat without assessments
prop_poly %>% dplyr::filter(level < 4) %>% 
        summarise(proportion_below_l3 = sum(percent_poly))
#proportion above L4
100- prop_poly %>% dplyr::filter(level < 4) %>% 
        summarise(proportion_below_l3 = sum(percent_poly))


# distinct mapped habitats
## convert to cahracter
map_dat$hab.1 <- as.character(map_dat$hab.1)
map_dat$hab.2 <- as.character(map_dat$hab.2)
map_dat$hab.3 <- as.character(map_dat$hab.3)

hab_categories <- map_dat %>% 
        dplyr::select(hab.1, hab.2, hab.3) %>% 
        replace_na(list(hab.1 = "", hab.2 = "", hab.3 = "")) %>% 
        tidyr::unite("habs", c(hab.1, hab.2, hab.3), sep = "", remove = TRUE) %>% 
        distinct()