# calcualte the number of missing habitats per data sens set

source("./functions/post_analyses/number_of_habitats_w_no_biotopes_data_def.R")
n_missing_habs_offshore_unfiltered <- is_data_deficient(x = unfiltered_biotope_sens_offshore)
n_missing_habs_inshore_unfiltered <- is_data_deficient(x = unfiltered_biotope_sens_inshore)
n_missing_habs_inshore_filtered <- is_data_deficient(x = filtered_biotope_sens)
