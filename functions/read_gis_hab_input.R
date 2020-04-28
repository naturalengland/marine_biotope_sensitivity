# FUNCTION: Read geodatabase from network, it it fails read a preprocessed file (a back-up copy that should not be changed unless certain that it is working)
#status: the current network file specified is the full file - this will have to be changed to a directory where the latest preprocessed file is saved.
read_hab_map <- function(hab_map_dir_in = input_habitat_map,
                                     gis_layer_in = input_gis_layer ){
        require(sf)
        hab_map_input <- try(sf::st_read(dsn = hab_map_dir_in, layer = gis_layer_in))
        if("try-error" %in% class(hab_map_input)) {
                cat("Caught an error during to read the user selected input habitat map file: ",input_habitat_map," with GIS layer: ",gis_layer_in," select", "  \n")
                     hab_map_input <- sf::st_read(dsn = paste0(getwd(),"/input/marine_habitat/marine_habitat_bsh_internal_evidence_inshore_multiple_sbgrs.gpkg"), layer = "marine_habitat_bsh_internal_evidence_inshore_multiple_sbgrs")

                }
        hab_map_input
        }
