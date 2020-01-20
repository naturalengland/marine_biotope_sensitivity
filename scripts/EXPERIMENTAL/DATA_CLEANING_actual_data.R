# Data cleaning of actual habitat map data based on experimental process

# Steps outline:
# 1. read in combined habitat  map
# 2. convert to multi-parts polygon to Single-parts
# 3. Dissolve by "HAB_TYPE" and "Data_source" : to get rid of multple overlapping polygons (NOTE: SF_code_UID tells you if it is a protected feature)
# 4. Multipart to single part
# 5. remove slithers: area size < 1 m sq (and < 5m sq) ->
# fill holes by assigning the habitat type adjent habitat type with greatest MESH scores.
# topology checking: lwgeom make_valid (in between as needed)

library(sf)
library(tmap)
library(tidyverse)
library(smoothr)
library(rgeos)
library(maptools)


# # Step 1: Read in habitat map from geopackage: Habitat map - NE and JNCC combined habitat map 2018-05-17 Version 9_6_4
# 
# # User input: specify data directory:
# hab_map_dir <-
#         "F:/gis_opensource/jncc/habitat_map/" 
# 
# # Execute read in command: User input: double check the file name
# hab_map_raw <-
#         sf::read_sf(dsn = paste0(
#                 hab_map_dir,
#                 "HABMAP_INSERT_20180517_.gdb"),
#                 layer = "C20180517_Combined_9_6_4"
#         )

# read_file short-cut as r object
hab_map_raw <- read_rds("F:/projects/marine_biotope_sensitivity/data/preprocessed_input/hm.rds")

# Step 2:  multipart to single parts
# note NAs are not allowed in subscripted assignments
hab_single_polys <- hab_map_raw %>% # 2 step casting to single polygon required as format from source first needs conversion to multipart polygon
        #st_cast(to = "MULTIPOLYGON") %>%  # cast to multipolygon
        st_cast(to = "POLYGON", group_or_split = TRUE, do_split = TRUE) %>% # cast from here to single polygon
        st_as_sf() %>% # make sure it is a sf oject
        lwgeom::st_make_valid() # ensure geometry is valid at this point


# Step 3: Dissolve by habitat : see: https://github.com/r-spatial/sf/issues/290
hab_dissolved <- hab_single_polys %>% 
        dplyr::select(HAB_TYPE) %>% # retain only HAB_TYPE column - this is all that is needed for my project
        dplyr::group_by(HAB_TYPE) %>% # this sets the variables by which to dissolve
        dplyr::summarize() %>%
        lwgeom::st_make_valid() # ensure geometry is valid at this point

#-----------------------------
# multipart poly to single part
hab_diss_s_poly <- hab_dissovled %>% 
        #st_cast(sample_hab_dissovled, to = "MULTIPOLYGON") %>%  
        st_cast(sample_hab_dissovled, to = "POLYGON", group_or_split = TRUE, do_split = TRUE) %>% 
        st_as_sf() %>% 
        lwgeom::st_make_valid() 

#reproject to BNG
hab_diss_s_poly_BNG <- st_transform(hab_diss_s_poly, 27700)

# see maptools for dissolving polygons below a certain size:

# drop polys below 1 m2
hab_diss_s_poly_BNG_l1 <- smoothr::drop_crumbs(x = hab_diss_s_poly_BNG, threshold = 1, drop_empty = TRUE)


#fill holes below threshold
hab_diss_s_poly_BNG_filled <- smoothr::fill_holes(sample_hab_diss_s_poly_BNG_l1, threshold = 1)

write_rds(sample_hab_diss_s_poly_BNG_filled, "./data/sample_flat_hab_map.rds")
