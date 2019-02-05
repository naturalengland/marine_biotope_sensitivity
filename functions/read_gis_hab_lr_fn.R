# FUNCTION: Read geodatabase from network, it it fails read a preprocessed file (a back-up copy that should not be changed unless certain that it is working)
#status: the current network file specified is the full file - this will have to be changed to a directory where the latest preprocessed file is saved.
read.network.geodatabase <- function(net.dir = "\\\\SAMVW3-GIREP02\\NEWorkingData\\GIS_Working_Data\\Marine\\Marine_Evidence_Geodatabase\\Marine_Evidence_Base_Internal.gdb",#\\SAMVW3-GIREP02\NEWorkingData\GIS_Working_Data\Marine\Marine_Evidence_Geodatabase\
                                     gis.layer = "Input_BSH_Polys_WGS84_Internal" ){
        require(rgdal)
        gdb <- try(readOGR(dsn = net.dir, layer = gis.layer))
        if("try-error" %in% class(gdb)) {
                cat("Caught an error during to read the network file, trying read a back up copy.\n")
                prep.gdb.dir <- "D:\\projects\\fishing_displacement\\2_subprojects_and_data\\2_GIS_DATA\\Marine habitat\\sbgr_input_poly_wgs84_internal_bgr_inside_12nm.gpkg"
                gis.layer <- "sbgr_input_poly_wgs84_internal_bgr_inside_12nm"
                gdb <- try(readOGR(dsn = prep.gdb.dir, layer = gis.layer))
                if("try-error" %in% class(gdb)) {
                        cat("Could not load back-up file, please specify the locality of the geodatabase./n")
                        gdb.path <- as.character(file.choose())
                        cat("Now specify the layer, e.g. Input_BSH_Polys_WGS84_Internal")
                        layer. <- basename(as.character(file.choose()))
                        gdb <- readOGR(dsn = gdb.path, layer = layer.)
                }
                gdb
        }
        gdb
}