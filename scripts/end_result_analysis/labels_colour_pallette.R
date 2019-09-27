# colour schema

sens_cat_1 <- c(label="High", value="1", alpha="255", color="#900a0a")
sens_cat_2 <- c(label="Medium", value="2", alpha="255", color="#e94026")
sens_cat_3 <- c(label="Low", value="3", alpha="255", color="#ff9d09")
sens_cat_4 <- c(label="Habitat data deficient - potentially sensitive", value="0", alpha="255", color="#ffff00")
sens_cat_5 <- c(label="Insufficient sensitivity evidence", value="4", alpha="255", color="#ffffa1")
#sens_cat_6 <- c(label="No sensitivity assessment carried out", value="5", alpha="255", color="#b2df8a") # removed becuase including it causes problems for the plot as this category was absent!!
sens_cat_7 <- c(label="Not sensitive", value="6", alpha="255", color="#33a02c")
sens_cat_8 <- c(label="No direct effects", value="7", alpha="255", color="#7099b8")
sens_cat_9 <- c(label="Activity-pressure combination not relevant to biotope", value="8", alpha="255", color="#182593")

labels_list <- list(sens_cat_1,
                 sens_cat_2,
                 sens_cat_3,
                 sens_cat_4,
                 sens_cat_5,
                 #sens_cat_6,
                 sens_cat_7,
                 sens_cat_8,
                 sens_cat_9)

labels_df <- as.data.frame(t(do.call(cbind, labels_list)))

labels_df$label <- factor(labels_df$label, levels =  c("High", 
                                              "Medium",
                                              "Low", 
                                              "Habitat data deficient - potentially sensitive",
                                              "Insufficient sensitivity evidence",
                                              #"No sensitivity assessment carried out",
                                              "Not sensitive",
                                              "No direct effects",
                                              "Activity-pressure combination not relevant to biotope"))
