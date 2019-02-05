#function(#populate columns with EUNIS codes according to the EUNIS level)

# Eunis code per level
z <- c()#vector("list", nrow(EunisAssessed))
nam <- c()
eunis.levels <- function(x = eunis.lvl.assessed, lvl = 1:6){
        for (i in seq_along(lvl)){
                
                #empty temporary data matrix
                y <- matrix(NA, ncol = 1,nrow = nrow(x))
                
                #replace NA values with EUNIS codes where levels match
                y[x$level == i] <- substr(as.character(x$EUNISCode[x$level == i]), 1,i+1)
                y <- as.data.frame(y, stringsAsFactors = FALSE) # save as dataframe
                
                #make names and assign them
                nam[i] <- paste("l", i, sep = "")
                #names(y) <- nam
                
                #store value
                z[[i]] <- y
                
        }
        names(z) <- nam
        z #call z so that it becomes the stored value
}