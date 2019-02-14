# Identify missing EUNIs codes from query design which only uses valid combinations of activity pressure etc combinations

myqry <- qryEUNIS_ActPressSens %>% distinct(EUNISCode) %>% arrange(EUNISCode)
orig.dat <- tblEUNISPressure %>% distinct(EUNISCode) %>% arrange(EUNISCode)
eunis.tbl <- tblEUNISLUT %>% distinct(EUNISCode) %>% arrange(EUNISCode)
hab.eunis.codes <- hab.types %>% distinct(hab.1) %>% arrange(hab.1) %>% rename(EUNISCode = hab.1)

str(myqry)
setdiff(orig.dat,myqry) # difference between the EUNIsCodes that have been included in my code AND the EUNIS codes that have been assessed which is in our Access database
setdiff(eunis.tbl,myqry) # difference between all EUNIs codes available, and those that we have included 
missing_habitats_from_map <- (setdiff(hab.eunis.codes, myqry)) %>% 
        left_join(tblEUNISLUT, by = "EUNISCode")

setdiff(eunis.tbl,orig.dat)
setdiff(hab.eunis.codes,orig.dat)


missing.matrix <- as.data.frame(table(tblEUNISPressure$EUNISCode, tblEUNISPressure$PressureCode)) %>%
        group_by(Var1) %>%
        summarise(sum(Freq)) # 355 EUNIS codes with 36 pressures each


active_vs_inactive_eunis_codes <- setdiff(tblEUNISLUT,tbl_ia_eunis_lut)
active_inactive_join <- left_join(tblEUNISLUT,tbl_ia_eunis_lut, by = "EUNISCode")
inactive_active_join <- right_join(tblEUNISLUT,tbl_ia_eunis_lut, by = "EUNISCode")

active_inactive_gi_join <- left_join(active_inactive_join, hab.eunis.codes, by = "EUNISCode")
