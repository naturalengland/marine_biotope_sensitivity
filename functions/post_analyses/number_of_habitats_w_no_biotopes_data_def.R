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