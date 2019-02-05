#plot map data

#install.packages("tmap")
#isntall.packages("mapview")

#libraries
library(tidyverse)
library(tmap) 
library(mapview) 
library(maps)       # Provides functions that let us plot the maps
library(mapdata) 
library(leaflet)

#world <- map_data("world")
uk <- map('worldHires',
    c('UK', 'Ireland', 'Isle of Man','Isle of Wight'),
    xlim=c(-11,3), ylim=c(49,60.9))

#to view the results, for e.g. Z10_6_D6
plot(hab.map@polygons, col = hab.map@data$Z10_6_D6)
#to do create colour scale and add as column?
#replace col with bg = so that black outlines are not drawn
#add uk -something like:
polygon(uk)

#write results to file
png(filename = "test_sens_output.png", width = 500, height = 350, units = "px", res = 600)
plot(hab.map, col = hab.map@data$Z10_6_D6)
dev.off()


#https://geocompr.robinlovelace.net/read-write.html#visual-outputs
tmap_obj = tm_shape(hab.map) +
        tm_polygons(col = "Z10_1_D6")
tmap_save(tm  = tmap_obj, filename = "lZ10_1_D6.png")
#On the other hand, you can save interactive maps created in the mapview package as an HTML file or image using the mapshot() function:


mapview_obj = mapview(hab.map, zcol = "Z10_1_D6", legend = TRUE)
mapshot(mapview_obj, file = "my_interactive_map.html")

#-------
leaflet() %>%
        addTiles() %>%
        addPolygons(data = hab.map)
