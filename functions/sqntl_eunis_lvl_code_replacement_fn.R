#genereate a list of sbgr matched biotopes from the results files, and sequentially assess the EUNIS levels from 6 to 4. Where an empty value at a higher EUNIs level is found it will look ion the next lower level, until it runs out at level four, when it leaves the value at NA.

sbgr.matched.btpt.w.rpl <- results.files %>% 
        plyr::llply(function(x){ 
                print(paste("Start of a list",attr(results.files,"split_labels")))
                #the read in csv files have now been split into their consituent dataframes
                
                # Do for each sbgr df: split accoring to h.lvl
                #split(x,f = h.lvl)
                y <- split(x,f = x$h.lvl) # split is apropriate as we want to access the dataframes per sbgr simulatnously
                
                #now feed each component of the list 
                
                #sbgr.dfs.lst.by.h.lvl.tmp <- z %>% # select a dataframe (temporary name for dataframe where PER sbgr dataframe is stored, and run through the rest of the code)
                #  plyr::ldply(function(y){ #if ddply use .variables = .(h.lvl)
                
                # splits it into a list of dataframes accoprding to the assessed (hlvl) biotope classicifation level (4/5/6)
                # the dataframes now need to be compared, and use level 6 values, and only replace NA values using level 5 and 4, but not replace EUNIs codes provided for eunis codes.
                
                l6.tmp <- y[[3]]#"3" should be replaced by something to make it eunis level 6 category, which is currently [[3]]
                l5.tmp <- y[[2]] # eunis level 5
                l4.tmp <- y[[1]] # eunis level 4
                l.tmp <- l6.tmp # temporary storage variable
                l.consolidated <- l6.tmp # this will be the consolidated table into which the results of the various h.lvls per sbgr will be stored. It is set-up to take l6 values, which NA values will then become overridden.
                
                #-----------------------
                # QA code to test that this is working
                #all.equal(l.tmp, l6) # at this point the answer should be/is TRUE!, run again after ifelse statemetns to check that it is not, if NA values have been changed in places.
                #-----------------------
                
                
                
                # replace NA values in eunis level matrix, with actual eunis values at alevel 5, to obtain as comprehensive as possible a data matrix
                # i used two embedded for loops to ensure that element for element is being compared, and I get a table of the same dimensions as output. I am certain that there are smoother ways of doing this!
                for (i in seq_along(l6.tmp)) { # go along columns
                        for (j in 1:nrow(l6.tmp)) { # go along rows
                                l.tmp[j,i] <- ifelse(l6.tmp[j,i] == "NA" | l6.tmp[j,i] == "<NA>"| is.na(l6.tmp[j,i]),l5.tmp[j,i],l6.tmp[j,i])#compare and replace
                                
                        }
                }        
                
                #repeat the above, but now use eunis level 4 to replace any remaning NA values
                for (i in seq_along(l.tmp)) { # go along columns
                        for (j in 1:nrow(l.tmp)) { # go along rows
                                l.consolidated[j,i] <- ifelse(l.tmp[j,i] == "NA" | l.tmp[j,i] == "<NA>"| is.na(l.tmp[j,i]),l4.tmp[j,i],l.tmp[j,i])       
                        }
                }
                
                
                # Future improvement?
                #I am sure that the ifelse could be converted to a function and ran inside % % and a map functional to make the code smooth...but not sure how to sepcify to replace with a cross corresponding element..., so where v and w stand alone at this stage...
                #replacefn <- function(w,u){
                #        l.tmp <- ifelse(w %==% "NA" | w %==% "<NA>"| w %==% is.na(),v,w)#compare and replace
                #}
                
                return(l.consolidated) # this is the value that I want to the function to return: send this dataframe (the consolidated dataframe from teh three comapred dataframes) into the overarching function (this is then repeated for each sbgr)
                
                #to write into sepearate files remove "#" below, and check that there is a folder called output in the working directory, (getwd()).
                write.csv(l.consolidated, paste0("./sbgr_",unique(l.consolidated$sbgr),"_consolidated_hlvls.csv")) # write the result to file to inspect it,and ensure thta R object at the end is correct
                
                
                
                #})
                
                
                #sbgr.matched.btpt.w.rpl <- rbind(sbgr.matched.btpt.w.rpl, l.consolidated) # bind the resulting tables
        }, .progress = "text") # %>% saveRDS(sbgr.matched.btpt.w.rpl, paste0("./sbgr_matched_btpt_w_rpl.rds")) # activate you want to save as an independent R object for later use.
