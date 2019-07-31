read.access.db <- function(db.p = db.path, drv.p = drv.path){
        
        #user defined operation filter (move this to the main script, global variables such that the user choooses the operation in teh beginning)
        operation <- as.character(ops.number)
        
        #specificy the connection to the database
        connection.path <- paste0("Driver={",drv.path,"};DBQ=",db.path)#server=",srv.host,"; #server may need to be defined for other SQL database formats
        
        # Connect to Access db to allow reading the data into R environment.
        conn <- odbcDriverConnect(connection.path)
        
        
        #------------------------------------------------------------------------------------------------
        #1: Step 1: Query selects EUNIS codes and their FeatSubHabCode (as defined by Natural England (NE) which will allow for filtering of... ) and then filers by Feature Activity interaction is relevant - last line of code
        # ** this was changed
        qryEUNISFeatAct <- sqlQuery(conn , paste("SELECT tblEUNISFeature.EUNISCode, tblFeatureActivity.FeatSubHabCode, tblFeatureActivity.FARelevant, tblActivityLUT.OperationCode, tblFeatureActivity.ActivityCode, tblActivityLUT.ActivityName 
                                                 FROM tblActivityLUT INNER JOIN (tblFeatureActivity INNER JOIN tblEUNISFeature ON tblFeatureActivity.FeatSubHabCode = tblEUNISFeature.FeatSubHabCode) ON tblActivityLUT.ActivityCode = tblFeatureActivity.ActivityCode;")) # keeps only FARelevant, 
        
        
        qryEUNISFeatAct <- filter(qryEUNISFeatAct, OperationCode == ops.number) # filters by the operation number selected by the user - this cuts down the processing reuired ( as maps are being produced for activities which belong to a single operation to limit the output file size - but this could be changed in future to do a single run fo rall operations)
        qryEUNISFeatAct <- as.data.frame(sapply(X = qryEUNISFeatAct, FUN = as.character), stringsAsFactors=FALSE) # makes sure that all fileds are characters (to avoid problems with R coercing characters into factors, and then trying to join factors with different levels)
        
        names(qryEUNISFeatAct)
        
        qryEUNISFeatAct %>% select(FARelevant) %>% distinct()
        # step 2a 
        qryEUNIS_grp_act <- qryEUNISFeatAct %>% select(EUNISCode, 
                                                       ActivityCode,
                                                       ActivityName,
                                                       OperationCode, 
                                                       FARelevant) %>% # ** this line was added
                group_by(EUNISCode,ActivityCode, ActivityName) %>%
                distinct()
        
        qryEUNIS_grp_act <- as.data.frame(sapply(X = qryEUNIS_grp_act, FUN = as.character), stringsAsFactors=FALSE) # makes sure that all fileds are characters (to avoid problems with R coercing characters into factors, and then trying to join factors with different levels)
        
        # Get individual data tables
        #----------------------------------------------------------------------------------------
        #sql statements to translate Microsoft Access table into R objects - these will be needed make joined tables to arrive at the required datatable
        tblEUNISLUT <- sqlQuery(conn, paste("SELECT tblEUNISLUT.* 
                                            FROM tblEUNISLUT;"))
        tblEUNISLUT <- as.data.frame(sapply(X = tblEUNISLUT, FUN = as.character), stringsAsFactors=FALSE)
        
        tblPressureLUT <- sqlQuery(conn, paste("SELECT tblPressureLUT.*
                                               FROM tblPressureLUT;"))
        tblPressureLUT <- as.data.frame(sapply(X = tblPressureLUT, FUN = as.character), stringsAsFactors=FALSE)
        
        tblActivityPressure <- sqlQuery(conn, paste("SELECT tblActivityPressure.*
                                                    FROM tblActivityPressure;"))
        tblActivityPressure <- as.data.frame(sapply(X = tblActivityPressure, FUN = as.character), stringsAsFactors=FALSE)
        
        tblActivityLUT <- sqlQuery(conn, paste("SELECT tblActivityLUT.*
                                               FROM tblActivityLUT;"))
        tblActivityLUT <- as.data.frame(sapply(X = tblActivityLUT, FUN = as.character), stringsAsFactors=FALSE)
        tblActivityLUT$OperationCode <- as.integer(tblActivityLUT$OperationCode)
        
        tblEUNISPressure <- sqlQuery(conn, paste("SELECT tblEUNISPressure.*
                                                 FROM tblEUNISPressure;"))
        tblEUNISPressure <- as.data.frame(sapply(X = tblEUNISPressure, FUN = as.character), stringsAsFactors=FALSE)
        
        tblSensitivityLUT <- sqlQuery(conn, paste("SELECT tblSensitivityLUT.*
                                                  FROM tblSensitivityLUT;"))
        tblSensitivityLUT <- as.data.frame(sapply(X = tblSensitivityLUT, FUN = as.character), stringsAsFactors=FALSE)
        tblSensitivityLUT$SensPriority <- as.integer(tblSensitivityLUT$SensPriority)
        
        #--------------------------
        #TEMPORARY JOIN TABLES/QUERIES - to make above query in case it gets removed from database
        #1 Joins pressure to sensitivity, and (only) allows to filter out by SensPriority
        tmp_jn_tbl_eunis_pressure_sens_lut <- left_join(tblEUNISPressure, tblSensitivityLUT, by = c("Sensitivity" = "EPSens")) %>%
                select(EUNISCode, PressureCode, ActSensRank, SensPriority) # temporarily commented out the filter below - i think that this is where the values are being removed that cause missing values in the outputs.

        
        #2 (only) adds the EUNIS names to the qryEUNIS_grp_act
        tmp_jn_tbl_eunis_lut_qry_eunis_grp_act <- right_join(qryEUNIS_grp_act, tblEUNISLUT, by = "EUNISCode")
        #str(tmp_jn_tbl_eunis_lut_qry_eunis_grp_act)
        
        #3 (only really) adds the Pressure Name to the tblActivityPressure, also, at this point filter out non relevant activities Pressure combinations: APRelevant
        tbl_relevant_activity_pressures <- right_join(tblPressureLUT, tblActivityPressure, by = "PressureCode") %>%
                select(ActivityCode, PressureCode, PressureName, APRelevant) %>%
                filter(grepl(main.act.code,ActivityCode), APRelevant == "Yes") %>%
                select(-c(APRelevant))# filter keeping only the Activity-Pressure which match the "Z10." - this can be changed to match an input variable #!grepl("Z10.",ActivityCode) AND filter only relevant pressure and activitiy combinations
        
        #4 is a join of #2 and #3  (joins named EUNIS grp act to Activity Pressure combinations)
        tbl_relevant_activity_pressure_eunis <- left_join(tbl_relevant_activity_pressures, tmp_jn_tbl_eunis_lut_qry_eunis_grp_act, by = "ActivityCode")
        
        
        #5 is a join of #1 and #3 (it joins the sensitivity assessments of each pressure - EUNIS code)
        tbl_relevant_activity_pressure_eunis_sens <- left_join(tbl_relevant_activity_pressure_eunis, tmp_jn_tbl_eunis_pressure_sens_lut, by = c("EUNISCode", "PressureCode")) %>%
                filter(!is.na(ActSensRank)) %>%
                select(ActivityCode, ActivityName, everything(), SensPriority)
        
        
        
        
}
