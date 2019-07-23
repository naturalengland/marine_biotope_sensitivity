#missing habitat types error trace
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
        select(HAB_TYPE, hab.1, sens_Z7_10_D1) %>% #contains("sens_Z") for all columns
        gather(key = "sens_AP_cat", value = "sens_value", -HAB_TYPE, -hab.1)  
        
qa_dat_na_values <- qa_dat %>% filter(is.na(sens_value)) %>% 
        group_by(HAB_TYPE, hab.1, sens_value) %>% 
        summarise(n()) %>% 
        arrange(HAB_TYPE)

qa_dat_valid_values <- qa_dat %>% filter(!is.na(sens_value)) %>% 
        group_by(HAB_TYPE, hab.1, sens_value) %>% 
        summarise(n()) %>% 
        arrange(HAB_TYPE)
