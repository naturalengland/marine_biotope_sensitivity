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
library(rgeos)
library(maptools)

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
#-----------------------------
# the below does the same - but it retains all fields albeit it becomes a sfc object - so you may want to convert back to sf.
# sample_hab_dissovled <- sample_hab_single_polys %>%  
#         split(.$HAB_TYPE) %>% 
#         lapply(st_union) %>% 
#         do.call(c, .) %>% # bind the list element to a single sfc
#         st_cast()

# See also vignette("combine_maptools" , package = "maptools")

#-----------------------------
# multipart poly to single part
sample_hab_diss_s_poly <- sample_hab_dissovled %>% 
        st_cast(sample_hab_dissovled, to = "MULTIPOLYGON") %>%  
        st_cast(sample_hab_dissovled, to = "POLYGON", group_or_split = TRUE, do_split = TRUE) %>% 
        st_as_sf() %>% 
        lwgeom::st_make_valid() 

#reproject to BNG
sample_hab_diss_s_poly_BNG <- st_transform(sample_hab_diss_s_poly, 27700)

# see maptools for dissovling polygons below a certain size:

#fill holes below threshold
sample_hab_diss_s_poly_BNG_filled <- smoothr::fill_holes(sample_hab_diss_s_poly_BNG, threshold = 1)

# Load designated areas
desig_dir <- "D:/projects/fishing_displacement/2_subprojects_and_data/2_GIS_DATA/designated_areas/"
# spa <- read_sf(paste0(desig_dir, "Special_Protection_Areas.gdb"), layer = "SPA_England")
# sac <- read_sf(paste0(desig_dir, "Special_Areas_of_Conservation.gdb"), layer = "SAC_England")
mcz <- read_sf(paste0(desig_dir, "Marine_Conservation_Zones.gdb"), layer = "Marine_Conservation_Zones")

# transform to crs 27700 (british National Grid - BNG)
# spa_bng <- st_transform(spa, 27700)
# sac_bng <- st_transform(sac, 27700)
mcz_bng <- st_transform(mcz, 27700) %>% dplyr::select(MCZ_NAME, MCZ_CODE)
# housekeeping - remove objects not required
rm(mcz, spa, sac, sample_hab, sample_hab_diss_s_poly, sample_hab_diss_s_poly_BNG, sample_hab_dissovled, sample_hab_diss_s_poly, sample_hab_single_polys)

# 1b. Sub-biogeoregions - simplified
sbgr_dir <- "D:/projects/fishing_displacement/2_subprojects_and_data/2_GIS_DATA/biogeoregions/"
sbgr <-
        sf::read_sf(dsn = paste0(sbgr_dir, "sbgr_simplified_boundary_polys_20190701.gpkg"),
                    layer = "sbgr_simplified_boundary_polys_20190702")#"dissolvd_aois_wgs84.gkpg"))

# Sub-biogeoregions
sbgr_bng <- st_transform(sbgr, 27700) %>% #Reproject to British National Grid (EPSG: 27700)
        lwgeom::st_make_valid() %>% #make sure geometry is valid
        sf::st_as_sf(sbgr_bng) # make sure it is a sf oject
rm(sbgr)

# tmap_mode("view")
# tm_shape(sbgr_bng) +
#         tm_borders(col = "black") +
#         tm_text("SubReg_id")

# Select mpa is in Sussex
sussex_bng <- sbgr_bng %>% 
        dplyr::filter(SubReg_id == "3a")

# intersect MCZs and Sussex MCZs
sussex_mczs_bng <- sf::st_intersection(sussex_bng, mcz_bng)

# tmap_mode("view")
# tm_shape(sussex_mczs_bng) +
#         tm_borders(col = "black") +
#         tm_text("MCZ_NAME")

# union habitat with desigated areas
# mcz intersection:
hab_mcz_union <- sf::st_union(sample_hab_diss_s_poly_BNG_filled, sussex_mczs_bng, by_feature = TRUE)
        # st_cast(hab_mcz_union, to = "POLYGON", group_or_split = TRUE, do_split = TRUE) %>% 
        # st_as_sf() %>% 
        # lwgeom::st_make_valid() # fix any topological errors

# test output - visual inspection
tmap_mode("view")
tm_shape(hab_mcz_intersect) +
        tm_polygons()

# Bigger questions: Can we reverse the deisgnated site boundary inclusion?
# What are the practicalities having a single flat file which is only clipped by protected areas after the fact?


# JNCC How does JNCC process our data: - Can fix the mismatch in the boundaries in the inshore?
# NE: Can we update our offshore to match JNCC or do we cut it to our remit?
# How does this workl with Magic and WebMap2?
