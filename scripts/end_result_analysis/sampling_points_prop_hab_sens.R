library(sf)
library(tidyverse)
library(RODBC)
library(DBI)
library(plotrix)


#read the geopackage files into R, inshore and offshore
sampling_pts_inshore <- st_read(dsn = "F:/scratch/sampling_points_fishing_act_overlay/random_pts_inside_high_dredge.gpkg", layer = "inshore_habitat_sens")
st_geometry(sampling_pts_inshore) <- NULL
sampling_pts_offshore <- st_read(dsn = "F:/scratch/sampling_points_fishing_act_overlay/random_pts_offshore_high_dredge_hab_sens.gpkg", layer = "pts_offshore_habitat_sens_high_dredge")
st_geometry(sampling_pts_offshore) <- NULL

# select relevant columns for the analysis, and filter by te five areas identified with high dredging (see the report for details)
inshore_scallop_drdg_pts <- sampling_pts_inshore %>%
        select(pt_id = id, pkey, aoi, sum_dredge = SUM_SUM_DREDNUM,sens_Z10_5_D2, sens_Z10_5_D5,sens_Z10_5_D6,assessed_hab_Z10_5_D2,assessed_hab_Z10_5_D5,
               assessed_hab_Z10_5_D6,conf_Z10_5_D2,conf_Z10_5_D5,conf_Z10_5_D6) %>%
        filter(aoi == 1| aoi ==3| aoi == 4 | aoi == 5| aoi ==8)

# add a column to identify the inshore habitats
inshore_scallop_drdg_pts$location <- "Inshore"

#check 
inshore_scallop_drdg_pts %>% filter(assessed_hab_Z10_5_D6 == "A4.231") %>%
        distinct(sens_Z10_5_D6, sens_Z10_5_D5, sens_Z10_5_D2, pkey) %>%
        dplyr::arrange(sens_Z10_5_D6)

#same for the offshore
offshore_scallop_drdg_pts <- sampling_pts_offshore %>%
        select(pt_id = id, pkey, aoi, sum_dredge = SUM_SUM_DREDNUM,sens_Z10_5_D2, sens_Z10_5_D5,sens_Z10_5_D6,assessed_hab_Z10_5_D2,assessed_hab_Z10_5_D5,
               assessed_hab_Z10_5_D6,conf_Z10_5_D2,conf_Z10_5_D5,conf_Z10_5_D6) %>%
        filter(aoi == 1| aoi ==3| aoi == 4 | aoi == 5| aoi ==8)

# add a column to identify the points as belonging to the offshore
offshore_scallop_drdg_pts$location <- "Offshore"

#check 
offshore_scallop_drdg_pts %>% filter(assessed_hab_Z10_5_D6 == "A4.231") %>%
        distinct(sens_Z10_5_D6, sens_Z10_5_D5, sens_Z10_5_D2)

#add the offshore data to the inshore data in one table
scallop_drdg_pts <- bind_rows(inshore_scallop_drdg_pts, offshore_scallop_drdg_pts)
#scallop_drdg_pts <- scallop_drdg_pts %>% mutate(Sensitivity = ifelse(sens_Z10_5_D6 == 6, "High",
#                                                ifelse(sens_Z10_5_D6 == 5, "Medium", 
#                                                       ifelse(sens_Z10_5_D6 == 4, "Low", NA))))

sens.rank <- source("./functions/sensitivity_rank_tbl.r")
sens.rank <- sens.rank$value

scallop_drdg_pts <- scallop_drdg_pts %>% left_join(sens.rank, by = c("sens_Z10_5_D6"="rank.value")) %>%
        rename(Sensitivity = ActSensRank)

# reorder columns to put location column first
scallop_drdg_pts <- scallop_drdg_pts %>% select(location, Sensitivity, pt_id:conf_Z10_5_D6)
# make column location a factor to group the results by:
scallop_drdg_pts$location <- as.factor(scallop_drdg_pts$location)

# total number of points per location
total_number_of_sampling_pts <- scallop_drdg_pts %>%
        group_by(location) %>%
        select(location, sens_Z10_5_D6) %>%
        drop_na() %>%
        summarise(total_pts =n())

#total number of points per sensitivity category
sens_counts_per_pressure <- scallop_drdg_pts %>%
        drop_na() %>%
        group_by(location, sens_Z10_5_D6) %>%
        summarise(number_pts = n())

#total number of points per sensitivity category
sens_counts_per_aoi <- scallop_drdg_pts %>%
        drop_na() %>%
        group_by(location, aoi) %>%
        summarise(mean(sens_Z10_5_D6), sd(sens_Z10_5_D6),SE = plotrix::std.error(sens_Z10_5_D6))

#percentage sampling points per pressure
perc_sampling_pts_per_pressure <- sens_counts_per_pressure %>%
        left_join(total_number_of_sampling_pts, by = "location") %>%
        select(location, total_pts, number_pts, sens_Z10_5_D6) %>%
        group_by(location, sens_Z10_5_D6) %>%
        summarise('Percent sampling points' = number_pts/total_pts*100) 
        
#high sensitive habitats
sens_habs <- scallop_drdg_pts %>% filter(sens_Z10_5_D6 == 4|sens_Z10_5_D6 == 5|sens_Z10_5_D6==6) %>%
        distinct(assessed_hab_Z10_5_D6, location, sens_Z10_5_D6, Sensitivity) %>%
        arrange(desc(sens_Z10_5_D6), location, assessed_hab_Z10_5_D6)
sens_habs




# EUNIS habitat codes

#specificy the connection to the database
connection.path <- paste0("Driver={",drv.path,"};DBQ=",db.path)#server=",srv.host,"; #server may need to be defined for other SQL database formats

# Connect to Access db to allow reading the data into R environment.
conn <- odbcDriverConnect(connection.path)

tblEUNISLUT <- sqlQuery(conn, paste("SELECT tblEUNISLUT.* 
                                            FROM tblEUNISLUT;"))
tblEUNISLUT <- as.data.frame(sapply(X = tblEUNISLUT, FUN = as.character), stringsAsFactors=FALSE)
close(conn)#close rodbc connection

# join with above
sens_habs_named <- left_join(sens_habs, tblEUNISLUT, by = c("assessed_hab_Z10_5_D6" = "EUNISCode")) %>%
        select(Location = location, Sensitivity, sens_Z10_5_D6, `Assessed habitat` = assessed_hab_Z10_5_D6, `EUNIS name` = EUNISName)
print(sens_habs_named)
saveRDS(sens_habs_named, "./report/tables/sensitive_habitats.RDS")

rm(sens_habs)







#think about a sensitive - vs non senstive model?
#glm1 <- glm(factor(sens_Z10_5_D6) ~ sum_dredge, data = scallop_drdg_pts, family = "binomial")
#class(glm1)
#plot(glm1)
#summary(glm1)
#ndat <- sample_frac(scallop_drdg_pts, 0.3)
#fdat <- fitted(glm1)
#pdat <- predict(glm1, type = "response")
#plot(fdat,pdat)
