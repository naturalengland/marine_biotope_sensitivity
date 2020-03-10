# Populate qryEUNIS_ActPressureSens using the read access function above, if it fails it will attempt to read a stored csv copy (note that this may not be the most up to date version)
qryEUNIS_ActPressSens <- try(read.access.db(db.path,drv.path))
if("try-error" %in% class(qryEUNIS_ActPressSens)) {
        qryEUNIS_ActPressSens <- read.csv("./input/qryEUNIS_ActPressSens.txt") # should find an older copy of the query for the fishing activity from the database to replaceC:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/3_Other/NE/Habitat_sensitivity/qryhabsens
        cat(paste0("The R script that obtains the senstivity data appears was UNABLE to connect to the database from the specified file location ",db.path, ", in the user input section above."))
        cat("An older back-up copy stored as a text file was read in, and is limited to sensititivity to Fishing operations data only! The text file is:", (Sys.time() - file.info("./input/qryEUNIS_ActPressSens.txt")$mtime), "days old. Make sure you are using the latest version if you are updating formal outputs.")
}
if(class(qryEUNIS_ActPressSens) == "data.frame") {
        cat(paste0("The R script that obtains the senstivity data appears to have connected and read the senstivity data from the specified file location ",db.path, ", created: ", file.info(db.path)$ctime, ", selected according to the user input section above."))
        cat("The Access database file is:", (Sys.time() - file.info(db.path)$mtime), "days old. Make sure you are using the latest version if you are updating formal outputs.")
}

# ensure EUNISCode is a character, as it reads converts to factor (which is incorrectand cannot join to other objects)
qryEUNIS_ActPressSens$EUNISCode <- as.character(qryEUNIS_ActPressSens$EUNISCode) # ensure EUNIS codes are character not factors, as this will cause trouble when joining to other tables with a mismatch in the number of eunis codes
# rename SensPriority: When sens.act.rank was dropped by simply keeping this column, it no longer needed joining to the sensitivty table - but the old code used rank.value as the field name - and to keep it consistent 
qryEUNIS_ActPressSens <- qryEUNIS_ActPressSens %>% 
        dplyr::rename(rank.value = SensPriority) #this renaming is legacy issue from code developement: coudl be kept as SensPriority - but then needs to be checked and changed back to this throughout all code

cat("A new R object was created and stored in the R environment named: qryEUNIS_ActPressSens. This object containsall the habitat senstivity assessments for each activity and pressure combination for each of the eunis categories contained in the NE database." )