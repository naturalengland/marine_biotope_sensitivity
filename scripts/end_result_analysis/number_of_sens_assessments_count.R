# count the number of sensitivity assessments, biotopes assessed and confidence assessments 

source("./functions/post_analyses/keyword_column_count.R") #this reads in the function that will count the number of columns, based on thedata and keyword

# Results
## Filtered biotope (inshore)
# i.e. number of sitivity assessments, biotopes assessed and confidence assessments for all fishing activities
keyword_column_count(x = filtered_biotope_sens, keyword = "sens") #columns 
keyword_column_count(x = filtered_biotope_sens, keyword = "assess")
keyword_column_count(x = filtered_biotope_sens, keyword = "conf")

# Results
## Unfiltered biotope - INSHORE
# i.e. number of sitivity assessments, biotopes assessed and confidence assessments for all fishing activities
keyword_column_count(x = unfiltered_biotope_sens_inshore, keyword = "sens") #columns 
keyword_column_count(x = unfiltered_biotope_sens_inshore, keyword = "assess")
keyword_column_count(x = unfiltered_biotope_sens_inshore, keyword = "conf")

# Results
## Unfiltered biotope - OFFSHORE
# i.e. number of sitivity assessments, biotopes assessed and confidence assessments for all fishing activities
keyword_column_count(x = unfiltered_biotope_sens_offshore, keyword = "sens") #columns 
keyword_column_count(x = unfiltered_biotope_sens_offshore, keyword = "assess")
keyword_column_count(x = unfiltered_biotope_sens_offshore, keyword = "conf")
