library(sf)
library(raster)
library(RQGIS) # these are the bridge libraries
library(RSAGA)
library(rgrass7)


# Aim: upload a file, and intersect it using R SAGA


rsaga.env() # this searches the harddrive for SAGA algorithms
        #if this is unsuccessful: 
        #library(link2GI)
        #saga = linkSAGA()
        #rsaga.env()
rsaga.get.libraries()#To find out which libraries are available, run:

#Here is a template ffor the intersection using RSAGA:
#res <- rsaga.intersect.polygons(layer_a = poly_1,
#                                layer_b = poly_2,
#                                result = dir_tmp,
#                                load = TRUE)


library("sp")
library("magrittr")
# construct coordinates of two squares
coords_1 <- matrix(data = c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
                   ncol = 2, byrow = TRUE)
coords_2 <- matrix(data = c(-0.5, -0.5, 0.5, -0.5, 0.5, 0.5, -0.5, 0.5,
                            -0.5, -0.5),
                   ncol = 2, byrow = TRUE)
# convert the coordinates into polygons
poly_1 <- SpatialPolygons(list(Polygons(list(Polygon(coords_1)), 1))) %>%
        as(., "SpatialPolygonsDataFrame")
poly_2 <- SpatialPolygons(list(Polygons(list(Polygon(coords_2)), 1))) %>%
        as(., "SpatialPolygonsDataFrame")

dir_tmp <- paste0(tempdir(), "/out.shp") #creates a temporary output location
res <- rsaga.intersect.polygons(layer_a = poly_1,
                                layer_b = poly_2,
                                result = dir_tmp,
                                load = TRUE)

#now for my own data
data_dir_gis <- "C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/2_GIS_DATA/"
poly_1 <- sf::read_sf(dsn = paste0(data_dir_gis, "english_inshore_and_offshore_waters_jncc_wgs84.gpkg"))
poly_2 <- sf::read_sf(dsn = paste0(data_dir_gis, "sbgr_single_part_PH_wgs84.gpkg"))#"dissolvd_aois_wgs84.gkpg"))
#visual inspection
plot(st_geometry(poly_1), col = as.factor(poly_1$AdminArea))
plot(poly_2, col = rgb(red =0, green = 0, blue = 0, alpha = 0, names = NULL, maxColorValue = 1), border = "black", lty = 2, add = TRUE)

# now repeat operation
