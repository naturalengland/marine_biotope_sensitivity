
# combine the results and transpose into a more suitable format
# join sbgr to filter out irrelevant combinations from the results.files


uncertainty_of_biotope_proxy <- results.files %>% 
        plyr::ldply(function(x){ 
                library(magrittr)
                #find positions of columns to make selecting to columns for reordering them
                sbgr <- unique(x$sbgr) # which sub-bioregion are we working in? this wil lbe used to populate into table
                
                #calculate the difference between the mapped eunis habitat and a given sensitivity assessed biotope: used to inform sensitivity 
                x$lvl_dif <- x$h_lvl - x$l_lvl
                
                
                sbgr_pos <- grep("sbgr", colnames(x))
                eunis_code_gis_pos <- grep("eunis_code_gis", colnames(x))
                
                #reorder the table to a easier to understand format
                x_rearrange <- x %>% dplyr::select(
                        sbgr, 
                        lvl_dif,
                        eunis_code_gis, 
                        1:(eval(sbgr_pos)-1),# captures the columns preceeding sbgr
                        (eval(eunis_code_gis_pos)+1):length(colnames(x)) #captures the oclumns following sbgr
                )
                
                unfilterd_biotope_candidates <- x_rearrange %>% 
                        tidyr::gather(key = "eunis_biotope_key", value = "eunis_biotope_value", -sbgr, -lvl_dif, -eunis_code_gis) %>% 
                        dplyr::arrange(sbgr, eunis_code_gis, eunis_biotope_key)
                
                
                
                rm(x, x_rearrange) #housekeeping
                
                #-----------------------------------
                # bind/filter with sub-bioregional validated biotope list
                #tbl_eunis_sbgr is in global environment - already read in, so just called here
                
                sbgr_filtered_tbl_eunis_sbgr <- tbl_eunis_sbgr %>% #eval(quote(tbl_eunis_sbgr), env = .GlobalEnv) %>% 
                        dplyr::filter(SRCode == sbgr)
                
                sbgr_filtered_biotope_candidates <- left_join(unfilterd_biotope_candidates, sbgr_filtered_tbl_eunis_sbgr, by = c("eunis_biotope_value"  = "EUNISCode")) %>% 
                        dplyr::filter(RelevantToRegion == "Yes") %>% 
                        dplyr::select(sbgr, 
                                      eunis_code_gis, 
                                      eunis_biotope_assess = eunis_biotope_value, 
                                      lvl_dif) %>% 
                        dplyr::arrange(eunis_code_gis)
                
                #number of potetial (candidate) biotopes per mapped eunis code, grouped by the level difference between their eunis codes
                total_candidate_biotopes <- sbgr_filtered_biotope_candidates %>% 
                        dplyr::group_by(sbgr,
                                        eunis_code_gis,
                                        lvl_dif) %>% 
                        dplyr::tally()
                
                #uses formula lvl_dif to the power of log(n)
                uncertainty_per_eunis_per_lvl <- total_candidate_biotopes %>% 
                        dplyr::mutate(log_tally = n^log(lvl_dif+1))
                
                
                uncertainty_per_eunis_code_per_sbgr <- uncertainty_per_eunis_per_lvl %>% 
                        dplyr::ungroup() %>% 
                        dplyr::group_by(sbgr,
                                        eunis_code_gis) %>% 
                        dplyr::summarise(uncertainty_sim = 1/sum(log_tally))
        }, .progress = "text")
# Statements to use parallel not working - because it cannot call tbl_eunis_sbgr
#.parallel = TRUE, .paropts = list(.export=c("tbl_eunis_sbgr"), .options.snow=opts), .progress = "text") #.parallel = TRUE, .paropts = list(.options.snow=opts),
