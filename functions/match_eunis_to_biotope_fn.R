# FUNCTION: Obtain EUNIS level 6 info to associate with lower EUNIs level, based on the similarity of their EUNIS code:
# Match all lower level EUNIs habitats to eunis level 6 that share the same EUNIS composition codes
# to work on: not able to pass results on into a global variable...

# Note this is the KEY function which underpins the matching between all possible combinations of assesssed fine-scale biotopes that may occur within broader [mapped] biotopes

## Check and create a directory for output

match_eunis_to_biotopes_fn <- function(x = x, y = bgr.dfs.lst, high.lvl = mx.lvl, valid_eunis_sbgr = tbl_eunis_sbgr) {
        # x (assessed) is a character vector, containing the eunis level for which there have been sensitivity assessments (coming from PD_AoO database)
        # y (mapped) is a list of dataframes, containing any eunis level lower than eunis 6 for which we want to obtain eunis level 6 data (coming from the spatial database)
        # high.lvl is a integer value, specifying the maximum EUNIS level at which results are dealt with, which is required for running of the script
        
        # specify a large table into which results can be written outside of for loops
        #big.result.tbl <<- data.frame(matrix(ncol = 95))
        #names(big.result.tbl) <- c(as.character(x.dfs.lst[[3]][[1]]),"sbgr", "h.lvl", "l.lvl","eunis.code.gis") #names should be x (highest level assessed against) 
        
        result.btp.lvl <- vector("list", length(x))
        names(result.btp.lvl) <- paste0("h.lvl_",names(x))
        #process per biogeographic region, as the matches are different between them (some biotopes are not relevant within certain broader levels)
        for (h in seq_along(y)) {
                
                #result.tbl # on screen viewing
                #print(paste("Start processing EUNIS subBGR",name(y[[h]]), "at:", Sys.time() ))
                
                # Mapped data: split y[[h]] by eunis "level" to allo associating biotopes with heirarchical levels of eunis codes (to allow using highest level eunis codes in the end)
                y.dfs.lst <- split(y[[h]], f = y[[h]]$level) # [[h]] becuase splitting an already split list of dataframes, [[h]] refers to iterative dataframes in the list of dataframes held in y
                
                result.sbgr <- vector("list", length(y))
                # within each subBGR number of dataframes held within y.dfs.lst, needed to inform the z matrix subsets: the bit of spatial data that we want to work with!
                for (k in seq_along(y.dfs.lst)) {
                        z <- y.dfs.lst[[k]]$hab.1 # isolate the mapped habitats variable into a vector, this is what will be matched with x, one at a time
                        
                        #to add to saved results name, obtain the following
                        sBGR <- unique(y.dfs.lst[[k]]$bgr_subreg_id) # the name of the biotope
                        lvl.col <- which( colnames(y.dfs.lst[[k]])=="level" ) # determines which column is called "level" to add to saved results name
                        low.lvl <- unique(y.dfs.lst[[k]][[lvl.col]]) # generates a single value of EUNIS level of spatial data being assessed (one level is being asssessed at a time)
                        
                        #determine the number of character to filter the results by
                        nchar.substr <- ifelse(low.lvl < "3", as.integer(low.lvl), as.integer(low.lvl)+1) # becuase EUNIs codes have a "." after teh 2nd char, we have to add a character to eunis levels more than three
                        

                        
                        #-----------sbgr assessed biotope filter------------------
                        #this filters the list of all biotopes in the 0 - 12 NM offshore to the list that ocur within a particular subbioregion (remember that this is already limited to the EUNIS level wihtin which we are looking). thi sis done so that biotopes that occur in other areas are not assigned to ones in the specific sbgr of interest.
                        # NEW 2019-07-04: x (assessed habitats, at given level, which needs filtering by the sub-biogeoregion in which they are occuring)
                        sbgr.list.MBA <- valid_eunis_sbgr %>% 
                                filter(SRCode == sBGR & NE_Empirical_Conclusion == "Yes")
                        
                        x_df <- as.data.frame(x, stringsAsFactors = FALSE)
                        x_df <- x_df %>% dplyr::rename(EUNISCode = x)
                        x_df$x <- x_df$EUNISCode
                        
                        x.sbgr.df <- right_join(x_df, sbgr.list.MBA, by = "EUNISCode") %>%
                                filter(!is.na(x))
                        
                        x.sbgr <- x.sbgr.df$x # this is the final list of valid biotopes which occur within the sbgr.
                        #-----------------------------------------------------------
                        
                        # STORE THE RESULTS: generate an empty temporary data frame to store the matched x and z results-----------------------------------
                        result.tbl <- data.frame(matrix(ncol = length(x.sbgr),nrow = length(z)))
                        
                        
                        #Why For loops: to make sure that each element of y is compared to each element of x two (nested) for loops are used to cycle through each element in y, and each element in x_____________________________
                        for (i in seq_along(z)) {# repeats the following commands for each element in y 
                                a <- matrix(ncol = length(x.sbgr), nrow = length(z)) # generate a matrix with the same number of columns as x, and same number of rows as y in which TRUE or FALSE is stored
                                # repeats for each element in x
                                for (j in seq_along(x.sbgr))  {
                                        #test if biotope matches the broader EUNIS level category
                                        a <- z[i] %in% substr(x.sbgr[j],1,nchar.substr) # this return TRUE FALSE
                                        # turn TRUE FALSE matrix into dataframe with biotope values
                                        if (a == TRUE){
                                                result.tbl[i,j] <- x.sbgr[j]
                                        }
                                }
                                
                                # Names rows and columns to make it clear which biotope sare being compared with which EUNIs levels
                                names(result.tbl) <- as.character(x.sbgr) #assign column names based on biotope names
                                row.names(result.tbl) <- as.character(z) # assign column names
                        }
                        
                        # add columns to results, and then save individual tables
                        result.tbl$sbgr <- as.character(sBGR)
                        result.tbl$h.lvl <- as.character(high.lvl)
                        result.tbl$l.lvl <- as.character(low.lvl)
                        result.tbl$eunis.code.gis <- row.names(result.tbl)
                        row.names(result.tbl) <- c()
                        
                        # WRITE RESULTS:
                        #write to file for later use, and verification
                        write.csv(result.tbl,paste0("./subBGR_",sBGR,"_match_biotope_eunis_high_",high.lvl,"_eunis_mapped_",low.lvl,".csv")) # stores the result as a csv
                        #saveRDS(result.tbl, paste0("./output/sbgr_biotp_eunis_match/subBGR_",sBGR,"_match_biotope_eunis_high_",high.lvl,"_eunis_mapped_",low.lvl,".rds"))
                        
                        #result.tbl # on screen viewing
                        print(paste("Finished processing and saved level ",high.lvl, " for subBiogeographic region: ",sBGR, " at: ", Sys.time() ))
                        #write results to big table as R obj
                        # "g" comes from for loop from where it is being called
                        #level.result.tbl[[g]] <- rbind(level.result.tbl[[g]], result.tbl)
                        
                        result.sbgr[[k]] <- result.tbl # may need to define it here?
                        
                        
                        #housekeeping, this should not be neccessary, as results is redfined in when the loop is repeated, while big.table is not redifened.
                        #rm(result.tbl) #rm(y.dfs.lst, lvl.col, low.lvl, nchar.substr, z, result.tbl)
                }
                result.btp.lvl[[h]] <- result.sbgr
                
        }
        assign("out", "result.btp.lvl",envir = globalenv())
        #level.result.tbl[[g]] <- result.btp.lvl
}


