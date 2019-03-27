column_naming_fn <- function(x = x, w, prfix){
        act.code <- unique(as.character(x$ActivityCode[!is.na(x$ActivityCode)])) # obtain the unique activity codes, excluding any NA values.
        orig.names <- names(w[,-1]) # obtain the original names for the columns
        new.names <- c(names(w[,1]),str_c(prfix, act.code, orig.names, sep = "_")) 
        #new.names.2 <- str_replace(new.names,"[.]","_") # change points to underscores to make them database compatable
        new.names.2 <- str_replace_all(new.names,"[.]","_") # change points to underscores to make them database compatable
        names(w) <- new.names.2 # set the names to names 2
        ##REMOVE columns with <NA> in name
        #drop columns with NA for name (these may have arised in datasets where NA occured in the PressureCode column which were assigned NA if they were not present)
        try(w <- w %>% select(-ends_with('<NA>'))) # this finds columns that ends with: ...<NA> and removes them
        
        
}

