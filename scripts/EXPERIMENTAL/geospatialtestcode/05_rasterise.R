#rasterisation

library(tidyverse)
library(raster)
library(sf)
library(tmap)
# library(parallel)
# library(foreach)
# library(rmapshaper)

#read in study area
#  1. Read in the data
# 1a. Habitat map - JNCC version
hab_map_dir <-
        "F:/gis_opensource/jncc/habitat_map/" # data directory

map <-
        sf::read_sf(dsn = paste0(
                hab_map_dir,
                "HABMAP_INSERT_20180517_.gdb"),
                layer = "C20180517_Combined_9_6_4"
        ) %>% 
        dplyr::select(HAB_TYPE)

# reproject and cast to polygon
map_27700 <- st_transform(map, 27700) %>% 
        st_cast(to = 'MULTIPOLYGON') %>%
        st_cast(to = 'POLYGON', group_or_split = TRUE, do_split = TRUE)



# define template raster - 1 km polys
raster_template = raster(extent(map), resolution = 1000,
                          crs = st_crs(map)$proj4string)

# rasterise
map_27700_raster = rasterize(map_27700, raster_template) 
write_sf(map_27700, "./data/habitat_map_combined_rasterized_1km_bng27700.gpkg")
