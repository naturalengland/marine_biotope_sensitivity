# join the pressure to a sbgr-consolidated data set: This code joins pressures within sbgr within an activity, as opposed to activity within sbgr.
#libraries
library(plyr)
library(dplyr)
library(magrittr)


source(file = "./functions/join_pressure_to_sbgr_list.R")

#housekeeping: remove objects no longer required
rm(sbgr.matched.btpt.w.rpl)

#saveRDS(xap.ls,"./output/xap_ls.rds") # not saving this any longer - as the code works, and this is an intermediate data set.
