# Aim: Add the GI attribute descriptions for the standard first six attribute columns
library(dplyr)

# Standard columns for all Habitat senstivity outputs: fid, pkey, HAB_TYPE, hab_1, hab_2, hab_3, sbgr_reg_id, uncertainty_sim
# Define dataframe using tibble
std_6_cols_attrb <- dplyr::tibble(attrb_name = c("pkey", "HAB_TYPE", "hab_1", "hab_2", "hab_3", "bgr_subreg_id", "uncertainty_sim"),#removed"fid", 
                           attrb_descr = c(""),
                           full_name = c(""))



# Full names of attributes ------------------------------------------------
# fid 
#std_6_cols_attrb$full_name[std_6_cols_attrb$attrb_name == "fid"] <- "Feature ID"
# pkey 
std_6_cols_attrb$full_name[std_6_cols_attrb$attrb_name == "pkey"] <- "ID associated with R processing"
# HAB_TYPE
std_6_cols_attrb$full_name[std_6_cols_attrb$attrb_name == "HAB_TYPE"] <- "EUNIS code/s of mapped Habitat from habitat map read in"
# hab_1
std_6_cols_attrb$full_name[std_6_cols_attrb$attrb_name == "hab_1"] <- "First EUNIS code encountered in HAB_TYPE"
# hab_2
std_6_cols_attrb$full_name[std_6_cols_attrb$attrb_name == "hab_2"] <- "Second EUNIS code encountered in HAB_TYPE"
# hab_3
std_6_cols_attrb$full_name[std_6_cols_attrb$attrb_name == "hab_3"] <- "Third EUNIS code encountered in HAB_TYPE"
# bgr_subreg_id
std_6_cols_attrb$full_name[std_6_cols_attrb$attrb_name == "bgr_subreg_id"] <- "Sub-biogeoregions ID number"
# uncertainty_sim
std_6_cols_attrb$full_name[std_6_cols_attrb$attrb_name == "uncertainty_sim"] <- "Biotope assignment confidence estimate"


# Attribute description ---------------------------------------------------
# fid 
#std_6_cols_attrb$attrb_descr[std_6_cols_attrb$attrb_name == "fid"] <- "Feature ID (unique identifier) associated with GIS file."
# pkey 
std_6_cols_attrb$attrb_descr[std_6_cols_attrb$attrb_name == "pkey"] <- "ID (unique identifier) associated with R processing routine."
# HAB_TYPE
std_6_cols_attrb$attrb_descr[std_6_cols_attrb$attrb_name == "HAB_TYPE"] <- "Habitat type expressed as a single or combination of EUNIS code/s (Level 1 to 6) (unique identifier). The HAB_TYPE values were obtained from the Natural England's internal benthic habitat map (or the EMODNET habitat net for opensource version). Multiple habitat categories represent mosaic habitats, which are separated out in the following columns. The descriptions of the habitat types represented by EUNIS codes in HAB_TYPE can be looked up https://eunis.eea.europa.eu/habitats.jsp"
# hab_1
std_6_cols_attrb$attrb_descr[std_6_cols_attrb$attrb_name == "hab_1"] <- "Habitat type expressed as a single EUNIS code/s (Level 1 to 6) (unique identifier). A hab_1 value is the first listed habitat obtained from HAB_TYPE column."
# hab_2
std_6_cols_attrb$attrb_descr[std_6_cols_attrb$attrb_name == "hab_2"] <- "Habitat type expressed as a single EUNIS code/s (Level 1 to 6) (unique identifier). A hab_2 value is the second listed habitat obtained from HAB_TYPE column."
# hab_3
std_6_cols_attrb$attrb_descr[std_6_cols_attrb$attrb_name == "hab_3"] <- "Habitat type expressed as a single EUNIS code/s (Level 1 to 6) (unique identifier). A hab_3 value is the third listed habitat obtained from HAB_TYPE column."
# sbgr_reg_id
std_6_cols_attrb$attrb_descr[std_6_cols_attrb$attrb_name == "bgr_subreg_id"] <- "An ID number representing the respective sub-biogeoregions in English inshore waters as defined by Keith Hiscock in a project in which likely biotopes occuring in each of the sub-biogeoregions were assigned thereto."
# uncertainty_sim
std_6_cols_attrb$attrb_descr[std_6_cols_attrb$attrb_name == "uncertainty_sim"] <- "A score ranging from 0 - 1 which represents a quantitative estimation of the certainty associated with the biotope which was assigned to mapped habitat (HAB_TYPE). Zero (0) represents low certainty and one (1) represents high certainty."

# Print message
cat("A new object named, std_6_cols_attrb, is now loaded into R environment. It contains two columns which match 2 of the names of act_press_attribution_results, which will be appended into a new table, attribution_table, containing ALL the attribute descriptions.")