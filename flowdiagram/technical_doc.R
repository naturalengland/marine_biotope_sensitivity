#install.packages("DiagrammeR")
#library(DiagrammeR)

grViz("
      
      digraph twopi {
        
        #MS Access database
        node [shape = circle
        fontname = Helvetica
        penwidth = 2
        fontcolor = black
        color = MidnightBlue
        style = filled        
        fillcolor = SteelBlue3
        alpha = 50]
        MS_Access_database
        
        #Sensitivity data source
        node [shape = circle
        fontname = Helvetica
        penwidth = 2
        fontcolor = black
        color = goldenrod4
        style = filled        
        fillcolor = goldenrod1
        alpha = 50]
        Sensivity_Assessment_Data; Sub_biogeoregional_biotopes; qryEUNISFeatAct


        # Habitat map source
        node [shape = circle
        fontname = Helvetica
        penwidth = 2
        color = SeaGreen3        
        fillcolor = DarkSeaGreen3
        alpha = 0.5]
        Habitat_Map


#########################################
        #edge statements
        MS_Access_database->Sensivity_Assessment_Data
        MS_Access_database->Sub_biogeoregional_biotopes
        
        
      }
")

