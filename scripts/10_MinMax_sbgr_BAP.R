#extract sensitivity scores (maximum, minimum (with a cap) from sbgr_bap): working with XAP instead
library(plyr)
library(tidyverse)

#test----------------------
#tmp <- sbgr.bap[[1]][[1]]

#max.sens.test <- as.tibble(tmp) %>% 
#        dplyr::group_by(eunis.code.gis, PressureCode) %>%
#        dplyr::mutate(max.sens = max(rank.value), # maximum sensitivity value, done using mutate to preserve the "eunis.match.assessed" column
#                      min.sens = min(rank.value[rank.value > 3]),
#                      min.sens.na = min(rank.value)) %>% # minimum sensitity value
#        slice(1) # keeps only the top value /selects row by position, done to preserve eunis.match.assessed code

#[myvector > 0]

#appears to be able to take care of both max and min in one code, and preserve the correct/or at least same eunis.match.assessed       
#min.sens.test <- as.tibble(tmp) %>% 
#        dplyr::group_by(eunis.code.gis, PressureCode) %>%
#        dplyr::mutate(min.sens = min(rank.value)) %>% # minimum sensitity value
#        slice(1) # keeps only the top value /selects row by position, done to preserve assessed eunis code


source(file = "./functions/min_max_sbgr_bap.R")


rm(xap.ls)