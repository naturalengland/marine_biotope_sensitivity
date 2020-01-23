# Create a new table appending data from act_press_attribution_results and std_6_cols_attrb, but only housing the atribute names and descriptions

attribution_table <- act_press_attribution_results %>% 
        dplyr::select(attrb_name,
                      attrb_descr) %>% 
        as_tibble() %>% 
        dplyr::bind_rows(std_6_cols_attrb, .id = "tbl_source") %>% 
        dplyr::arrange(desc(tbl_source)) %>% 
        dplyr::select(attrb_name,
                      attrb_descr)