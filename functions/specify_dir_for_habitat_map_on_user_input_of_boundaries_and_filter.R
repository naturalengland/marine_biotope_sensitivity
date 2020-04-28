# AIM: specify the habitat map/geodata input files based on the inshore offshore boundary and sub-biogeoregional specified by the user 

if(sbgr_filter == FALSE){
        # Define gis input for habitat map(s)
        input_habitat_map <- paste0(getwd(),"/input/marine_habitat/internal_hab_clip_to_mmo_plan_areas/marine_habitat_bsh_internal_evidence.gpkg") #D:\\projects\\fishing_displacement\\2_subprojects_and_data\\2_GIS_DATA\\marine_habitat\\hab_clip_to_mmo_plan_areas\\
        #F:\projects\marine_biotope_sensitivity\input\marine_habitat\internal_hab_clip_to_mmo_plan_areas
        if (waters == "inshore"){# INSHORE but without sub-biogeoregions
                # Layer in geopackage: 
                input_gis_layer <- "inshore_bsh_English_waters_wgs84" 
        }
        else {input_gis_layer <- "offshore_bsh_English_waters_wgs84"}
        
} else {    
        # INSHORE With sub-biogeoregions:
        input_habitat_map <- paste0(getwd(),"/input/marine_habitat/internal_hab_clip_to_mmo_plan_areas/marine_habitat_bsh_internal_evidence_inshore_multiple_sbgrs.gpkg")#this directory is for the clipped sbgrs.
        # Now supply the layer name that you are interest in
        input_gis_layer <- "marine_habitat_bsh_internal_evidence_inshore_multiple_sbgrs"
}        


#marine_habitat_bsh_internal_evidence