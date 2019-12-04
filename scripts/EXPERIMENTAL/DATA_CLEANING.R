# Aproach to fixing the data
# Sample area of the wash
# convert to Single parts
# Merge to get rid of overlaps??
# Dissolve by "HAB_TYPE" and "Data_source" : to get rid of multple overlapping polygons (NOTE: SF_code_UID tells you if it is a protected feature)
# Multipart to single part
# clip habitat map by desigantion polygons to: Builds in protected area info without creating duplicates
# remove slithers: area size < 1 m sq (and < 5m sq) ->
        # fill holes by assigning the habitat type adjent habitat type with greatest MESH scores.
# topology checking: lwgeom make_valid (in between as needed)

library(sf)
library(tmap)
library(tidyverse)
library(smoothr)

# test_endpoint(Create sample layer)
# Step 1: 
sample_dir <- "F:/projects/marine_biotope_sensitivity/input/"
sample_hab <- read_sf(paste0(sample_dir, "sample_hab_data_3a_20190429_wgs84.gpkg"))

# multipart to single parts
# NAs are not allowed in subscripted assignments
sample_hab_single_polys <-
        st_cast(sample_hab, to = "MULTIPOLYGON") %>%  
        st_cast(sample_hab, to = "POLYGON", group_or_split = TRUE, do_split = TRUE) %>% 
        st_as_sf() %>% 
        lwgeom::st_make_valid() # make sure it is a sf oject


#dissolve by habitat : see: https://github.com/r-spatial/sf/issues/290
sample_hab_dissovled <- sample_hab_single_polys %>% 
        dplyr::select(HAB_TYPE) %>% 
        dplyr::group_by(HAB_TYPE) %>%
        summarise()

# the below does the same - but it retains all fields albeit it becomes a sfc object - so you may want to convert back to sf.
# sample_hab_dissovled <- sample_hab_single_polys %>%  
#         split(.$HAB_TYPE) %>% 
#         lapply(st_union) %>% 
#         do.call(c, .) %>% # bind the list element to a single sfc
#         st_cast()

# multipart poly to single part
sample_hab_diss_s_poly <- sample_hab_dissovled %>% 
        st_cast(sample_hab_dissovled, to = "MULTIPOLYGON") %>%  
        st_cast(sample_hab_dissovled, to = "POLYGON", group_or_split = TRUE, do_split = TRUE) %>% 
        st_as_sf() %>% 
        lwgeom::st_make_valid() 

#reproject to BNG
sample_hab_diss_s_poly_BNG <- st_transform(sample_hab_diss_s_poly, 27700)

#fill holes below threshold
sample_hab_diss_s_poly_BNG_filled <- smoothr::fill_holes(sample_hab_diss_s_poly_BNG, threshold = 1)

# Bigger questions: Can we reverse the deisgnated site boundary inclusion?
# What are the practicalities having a single flat file which is only clipped by protected areas after the fact?


# JNCC How does JNCC process our data: - Can fix the mismatch in the boundaries in the inshore?
# NE: Can we update our offshore to match JNCC or do we cut it to our remit?
# How does this workl with Magic and WebMap2?
