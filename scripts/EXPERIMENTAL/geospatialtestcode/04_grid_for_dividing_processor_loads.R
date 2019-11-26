# AIM: in order to facilitate parallel processing of GI data: divide a study area into square grids that are one or two less than the number of cores

#libraries
library(tidyverse)
library(sf)
library(tmap)
library(parallel)
library(foreach)
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
        )




# # 1b. Sub-biogeoregions - simplified
# sbgr_dir <- "D:/projects/fishing_displacement/2_subprojects_and_data/2_GIS_DATA/biogeoregions/"
# sbgr <-
#         sf::read_sf(dsn = paste0(sbgr_dir, "sbgr_simplified_boundary_polys_20190701.gpkg"),
#                     layer = "sbgr_simplified_boundary_polys_20190702")


sf::st_crs(map)


map_27700 <- st_transform(map, 27700) %>% 
        st_cast(to = 'MULTIPOLYGON') %>%
        st_cast(to = 'POLYGON', group_or_split = TRUE, do_split = TRUE)

# map_simple = rmapshaper::ms_simplify(map, keep = 0.01,
#                                      keep_shapes = TRUE)


detectCores()
# there are 16 cores on this machine

# assign 9 cores and 3 by 3


#make grid
sbgr_grid <- st_make_grid(map_27700, n = c(3,3))

#plot output
tmap::tm_shape(map_27700) +
        tm_borders(col = "black") +
        tm_shape(sbgr_grid) +
        tm_borders("gray")

