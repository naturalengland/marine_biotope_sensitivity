concat_prefix_act_press_codes_fn <- function(x, prfix){ # x is the queried data set from the main script
        
        concat_codes_result <- data.frame(matrix(nrow = nrow(x), ncol = length(prfix)))
        
        for (i in seq_along(prfix)) {
                
                concat_codes_raw <- paste0(prfix[i], "_", x$ActivityCode,"_", x$PressureCode)
                
                concat_codes_exchange_pts_for_underscore <- str_replace_all(concat_codes_raw,"[.]","_") 
                concat_codes_result[,i] <- concat_codes_exchange_pts_for_underscore
                
                }
        names(concat_codes_result) <- prfix
        concat_codes_result
        
}
