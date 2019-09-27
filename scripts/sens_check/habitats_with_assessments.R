# hab_types  with NA outcomes

habitat_types_with_no_biotopes_in_sbgr_Z7_1_D6 <- sens_dat %>% filter(is.na(sens_Z7_1_D6)) %>% 
        select(HAB_TYPE, hab.1, sens_Z7_1_D6) %>% 
        distinct()


habitat_types_with_no_biotopes_in_sbgr_Z7_1_D6 <- sbgr.BAP.max.sens[[1]] %>% filter(is.na(max.sens)) %>% 
        select(eunis.code.gis, eunis.match.assessed, max.sens) %>% 
        distinct()

habitat_types_with_no_biotopes_in_sbgr <- purrr::map_df(sens_dat)

# a function that finds missing values - these will be the data deficient values - and then identifies and counts thenumber of biotopes
library(sf)
library(tidyverse)
library(stringr)

is_data_deficient <- function(x, keyword = "assessed_hab_Z"){
        
        x %>% st_set_geometry(NULL) %>% #set geomotry null to make it quick!
                select(HAB_TYPE, contains(eval(keyword))) %>% 
                tidyr::gather(key = "pressure_code_tmp",
                              value = "biotope", -HAB_TYPE) %>% 
                dplyr::filter(is.na(biotope)) %>% 
                group_by(pressure_code_tmp) %>% 
                distinct() %>% 
                dplyr::summarise(n())
                
                
}

x <- unfiltered_biotope_sens_offshore
