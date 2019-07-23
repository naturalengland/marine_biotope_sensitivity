library(tidyverse)
library(sf)
#check if pressures are different between different activities

#check if outputs are identical - change the ACTIVITY values as needed e.g. below
identical(sens_dat[['sens_Z7_1_D6']],sens_dat[['sens_Z7_17_D6']])
#if FALSE, then there are differences


sens_check <- as.data.frame(as.integer(sens_dat[['sens_Z7_1_D6']]) - as.integer(sens_dat[['sens_Z7_17_D6']]) )
colnames(sens_check) <- c("compare_value")

#this test tries to find out if there are differences between the assessments
sens_check %>% filter(!is.na(compare_value) & compare_value < 0 | !is.na(compare_value) & compare_value > 0)
#this sugegsts that there are datasets where the differences are a result of NA values for some assessments, which were assessed in other data sets


map_the_differences <- sens_dat %>% select(pkey, sens_Z7_1_D6, sens_Z7_17_D6, geom) %>%
        filter(!is.na(sens_Z7_1_D6) & is.na(sens_Z7_17_D6))


st_write(map_the_differences, dsn = "map_the_differences.GPKG", layer = "compare_sens_sbgr_4a_Z7_1_D6_and_sens_Z7_17_D6", delete_layer=TRUE)
plot(map_the_differences["sens_Z7_1_D6"])
plot(map_the_differences["sens_Z7_17_D6"])
plot(map_the_differences["HAB_TYPE"])


compare_dat <- qryEUNIS_ActPressSens %>% 
        filter(PressureCode == "D6" & ActivityCode == "Z7.1"| ActivityCode == "Z7.17" & PressureCode == "D6") %>% 
        arrange(EUNISCode, PressureCode)
