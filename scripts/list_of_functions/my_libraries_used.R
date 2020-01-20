# prepare a list of libraries need
library(NCmisc)
library(tidyverse)

#list of libraries used in "main script"
main_script_packages <-
        list.functions.in.file(filename = "./scripts/main_script.R", alphabetic = TRUE) %>%
        names() %>%
        unique() %>%
        as_tibble() %>%
        dplyr::rename(packages = value) %>%
        dplyr::filter(str_detect(string = .$packages, pattern = "^package:")) %>%
        unlist() %>%
        stringr::str_replace(pattern = "package:", replacement = "")

# list of functions in functions folder
my_functions <- list.files("./functions/", pattern = "\\.R$")

# Check packages used in my helper functions
my_full_fns_ls <- list(list())
for (i in seq_along(my_functions)) {
        my_ith_fns_ls <-
                list.functions.in.file(
                        filename = paste0("./functions/", my_functions[i]),
                        alphabetic = TRUE
                )
        packages_tmp <- names(my_ith_fns_ls) %>% unique() %>%
                stringr::str_replace("package:", "")
        
        my_full_fns_ls[[i]] <-
                packages_tmp %>% as_tibble() %>%
                dplyr::rename(packages = value) %>%
                filter(!str_detect(string = .$packages, pattern = "^c"))
        
} 
#combine main script and list of packages from helper functions
all_packages_used <- my_full_fns_ls %>% unlist() %>% 
        as.character()  %>% 
        c(main_script_packages) %>% 
        unique() %>% 
        as_tibble() %>% 
        dplyr::rename(packages = value) %>% 
        dplyr::filter(!str_detect(string = .$packages,pattern = ".Global"))
write_rds(all_packages_used, "./data/all_packages_used.R")
