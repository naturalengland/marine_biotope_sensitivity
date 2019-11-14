# spatial training

library(sf)
library(raster)#requires (sp)
library(dplyr)#load after raster to avoid masking issue
library(spData) #provides data sets to play with


canterbury = nz %>% filter(Name == "Canterbury") #apply dplyr's filtering to keep only records that match Canterbury
canterbury_height = nz_height[canterbury, ] #now subset points that fall within canterbury - i.e. this is doing an intersect!

#see a few plots to demostrate this
plot(st_geometry(nz), col = as.factor(nz$Name), border = "gray", lwd = 1.5)
plot(st_geometry(canterbury), col = "White", border = "grey", lty = 1, lwd = 2)

#this is subsetting (using intersect commands)
nz_height[canterbury, 2, op = st_disjoint] # adds 
nz_height[canterbury, , op = st_disjoint]

# to see how subsetting works, add the points over the map
plot(st_geometry(nz), col = "white", border = "gray", lwd = 1.5) # plots NZ in white with gray outline
plot(nz_height[canterbury, , op = st_disjoint], col = "blue", add = TRUE) # adds points outside of canterbury in blue
plot(nz_height[canterbury, ], col = "red", add = TRUE) #adds points inside of canterbury in red

