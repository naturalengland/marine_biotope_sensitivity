# count the number of sensitivity assessments, biotopes assessed and confidence assessments 
# aim: how many data columns

library(sf)
library(tidyverse)
# #this reads in the function that will count the number of columns, based on the data and keyword
source("./functions/post_analyses/keyword_column_count.R") 


#read mapped outputs into R
filtered_biotope_sens <- read_sf("./outputs/habitat_sensitivity_fishing_multiple_sbgr_mosaic.gpkg")
unfiltered_biotope_sens_inshore <- read_sf(dsn = "./outputs/habitat_sensitivity_fishing_mosaic_unfiltered.gpkg", layer = "inshore_fishing_ops_inshore_sens_unfiltered")
unfiltered_biotope_sens_offshore <- read_sf(dsn = "./outputs/habitat_sensitivity_fishing_mosaic_unfiltered.gpkg", layer = "offshore_fishing_ops_inshore_sens_unfiltered")

#user specification: Choose which map to include:
map_dat <- unfiltered_biotope_sens_offshore # USER INPUT: DECIDE WHICH ONE TO PROCESS
        #rm(unfiltered_biotopte_sens, filtered_biotopte_sens)

# Results
## i.e. number of sitivity assessments, biotopes assessed and confidence assessments for all fishing activities
keyword_column_count(x = map_dat, keyword = "sens") # number of columns containing senstivity assessments
keyword_column_count(x = map_dat, keyword = "assess") # number of columns containing assessed biotopte info
keyword_column_count(x = map_dat, keyword = "conf") # number of columns containingconfidence assessments

# to inspect - call the second function in the keyword search function:
keyword_column_names(x = map_dat, keyword = "sens")
