# generate a sensitivity ranking score that will be used to replace characters/strings in sbgr.bap to allow selecting the highest, and lowest sensitivity, and genrate some confidence around this.
library(tidyverse)
sens.rank <- tribble(
        ~rank.value, ~ActSensRank,
        #-------/------------
        1, "Not sensitive",
        2, "Insufficient evidence",
        3, "Not assessed",
        4, "Low",            
        5, "Medium",
        6, "High"
)

