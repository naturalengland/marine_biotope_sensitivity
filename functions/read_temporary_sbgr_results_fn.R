#read in all the restuls generated in a single file as lists of dataframes
results.files <- list.files(folder, full.names = F, recursive=T) %>%
        plyr::ldply(function(x){
                read.csv(paste0(folder,x), stringsAsFactors=FALSE) %>%
                        #---------
                #dplyr::mutate(#subBGR = metadata[2],
                #btp = metadata[7],
                #eunis.mapped = metadata[10]) %>%
                #---------
                dplyr::select(-one_of("X")) # removes the X column
                
        }) %>%
        plyr::dlply(.(sbgr), identity) # then regroups the data into a list of dataframes according to sub-biogeographic regions; plyr::dlply(.(sbgr,h.lvl), identity)
