#list of named habitats

#requires running scripts and isolate hab.types and tblEUNISLUT - done from within main script, and the running the comamnds in the function 01_read_access....

habs.12nm <- hab.types %>% distinct(hab.1)
names(habs.12nm)

habs.12nm.named <- habs.12nm %>%
        left_join(tblEUNISLUT, by = c("hab.1" = "EUNISCode"))

write.csv(habs.12nm.named, "./outputs/named_habitats_0_12nm.csv")

