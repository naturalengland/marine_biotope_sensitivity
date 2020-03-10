# Layer attribution
# Obtain the information of each Activity-Pressure combintation to supply the layer attribution file: This is a file that describes what goes into each column in the data

# Libraries
## Below the list of R libraries to load into R (in sequence). If they are not already installed on your machine you will have to do so first. This can be done using the command like install.packages("RODBC"), for each of the libraries. Then load them by running the commands below.
#library(RODBC) # allows connecting to databases
#library(DBI) # allows connecting to databases
library(tidyverse) # data wrangling scripts
#library(plyr) # more data wrangling scripts

# This script can be run as a self-contained unit, by removing the hastags, and ensuring access to all the helper scripts tha tit calls - or it can be run iside of the main script for the marine_biotope_sensitivity which already contains these data and user choices.
#---------------
# Read in Habitat senstivity data: USER INPUT REQUIRED!

# README: Script to read in Habitat sensitivity assessment data based on user selection - assuming that all other user selections made in the "main script" such as the location of the files etc is correct. I only leave the type of operation to be selected by the user, such as fishing operations.
#source("./scripts/attribution/read_sens_assess_tbl_into_R_print_operations.R") # a list of operations are printed on the screen with Operation numbers - make sure the terminal is set as wide as possible to read the info.

# Choose an operation by selecting one OperationCode from the conservation advice database. Choose 1 - 18, and set the variable ops.choice to this.
# USER selection of operation code: Set the ops.number to which you are interested, e.g. ops.number <- 13
# ops.number <- 11 # leave as 11 for fishing

# Run this to save your choice, and print a message to see what was saved
#source(file = "./functions/set_user_ops_act_choice.R")

# Load the function that reads the Access database
#source(file = "./functions/read_access_db.R") # see main script for details

# Run function that generates the R object for the specified operation
#source(file = "./scripts/attribution/generate_habitat_sens_tbl_for_eunis_codes_fn.R") 
#------------------

# start here if you run it in the main script---------

# Make table of unique combinations of Activity and Pressure (not for each EUNIS habitat cateogry)
source("./scripts/attribution/make_table_unique_activity_pressure_codes_fn.R")
act_press_combinations <- unique_activity_pressure_codes(x = qryEUNIS_ActPressSens)

# Concatenate a prefix = e.g. "sens_" to activity and pressures codes with a "_" separrator to and the the rest of characters to the codes to allow joining this table with a table of column names
source("./scripts/attribution/concat_act_press_codes_fn.R")
act_press_attribution_columns <- concat_prefix_act_press_codes_fn(x = act_press_combinations, prfix = c("sens", "conf", "assessed_hab"))

# Add the attribution columns to the Activity Pressure table in a new table.
act_press_attribution_results <- dplyr::mutate(.data = act_press_combinations, 
                                               sens_attrb = act_press_attribution_columns$sens,
                                               conf_attrb = act_press_attribution_columns$conf,
                                               assess_attrb = act_press_attribution_columns$assess,
                                               ) %>% 
        tidyr::gather(key = "attrb_type", value = "attrb_name", -c(ActivityCode, PressureCode, ActivityName, PressureName)) # reshape the table into a long format ( as opposed values of attributes spread over three columns. Note this should be the same number of rows as in the GIS File!)

# Add the Full name as a new column and assign it the combination of "Pressure name to Activity Name"
act_press_attribution_results$full_name <- paste0(act_press_attribution_results$PressureName," from ", act_press_attribution_results$ActivityName)

# unify attribute description
source("./scripts/attribution/attribute_description_unified.R")

# Add attributes for the first six (standard) columns that will appear in every Habitat Sensitivity layer output as produced by my scripts.
source("./scripts/attribution/attribute_description_standard_six_cols.R") # produces a 


# Assign the class/format of the object
source("./scripts/attribution/assign_class.R")

# Bind all attributes from standard 6 and act_press_attribution_results
source("./scripts/attribution/bind_all_attributes.R")   

# Save the attribution output file as a csv and Excel table to the outputs folder
write_excel_csv(attribution_table, paste0("./packaged_outputs/attribution_table_habitat_sensitivity_to_", as.character(choice[,2]),"_",Sys.Date(),".csv"))

# Housekeeping: remove unneccessary R objects
rm(act_press_combinations, act_press_attribution_columns, act_press_attribution_results, format, attribution_table)

