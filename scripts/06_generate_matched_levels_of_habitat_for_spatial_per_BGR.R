# assign the EUNIs level to the mapped habitats 
library(plyr)
library(tidyverse)
#library(data.table)

#setwd(orig.d)
#functions
source("./functions/match_eunis_to_biotope_fn.R") # function 

# input data

# SPATIAL data for join (y):
# y - from spatial data; all possible EUNIS codes per BGR
#in order to do so, define the EUNIs level of the hab.1 column
eunis.lvl.less.2 <- nchar(as.character(hab.types$hab.1), type = "chars", allowNA = T, keepNA = T)
eunis.lvl.more.2 <- nchar(as.character(hab.types$hab.1), type = "chars", allowNA = T, keepNA = T)-1
hab.types$level <- ifelse(nchar(as.character(hab.types$hab.1), type = "chars", allowNA = T, keepNA = T) > 2, eunis.lvl.more.2, eunis.lvl.less.2) #only using the first stated habitat, could be made to include others later on
rm(eunis.lvl.less.2, eunis.lvl.more.2) # housekeeping remove temporary vars


# Define (unique) benthic habitats to allow the join between the GIS spatial mapped data and the sensitivity assessments (by EUNIS codes)
distinct.mapped.habt.types <- hab.types %>%
        distinct(hab.1,bgr_subreg_id, level) %>% drop_na() # hab.1 contains the worked/processed HAB_TYPE data (1st column)

#generate multiple dataframes in a list, for the various habitat types within subBGRs, per hab level. this holds the gis data used to generate cross tabulated data matrices in the "match_eunis_to_biotope_fn"
bgr.dfs.lst <- split(distinct.mapped.habt.types, distinct.mapped.habt.types$bgr_subreg_id)


# All EUNIS Biotopes that have been assessed 
#this list of data tables holds the assessed level data from the Access database - all habitats assessed per habitat level. this will be used with the above to generate the cross tabulate matrices in the "match_eunis_to_biotope_fn"
x.dfs.lst <- split(EunisAssessed,f = EunisAssessed$level)

level.result.tbl <- vector("list", length(x.dfs.lst))
names(level.result.tbl) <- paste0("h.lvl_",names(x.dfs.lst))

#Genreate a diroctory save temporary output files into
mainDir <- getwd()#"C:/Users/M996613/Phil/PROJECTS/Fishing_effort_displacement/2_subprojects_and_data/4_R/sensitivities_per_pressure"
subDir <- "tmp_output/"
dir.create(file.path(mainDir, subDir), showWarnings = FALSE)
setwd(file.path(mainDir, subDir))
# below is a for loop that count backwards, and then split the EUNIsAssessed in to a list of dataframes 1st being the most detailed biotope level (6), and then down to the broadest biotope level (4) that were assessed in the PD_AoO access database
for (g in seq_along(x.dfs.lst)) {
        #determine the number of characters for substring limit to feed into substring statement
        sbstr.nchr <- unique(nchar(as.character(x.dfs.lst[[g]]$EUNISCode)))
        #Obtain the EUNIs code by copying only the number of characters at the level assessed.
        x <- substr(as.character(x.dfs.lst[[g]]$EUNISCode), 1,sbstr.nchr)
        #obtain the EUNIS level:
        mx.lvl <- unique(x.dfs.lst[[g]]$level)
        
        #r obj to save results per level
        level.result.tbl[[g]] <- data.frame(matrix(ncol = length(x)+4), stringsAsFactors = FALSE) # +4 to cater for the added columns, sbgr, etc
        names(level.result.tbl[[g]]) <- c(as.character(x.dfs.lst[[g]][[1]]),"sbgr", "h.lvl", "l.lvl","eunis.code.gis") #names should be x (highest level assessed against) 
        
        
        # specify a large table into which results can be written outside of for loops
        
        match_eunis_to_biotopes_fn(x,bgr.dfs.lst,mx.lvl) # this calls the FUNCTION which generates the results tables which are written to CSV - this should rather be stored as R objects which can be removed in due course than saving files - but needs further work
        
        #level.result.tbl[[g]] <- out # this does not yet work...at this stage all results are being wriiten to Results table csv and then read back in later
}
setwd(file.path(mainDir))
getwd()
rm(mainDir, subDir)
