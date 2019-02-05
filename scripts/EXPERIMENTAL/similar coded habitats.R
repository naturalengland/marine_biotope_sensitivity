#Experimental test which are the similar named habitats

qryEUNIS_ActPressSens %>% filter(grepl("A4.13", EUNISCode, fixed = TRUE), PressureCode == "D6", ActivityName == "Dredges")
