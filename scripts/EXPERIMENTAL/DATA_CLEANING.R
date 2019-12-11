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
        st_cast(to = "POLYGON", group_or_split = TRUE, do_split = TRUE) %>% 
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

# drop polys below 1 m2
sample_hab_diss_s_poly_BNG_l1 <- smoothr::drop_crumbs(x = sample_hab_diss_s_poly_BNG, threshold = 1, drop_empty = TRUE)


#fill holes below threshold
sample_hab_diss_s_poly_BNG_filled <- smoothr::fill_holes(sample_hab_diss_s_poly_BNG_l1, threshold = 1)

write_rds(sample_hab_diss_s_poly_BNG_filled, "./data/sample_flat_hab_map.rds")

# end of section: cleaned flat habitat map
#-----------------------------------

# Start of attempt to intersect with boundaries
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


# mcz intersection:
hab_mcz_intersect <- sf::st_intersection(sample_hab_diss_s_poly_BNG_filled, sussex_mczs_bng)

# remainder of the habitats outside of MCZs: done to be added to the intersection
hab_mcz_diff <- sf::st_difference(sample_hab_diss_s_poly_BNG_filled, sussex_mczs_bng)


# Prepare a list of layers
hab_mcz_lst <- list(hab_mcz_intersect, hab_mcz_diff)

# combine geometries to arrive at a single object
hab_combine_mcz <-
        mapedit:::combine_list_of_sf(hab_mcz_lst, crs = 27700) %>%
        lwgeom::st_make_valid()

hab_combine_mcz_disslv <-
        hab_combine_mcz %>% 
        dplyr::select(HAB_TYPE, MCZ_CODE) %>% 
        dplyr::group_by(HAB_TYPE, MCZ_CODE) %>%
        summarise()

# test output - visual inspection
tmap_mode("view")
tm_shape(hab_combine_mcz) +
        tm_polygons()#+
        tm_shape(sussex_mczs_bng)+
        tm_borders(col = "forestgreen")


# Bigger questions: Can we reverse the deisgnated site boundary inclusion?
# What are the practicalities having a single flat file which is only clipped by protected areas after the fact?


# JNCC How does JNCC process our data: - Can fix the mismatch in the boundaries in the inshore?
# NE: Can we update our offshore to match JNCC or do we cut it to our remit?
# How does this workl with Magic and WebMap2?
