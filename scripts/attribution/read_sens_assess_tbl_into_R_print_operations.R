# Read list of operations and provide it as a printed table for the user to make a selection:

# Database: Senstivity assessments

# Define Path to Access database on Power pc specified below
db.path <- "D:/projects/fishing_displacement/2_subprojects_and_data/5_internal_data_copies/database/PD_AoO.accdb"
drv.path <- "Microsoft Access Driver (*.mdb, *.accdb)" #"this relies on the driver specified above for installation, and will not work without it!

# Below prints the list of options for the user to read, and then make a selection to enter below
source(file = "./functions/read_access_operations_and_activities.R")
OpsAct <- try(suppressWarnings(read.access.op.act())) #suppressWarnings(expr) turns warnigns off, as this warning will just tell you which data were not selected, and may be unneccessarily confusing.
if("try-error" %in% class(OpsAct)){print("Choice could not be set. Make sure your your Access Driver software is set-up correctly. Defaulting to 11. Fishing (Z10)")}
if(!"try-error" %in% class(OpsAct)){print(OpsAct)}
