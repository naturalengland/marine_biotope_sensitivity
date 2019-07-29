# hab_types  with NA outcomes

habitat_types_with_no_biotopes_in_sbgr_Z7_1_D6 <- sens_dat %>% filter(is.na(sens_Z7_1_D6)) %>% 
        select(HAB_TYPE, hab.1, sens_Z7_1_D6) %>% 
        distinct()


habitat_types_with_no_biotopes_in_sbgr_Z7_1_D6 <- sbgr.BAP.max.sens[[1]] %>% filter(is.na(max.sens)) %>% 
        select(eunis.code.gis, eunis.match.assessed, max.sens) %>% 
        distinct()

habitat_types_with_no_biotopes_in_sbgr <- purrr::map_df(sens_dat)
