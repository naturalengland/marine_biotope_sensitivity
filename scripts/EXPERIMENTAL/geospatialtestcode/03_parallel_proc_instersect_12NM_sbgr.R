# use parallel  boundary to interest 12 NM boundary using sub-biogeoregions

# Clear working space - free up memory as these tasks are demanding on the processor
#rm(list = ls()) # clears all! 
rm(list=setdiff(ls(), c("hab_map_raw_utm38s", "sbgr_utm38s", "boundaries_utm38s" ))) # clears all but the listed objects

# Load libraries
library(sf) # spatial data
library(tidyverse) # data wrangling scripts
# library(foreach) # parallel processing


#---------------------------------------------------------
#  1. Read in the data

# 1a. Habitat map - JNCC version
hab_map_dir <-
        "F:/gis_opensource/jncc/habitat_map/" # data directory

hab_map_raw <-
        sf::read_sf(dsn = paste0(
                hab_map_dir,
                "HABMAP_INSERT_20180517_.gdb",
                layer = "C20180517_Combined_9_6_4"
        ))

# 1b. Sub-biogeoregions - simplified
sbgr_dir <- "D:/projects/fishing_displacement/2_subprojects_and_data/2_GIS_DATA/biogeoregions/"
sbgr <-
        sf::read_sf(dsn = paste0(sbgr_dir, "sbgr_simplified_boundary_polys_20190701.gpkg"),
                                 layer = "sbgr_simplified_boundary_polys_20190702")#"dissolvd_aois_wgs84.gkpg"))

# 1c. 12 NM boundaries
boundaries_dir <- "F:/gis_opensource/mmo/MMO_MarinePlanAreas_SHP_Full-dissolved_copy/"
boundaries <- 
        sf::read_sf(dsn = paste0(
                boundaries_dir, "offshore_marine_plan_area_dissolved_wgs84.gpkg"),
                layer = "offshore_marine_plan_areas")



#----------------------------------------------------------
# 2. Visual inspection through basic plots
plot(st_geometry(poly_1), col = as.factor(poly_1$AdminArea))

plot(
        st_geometry(poly_2),
        col = rgb(
                red = 0,
                green = 0,
                blue = 0,
                alpha = 0,
                names = NULL,
                maxColorValue = 1
        ),
        border = "black",
        lty = 2
        #add = TRUE
)

# ----------------------------------------------------------
# 2. ENSURE PROJECTIONS ALIGN
# 2a. Check data projectsion
sf::st_crs(hab_map_raw)
sf::st_crs(sbgr)
sf::st_crs(boundaries)

# 2b. Reproject to British National Grid (EPSG: 27700)
hab_map_raw_utm38s <- st_transform(hab_map_raw, 27700)
hab_map_raw_utm38s <- st_as_sf(hab_map_raw_utm38s)
hab_map_raw_utm38s <- hab_map_raw_utm38s %>% 
        dplyr::select(POLYGON, HAB_TYPE)
hab_map_raw_utm38s_m_polygon <- st_cast(hab_map_raw_utm38s, "MULTIPOLYGON")
hab_map_raw_utm38s_polygon <- st_cast(hab_map_raw_utm38s, "POLYGON")
sbgr_utm38s <- st_transform(sbgr, 27700) 
sbgr_utm38s <- st_as_sf(sbgr_utm38s)
boundaries_utm38s <- st_transform(boundaries, 27700)
boundaries_utm38s <- st_as_sf(boundaries_utm38s)

# Housekeeping: Remove unwanted objects to free up memory
rm(hab_map_raw, boundaries, sbgr)

# Geoprocessing of maps to restrict data to inshore and offshore boundaries, as well as sub-biogeoregional boundaries
hab_offshore_utm38s <- st_intersection(sbgr_utm38s, hab_map_raw_utm38s_polygon)
hab_inshore_utm38s <- st_difference(sbgr_utm38s, hab_map_raw_utm38s_polygon)
hab_inshore_sbgr_utm38s <- st_intersection(hab_inshore, sbgr_utm38s)


