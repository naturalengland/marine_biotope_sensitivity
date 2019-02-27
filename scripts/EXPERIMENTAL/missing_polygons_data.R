#missing habitats continued

#area and number of polys
gis.hab.types.tmp <- as.data.frame(as.matrix(as.character(hab.map@data$HAB_TYPE)), stringsAsFactors = FALSE)
names(gis.hab.types.tmp) <- "HAB_TYPE"

poly.area <- as.data.frame(as.matrix(sapply(slot(hab.map, "polygons"), slot, "area")))
names(poly.area) <- "area"

polys.n.area <- dplyr::bind_cols(gis.hab.types.tmp, poly.area)
str(polys.n.area)

#Check missing habs
total.n.polys.area <- polys.n.area %>%
        group_by(HAB_TYPE) %>%
        summarise(total.area = sum(area), n.ploys =n())


mssing.eunis <- as.data.frame(as.matrix(as.character(hab.map@data$HAB_TYPE[is.na(hab.map@data$Z10_5_D6)] %>% unique())))
names(mssing.eunis) <- "EUNISCode"
missing.eunis <- left_join(mssing.eunis, tblEUNISLUT, by = "EUNISCode")
str(missing.eunis)

missing.eunis.areas <- left_join(missing.eunis, total.n.polys.area, by = c("EUNISCode" = "HAB_TYPE")) %>%
        arrange(EUNISCode)

write.csv(missing.eunis.areas, "./outputs/missing_eunis_area.csv")