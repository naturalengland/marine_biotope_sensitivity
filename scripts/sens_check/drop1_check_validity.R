# if NA - drop one character - check if it it is still NA and replace, else drop another cahracter, and repeat.

library(tidyverse)


sens_dat_drop <- sens_dat %>% 
        select(pkey, HAB_TYPE, hab.1, contains("sens_Z")) %>% #contains("sens_Z") for all columns # sens_Z7_10_D1
        gather(key = "sens_AP_cat", value = "sens_value", -pkey, -HAB_TYPE, -hab.1 )  

sens_dat_drop$hab_drop1 <- as.character("")

#step 1: drop 1 character
sens_dat_drop$hab_drop1 <- ifelse(nchar(sens_dat_drop$hab.1) > 4 & is.na(sens_dat_drop$sens_value), substr(sens_dat_drop$hab.1,1,nchar(sens_dat_drop$hab.1)-1), sens_dat_drop$hab.1)

replacement_dat_valid_values <- sens_dat_drop %>% 
        filter(!is.na(sens_value)) %>%
        select(sens_AP_cat, hab.1 , sens_value) %>% 
        distinct()


sens_dat_drop_join_w_replace_drop1 <- sens_dat_drop %>% left_join(replacement_dat_valid_values, by =c("sens_AP_cat" = "sens_AP_cat", "hab_drop1" =  "hab.1"))

sens_dat_drop_join_w_replace_drop1$sens_amal <- ifelse(!is.na(sens_dat_drop_join_w_replace_drop1$sens_value.x),sens_dat_drop_join_w_replace_drop1$sens_value.x, sens_dat_drop_join_w_replace_drop1$sens_value.y)

# step 2: drop 2 characters: needs working up - to repeat teh above - but htink it through carefully it may only apply to  more than 5 chars....
sens_dat_drop$hab_drop2 <- ifelse(nchar(sens_dat_drop$hab.1) > 4 & is.na(sens_dat_drop$sens_value), substr(sens_dat_drop$hab.1,1,nchar(sens_dat_drop$hab.1)-2), sens_dat_drop$hab.1)

replacement_dat_valid_values_2 <- sens_dat_drop %>% 
        filter(!is.na(sens_value)) %>%
        select(sens_AP_cat, hab.1 , sens_value) %>% 
        distinct()


sens_dat_drop_join_w_replace_drop2 <- sens_dat_drop_join_w_replace_drop1 %>% left_join(replacement_dat_valid_values_2, by =c("sens_AP_cat" = "sens_AP_cat", "hab_drop2" =  "hab.1"))

sens_dat_drop_join_w_replace_drop2$sens_amal <- ifelse(!is.na(sens_dat_drop_join_w_replace_drop1$sens_amal),sens_dat_drop_join_w_replace_drop1$amal, sens_dat_drop_join_w_replace_drop1$sens_value.y)












#sens check:

qa_dat_na_values <- sens_dat_drop %>% 
        filter(is.na(sens_value)) %>% 
        group_by(sens_AP_cat, HAB_TYPE, hab.1 , sens_value, hab_drop1) %>% 
        summarise(n()) %>% 
        arrange(HAB_TYPE)

qa_dat_valid_values <- sens_dat_drop %>% 
        filter(!is.na(sens_value)) %>% 
        group_by(sens_AP_cat, HAB_TYPE, hab.1 , sens_value, hab_drop1) %>% 
        summarise(n()) %>% 
        arrange(HAB_TYPE)

qa_dat_na_values$sens_drop1 <- as.character("")

qa_dat_join_na_and_valid_drop1 <- left_join(qa_dat_na_values, qa_dat_valid_values, by = c("sens_AP_cat"= "sens_AP_cat", "hab_drop1" = "hab.1"))
#qa_dat_join_na_and_valid_drop1 <- left_join(qa_dat_na_values, qa_dat_valid_values, by = c("hab.1" = "hab.1"))
