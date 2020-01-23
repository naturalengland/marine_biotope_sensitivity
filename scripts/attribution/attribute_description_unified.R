# make a new column which concatenates (unifies) the values in the columns to create a sensible attribute description

# create the Attribute Description column (attrb_descr) and store empty cell values in all rows.
act_press_attribution_results$attrb_descr <- as.character("")


#------------------------------------
# Populate the Attribute Description column (attrb_descr) with a description using existing columns of data

# Habitat senstivity score:
act_press_attribution_results$attrb_descr[act_press_attribution_results$attrb_type == "sens_attrb"] <-
        paste0(
                "Habitat sensitivity score (MarESA) to ",
                act_press_attribution_results$PressureName[act_press_attribution_results$attrb_type == "sens_attrb"],
                " (",
                act_press_attribution_results$PressureCode[act_press_attribution_results$attrb_type == "sens_attrb"],
                ") from ",
                act_press_attribution_results$ActivityName[act_press_attribution_results$attrb_type == "sens_attrb"],
                " (",
                act_press_attribution_results$ActivityCode[act_press_attribution_results$attrb_type == "sens_attrb"],
                ") ",
                "caused by ",
                as.character(choice[, 2]),
                " operations. Habitat sensitivity score (MarESA) categories: 1 = High, 2 = Medium, 3 = Low, 4 = Insufficient sensitivity evidence, 5 = No sensitivity assessment carried out, 6 = Not sensitive, 7 = No direct effects, NA = Data deficient - potentially sensitivity."
                
        )

# Confidence of sensitivity assessment:
act_press_attribution_results$attrb_descr[act_press_attribution_results$attrb_type == "conf_attrb"] <-
        paste0(
                "Confidence in (MarESA) habitat senstivity assessment to ",
                act_press_attribution_results$PressureName[act_press_attribution_results$attrb_type == "conf_attrb"],
                " (",
                act_press_attribution_results$PressureCode[act_press_attribution_results$attrb_type == "conf_attrb"],
                ") from ",
                act_press_attribution_results$ActivityName[act_press_attribution_results$attrb_type == "conf_attrb"],
                " (",
                act_press_attribution_results$ActivityCode[act_press_attribution_results$attrb_type == "conf_attrb"],
                ") ",
                "caused by ",
                as.character(choice[, 2]),
                " operations."
        )

# Assessed biotope:
act_press_attribution_results$attrb_descr[act_press_attribution_results$attrb_type == "assess_attrb"] <-
        paste0(
                "The ASSIGNED BIOTOPE (EUNIS level 4 - 6) which was used in the (MarESA) habitat senstivity assessment to ",
                act_press_attribution_results$PressureName[act_press_attribution_results$attrb_type == "assess_attrb"],
                " (",
                act_press_attribution_results$PressureCode[act_press_attribution_results$attrb_type == "assess_attrb"],
                ") from ",
                act_press_attribution_results$ActivityName[act_press_attribution_results$attrb_type == "assess_attrb"],
                " (",
                act_press_attribution_results$ActivityCode[act_press_attribution_results$attrb_type == "assess_attrb"],
                ") ",
                "caused by ",
                as.character(choice[, 2]),
                " operations."
        )

#---------# To do: functionalise! (not neccesary but a challenge)
# 
# attrb_descr_cols <-function(x){
#         
#         # define object that stores the unique attribute types 
#         attrb_x <- unique(act_press_attribution_results$attrb_type)
#         
#         # in for loop
#         # define results table
#         attrb_descr_x <- data.frame(matrix(nrow = nrow(act_press_attribution_results), ncol = length(attrb_x)))
#         
#         for (i in seq_along(attrb_x)) {
#                 
#                 
#                 #condition
#                 act_press_attribution_results$attrb_descr[act_press_attribution_results$attrb_type == attrb_x[i]]
#                 
#                   
#         }      
#         # name columns
#         
#         # call result into list
#         attrb_descr_x 
# }