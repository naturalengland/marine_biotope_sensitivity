#qryEUNISFeatAct <- sqlQuery(conn ; paste("SELECT tblEUNISFeature.EUNISCode; tblFeatureActivity.FeatSubHabCode, tblFeatureActivity.FARelevant, tblActivityLUT.OperationCode, tblFeatureActivity.ActivityCode, tblActivityLUT.ActivityName 
#      FROM tblActivityLUT INNER JOIN (tblFeatureActivity INNER JOIN tblEUNISFeature ON tblFeatureActivity.FeatSubHabCode = tblEUNISFeature.FeatSubHabCode) ON tblActivityLUT.ActivityCode = tblFeatureActivity.ActivityCode;")) # keeps only FARelevant, 


#install.packages("DiagrammeR")
#library(DiagrammeR)

grViz("
      
      digraph twopi {
        
        #MS Access database - BLUE CIRCLE
        node [shape = circle
        fontname = Helvetica
        penwidth = 2
        fontcolor = black
        color = MidnightBlue
        style = filled        
        fillcolor = SteelBlue3
        alpha = 50]
        MS_Access_database; 
        
        #MS tables - YELLOW BOX
        node [shape = box
        fontname = Helvetica
        penwidth = 2
        fontcolor = black
        color = goldenrod4
        style = filled        
        fillcolor = goldenrod1
        alpha = 50]
        tblEUNISFeature; tblFeatureActivity; tblActivityLUT; tblOperationLUT; tblSensitivityLUT; tblEUNISPressure; tblEUNISLUT; tblPressureLUT; tblActivityPressure
        
        
        # MS table columns - PINK DIAMONDS
        node [shape = diamond
        fontname = Helvetica
        penwidth = 2
        fontcolor = black
        color = deeppink4
        style = filled        
        fillcolor = deeppink
        alpha = 50]
        EUNISCode; FeatSubHabCode; FARelevant; ActivityCode; OperationCode;  ActivityName
        
        # Queries - GREEN BOXES
        node [shape = box
        fontname = Helvetica
        penwidth = 2
        fontcolor = black
        color = forestgreen
        style = filled        
        fillcolor = forestgreen
        alpha = 50]
        qryEUNISFeatAct_PreActFilter; qryDistinctListOpsAct; qryEUNISFeatAct_AfterFilter; qryEUNIS_grp_act; tmp_jn_tbl_eunis_pressure_sens_lut; tmp_jn_tbl_eunis_lut_qry_eunis_grp_act; tbl_relevant_activity_pressures; tbl_relevant_activity_pressure_eunis; tbl_relevant_activity_pressure_eunis_sens;qryEUNIS_ActPressSens
        
        # user choice input
        node [shape = rhombus
        fontname = Helvetica
        penwidth = 2
        fontcolor = black
        color = aquamarine
        style = filled        
        fillcolor = aquamarine
        alpha = 50]
        UserChoiceActivity

#########################################
        #edge statements
        MS_Access_database->tblEUNISFeature->EUNISCode
        MS_Access_database->tblFeatureActivity->FeatSubHabCode
        
        
        MS_Access_database->tblActivityLUT->OperationCode
        tblFeatureActivity->FARelevant
        tblFeatureActivity->ActivityCode
        tblActivityLUT->ActivityName
        
        EUNISCode->qryEUNISFeatAct_PreActFilter
        FeatSubHabCode->qryEUNISFeatAct_PreActFilter
        FARelevant->qryEUNISFeatAct_PreActFilter
        OperationCode->qryEUNISFeatAct_PreActFilter
        ActivityCode->qryEUNISFeatAct_PreActFilter
        ActivityName->qryEUNISFeatAct_PreActFilter
        
        tblActivityLUT->qryDistinctListOpsAct
        MS_Access_database->tblOperationLUT->qryDistinctListOpsAct->UserChoiceActivity->qryEUNISFeatAct_AfterFilter->qryEUNIS_grp_act->tmp_jn_tbl_eunis_lut_qry_eunis_grp_act
        qryEUNISFeatAct_PreActFilter->UserChoiceActivity
         
         
        MS_Access_database->tblEUNISLUT->tmp_jn_tbl_eunis_lut_qry_eunis_grp_act
        
        MS_Access_database->tblPressureLUT->tbl_relevant_activity_pressures
        MS_Access_database->tblActivityPressure->tbl_relevant_activity_pressures
        
        tbl_relevant_activity_pressures->tbl_relevant_activity_pressure_eunis
        tmp_jn_tbl_eunis_lut_qry_eunis_grp_act->tbl_relevant_activity_pressure_eunis
        
        MS_Access_database->tblSensitivityLUT->tmp_jn_tbl_eunis_pressure_sens_lut
        MS_Access_database->tblEUNISPressure->tmp_jn_tbl_eunis_pressure_sens_lut
        
        tbl_relevant_activity_pressure_eunis->tbl_relevant_activity_pressure_eunis_sens
        tmp_jn_tbl_eunis_pressure_sens_lut->tbl_relevant_activity_pressure_eunis_sens
        
        tbl_relevant_activity_pressure_eunis_sens->qryEUNIS_ActPressSens
      }
")
#->tbl_relevant_activity_pressure_eunis_sens