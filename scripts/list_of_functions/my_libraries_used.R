# prepare a list of libraries need
library(NCmisc)
library(tidyverse)

#list of libraries used in main script
list.functions.in.file(filename = "./scripts/main_script.R", alphabetic = TRUE)

# list of functions in functions folder
my_functions <- list.files("./functions/", pattern = "\\.R$")

# Check libraries used in my functions

my_full_fns_ls <- list(list())
for (i in seq_along(my_functions)) {
        my_ith_fns_ls <- list.functions.in.file(filename = paste0("./functions/",my_functions[i]), alphabetic = TRUE)
        packages_tmp <- unlist(my_ith_fns_ls) %>% names()
        
        my_full_fns_ls[i] <- my_ith_fns_ls
        }
