# count number of columns with "sens"
library(dplyr)

#function that counts the number of columns in data frame witha  keywords, like sens: The idea is taht it could count the number of senstivity assessments
keyword_column_count <- function(x, keyword = "sens"){
        x %>% st_set_geometry(NULL) %>% select(contains(eval(keyword))) %>% ncol()
}

#x expects a data.frame or similar, and keyword is the word entered wihch will be searched for in the columns

#function that counts the number of columns in data frame witha  keywords, like sens: The idea is taht it could count the number of senstivity assessments
keyword_column_names <- function(x, keyword = "sens"){
        x %>% st_set_geometry(NULL) %>% select(contains(eval(keyword))) %>% names()
}
