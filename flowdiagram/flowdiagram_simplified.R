#install.packages("DiagrammeR")
#library(DiagrammeR)

grViz("
      
      digraph twopi {
        
        #Sensitivity data source
        node [shape = circle
        fontname = Helvetica
        penwidth = 2
        fontcolor = black
        color = MidnightBlue
        style = filled        
        fillcolor = SteelBlue3
        alpha = 50]
        
        Sensivity_Assessment_Data;

        # Habitat map source
        node [shape = circle
        fontname = Helvetica
        penwidth = 2
        color = SeaGreen3        
        fillcolor = DarkSeaGreen3
        alpha = 0.5]
        Habitat_Map

        #MainScript; Functions related to processing: Sensitivity Assessments form DB
        node [shape = box
        fontname = Helvetica
        penwidth = 2
        color = lightblue
        fillcolor = LightCyan1
        aplha = 0.5]
        Connect_and_read; Assign_EUNIS_Levels_4_to_6
        
        #MainScript; Functions related to processing: 
        #Habitat map data
        node [shape = box
        fontname = Helvetica
        penwidth = 2        
        color = OliveDrab
        fillcolor = YellowGreen
        alpha = 0.5]
        Read; Clean; Break_up_Mosaic_habitats; Assign_EUNIS_Levels_1_to_6

        #join up of two data sets:
        node [color = purple
        fillcolor = Lavender
        penwidth = 2        
        shape = box]
        Match_biotopes_to_mapped_habitats; Filter_using_sub_biogeoregion_info; Combine_data_matrices; Maximum_senstivity_per_mapped_habitat; Calculate_Confidence; Join_sensitivity_and_confidence_to_habitat_map

        #output data
        node[shape = diamond
        penwidth = 2
        color = Red4
        fillcolor = IndianRed
        alpha = 0.5]
        Habitat_Sensitivity_Map

#########################################
        #edge statements
        #MainScript->Sensivity_Assessment_Data; MainScript->Habitat_Map
        Sensivity_Assessment_Data->Connect_and_read->Assign_EUNIS_Levels_4_to_6
        Habitat_Map->Read->Clean->Break_up_Mosaic_habitats->Assign_EUNIS_Levels_1_to_6
        Assign_EUNIS_Levels_1_to_6->Match_biotopes_to_mapped_habitats
        Assign_EUNIS_Levels_4_to_6->Match_biotopes_to_mapped_habitats
        Match_biotopes_to_mapped_habitats->Filter_using_sub_biogeoregion_info->Combine_data_matrices->Maximum_senstivity_per_mapped_habitat->Calculate_Confidence
        Combine_data_matrices->Calculate_Confidence
        Calculate_Confidence->Join_sensitivity_and_confidence_to_habitat_map->Habitat_Sensitivity_Map
        Habitat_Map->Habitat_Sensitivity_Map
      }
")

