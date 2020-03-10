# make table of unique combinations of Activity and pressures
unique_activity_pressure_codes <- function(x){ # x is dataframe with a column with activity codes and a column of pressure codes

activity_pressure_combs <-
        x %>% dplyr::select(ActivityCode,
                            PressureCode, 
                            ActivityName,
                            PressureName) %>%
        dplyr::distinct()
}
