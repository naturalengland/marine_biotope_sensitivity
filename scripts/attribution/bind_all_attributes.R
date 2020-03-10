# Create a new table appending data from act_press_attribution_results and std_6_cols_attrb, but only housing the atribute names and descriptions

attribution_table <- act_press_attribution_results %>% 
        dplyr::select(attrb_name,
                      full_name,
                      attrb_descr) %>% 
        as_tibble() %>% 
        dplyr::bind_rows(std_6_cols_attrb, .id = "tbl_source") %>% 
        dplyr::arrange(desc(tbl_source)) %>% 
        dplyr::left_join(format, by = "attrb_name") %>% 
        dplyr::select(`Column name` = attrb_name,
                      `Full name` = full_name,
                      Format,
                      Description = attrb_descr
                      )

# act_press_attribution_results$attrb_descr