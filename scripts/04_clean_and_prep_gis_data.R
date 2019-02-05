#Clean geodata file; done from attribute table - i.e. remove the geomotry to make the file small and managable to work with.
#to do: functionalise: make gis.hab.bgr.dat a changable variable:#specify unique id and other variables

library(tidyverse)

#function that loads teh GIs attributes from the GIs file (seperate it foreasier manipulation).Reads file from specified locality, or defaults to a back-up locality,
source(file = "./functions/load_gis_atributes_fn")
gis.attr <- load.gis.attrib()

# Cleans the HABTYPE column in the attribute, keeping on ly a single habitat type (not multiple within the same cell, as this cannot be assessed)
source(file = "./functions/clean_gis_attrib_habtype_fn.R")
hab.types <- gis.hab.bgr.dat(gis.attr)
