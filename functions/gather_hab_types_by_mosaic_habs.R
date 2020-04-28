#gather the hab.type results to allow for processing all available habitats in a mosaic habitat
library(tidyr)

hab_types <- hab.types %>% tidyr::gather("hab_mosaic_entry_order","habs",-c(pkey, HAB_TYPE, bgr_subreg_id)) %>%
        dplyr::filter(!is.na(habs) & !is.na(HAB_TYPE)) # this removes isntances where both HAB_TYPE and habs have data in them. where both are NA
#clean last / hanging at the back of any habitats
hab_types$habs <- str_replace_all(hab_types$habs, "(\\/)", "\\")
hab_types$habs <- str_replace(hab_types$habs, "^$","A")#  this should turn empty habitats - "" into A - which stands for marine and is probably a fair outcome for missing data on a marine habitat map.
#hab_types$habs <- sub("^$", "A", hab_types$HAB_TYPE)
#drop empty rows
hab_types <-  hab_types[!(hab_types$habs==""), ]

cat("This leaves a new variable, hab_types, which is different from the GIS-object, hab.types, as it includes ALL the habitats, including mosaic habitats. This was done to allow processing all the said habitats and compare their sensitivities within a polygon following the same process as previous.")