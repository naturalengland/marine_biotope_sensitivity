subsample <- hab_map@data %>%
        select(Z10_1_D6, Z10_1_D2)

#Define a new S4 object
setClass("RelevantFishingPressure", 
         slots = c(
                 Z10_6_D2 = "numeric", 
                 Z10_6_D6 = "numeric"
         ),
         prototype = list(
                 Z10_6_D2 = NA_real_,
                 Z10_6_D6 = NA_real_
         )
)


#add data to it
#relevant_fishing_pressures <- new("RelevantFishingPressure", Z10_6_D2 = 2, Z10_6_D6 = 6)
#relevant_fishing_pressures <- new("RelevantFishingPressure", Z10_6_D2 = hab_map@data$Z10_6_D2, Z10_6_D6 = hab_map@data$Z10_6_D2)

relevant_fishing_pressures@Z10_6_D2 <- hab_map@data[["Z10_6_D2"]]


#inheret S4 object and add a new slot
setClass("tests4", #class name
         contains = c("data.frame","Polygons", "CRS"), #inherits hab_map properties
         slots = c(
                 RelevantFishingPressures = "data.frame"
                 ),# slots
         prototype = data.frame(
                 RelevantFishingPressure = new("data.frame") #prototype
         )
)


ExportTest <- hab_map@data %>%
        select()


aggregate()
