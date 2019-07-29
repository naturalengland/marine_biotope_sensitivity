#missing habitat types error trace

#test:
qa_dat <- sens_dat %>% filter(HAB_TYPE == "A5.25") %>% select(hab.1, contains("sens"))
#comapre this with: sbgr.matched.btpt.w.rpl
qa_match_compare <- sbgr.matched.btpt.w.rpl[[1]] %>% filter(eunis.code.gis == "A5.25")
#qa_dat_Z10_10_D1 <- qa_dat %>% filter(is.na(sens_Z10_1_D1))

#TO DO where na values appear these need to be checked - can I assign the values of 5.2 to 5.25 perhaps? we did these not get sensitivity scores: to folow up                



#In the output from this look for A1.1132, A1.122 - A1.126: These are codes which seem to be missing 

#the error seems to havealready been introduced early on, and all subsequent steps seemed to produce the correct output.

# Z7_1 D6 appears to be missing from some of the unique combinations that generated in sens.act.rank 

sens.act.rank %>% dplyr::filter(ActivityCode == "Z7.1" & PressureCode == "D6") %>% select(EUNISCode) %>% arrange(EUNISCode)
#this shows that there are many missing codes - traceback furthe to find error: in the ORIGINAL QUERY FROM THE DATABASE

qryEUNIS_ActPressSens %>% dplyr::filter(ActivityCode == "Z7.1" & PressureCode == "D6") %>% select(EUNISCode) %>% arrange(EUNISCode)
#Check the Access database, and the query set up in R in function: 

qryEUNIS_ActPressSens %>% 
        dplyr::filter(ActivityCode == "Z7.1" & PressureCode == "D6" & EUNISCode == "A1.126") %>% 
        select(EUNISCode, ActSensRank) %>% arrange(EUNISCode)

#drop columns where all values are na first
# functions to remove columns where all or any values are NA
not_all_na <- function(x) any(!is.na(x))
not_any_na <- function(x) all(!is.na(x))
tmp <- sens_dat %>% select_if(not_all_na)

qa_dat <- tmp %>% 
        select(HAB_TYPE, hab.1, contains("sens_Z")) %>% #contains("sens_Z") for all columns; sens_Z7_10_D1
        gather(key = "sens_AP_cat", value = "sens_value", -HAB_TYPE, -hab.1)  
        
qa_dat_na_values <- qa_dat %>% 
        dplyr::filter(is.na(sens_value)) %>% 
        dplyr::group_by(HAB_TYPE, hab.1, sens_value) %>% 
        dplyr::summarise(n()) %>% 
        dplyr::arrange(HAB_TYPE)

qa_dat_valid_values <- qa_dat %>% 
        dplyr::filter(!is.na(sens_value)) %>% 
        dplyr::group_by(HAB_TYPE, hab.1, sens_value) %>% 
        dplyr::summarise(n()) %>% 
        dplyr::arrange(HAB_TYPE)


qa_not_assessed_dat <- tmp %>% 
        select(HAB_TYPE, hab.1, contains("sens_Z")) %>% #contains("sens_Z") for all columns; sens_Z7_10_D1
        select(HAB_TYPE, hab.1, contains("not_assessed")) %>% #columns that contain not assessed
        gather(key = "sens_AP_cat", value = "sens_value", -HAB_TYPE, -hab.1)  

hab_typ_not_assessed <- qa_not_assessed_dat %>% 
        dplyr::filter(sens_value == "not_assessed") %>% 
        dplyr::group_by(HAB_TYPE, sens_value) %>% 
        dplyr::summarise(n()) %>% 
        arrange(desc(`n()`))



hab_typ_not_assessed$HAB_TYPE %>% 
        purrr::map(function(x) paste0("hab.1 = ","'", x,"'")) %>% 
        unlist() %>% write.csv(file = "hab_typ_not_assessed.csv")
