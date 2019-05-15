#install.packages("DiagrammeR")
library(DiagrammeR)

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
        
        SensAssessData;

        # Habitat map source
        node [shape = circle
        fontname = Helvetica
        penwidth = 2
        color = SeaGreen3        
        fillcolor = DarkSeaGreen3
        alpha = 0.5]
        HabitatMap

        #MainScript; Functions related to processing: Sensitivity Assessments form DB
        node [shape = box
        fontname = Helvetica
        penwidth = 2
        color = lightblue
        fillcolor = LightCyan1
        aplha = 0.5]
        read_SensAssessData; unique_EUNISCodes_SensAssess; assign_EUNISLevels
        
        #MainScript; Functions related to processing: 
        #Habitat map data
        node [shape = box
        fontname = Helvetica
        penwidth = 2        
        color = OliveDrab
        fillcolor = YellowGreen
        alpha = 0.5]
        read_HabitatMap; isolate_HabitatMapAttr; clean_HabitatMapAttr; 

        #join up of two data sets:
        node [color = purple
        fillcolor = Lavender
        penwidth = 2        
        shape = box]
        match_MappedBiotopesToSensAssess_perSBGR; seqProc_per_SBGR; join_ActivityPressures_perSBGR; Filter_MaxSens_per_polygon; join_DataToHabMap

        #output data
        node[shape = diamond
        penwidth = 2
        color = Red4
        fillcolor = IndianRed
        alpha = 0.5]
        FishingOps_SensMap

#########################################
        #edge statements
        #MainScript->SensAssessData; MainScript->HabitatMap
        SensAssessData->read_SensAssessData->unique_EUNISCodes_SensAssess->assign_EUNISLevels
        HabitatMap->read_HabitatMap->isolate_HabitatMapAttr->clean_HabitatMapAttr
        clean_HabitatMapAttr->match_MappedBiotopesToSensAssess_perSBGR
        assign_EUNISLevels->match_MappedBiotopesToSensAssess_perSBGR
        match_MappedBiotopesToSensAssess_perSBGR->seqProc_per_SBGR->join_ActivityPressures_perSBGR->Filter_MaxSens_per_polygon->join_DataToHabMap
        join_DataToHabMap->FishingOps_SensMap
        HabitatMap->FishingOps_SensMap
      }
")

