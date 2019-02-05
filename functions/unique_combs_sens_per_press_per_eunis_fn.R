# List of sensitivity_per_pressure for each assessed EUNIs code (biotope) (from Access database)
#passes the ranked sensitivty assessments (from the database), splits it according to activity code, joins it to unique eunis combinations that have been assessed, and keeps only fields tha tare required for further calucautions

# this provides the lists of unique combinations of pressure sensitivities of all biotopes - for activity - which is then passed onto teh next set of instructions
act.press.list <- sens.act.rank %>% 
        dlply(.variables = "ActivityCode", .fun = function(x){
                
                x %>%
                        right_join(eunis.lvl.assessed, by  = "EUNISCode") %>%
                        select(EUNISCode, ActivityCode, PressureCode, rank.value)
                
                
                
        })
