#read activity and operations table to make a list for user to select from

read.access.op.act <- function(db.p = db.path, drv.p = drv.path){
        
        #specificy the connection to the database
        connection.path <- paste0("Driver={",drv.path,"};DBQ=",db.path)#server=",srv.host,"; #server may need to be defined for other SQL database formats
        
        # Connect to Access db to allow reading the data into R environment.
        conn <- odbcDriverConnect(connection.path)
        
        #read tblOperationLUT
        tblOperationLUT <- sqlQuery(conn, paste("SELECT tblOperationLUT.*
                                                FROM tblOperationLUT;")) %>%
                arrange(as.integer(OperationCode))
        
        #read tblActivityLUT
        tblActivityLUT <- sqlQuery(conn, paste("SELECT tblActivityLUT.*
                                               FROM tblActivityLUT;"))
        tblActivityLUT <- as.data.frame(sapply(X = tblActivityLUT, FUN = as.character), stringsAsFactors=FALSE)
        tblActivityLUT$OperationCode <- as.integer(tblActivityLUT$OperationCode)
        
        #source("./functions/00_generate_list_of_ops_activities.R")
        #OpsAct <- OpActCodes(act = tblActivityLUT, ops = tblOperationLUT)
        
        tblActivityLUT %>% separate(ActivityCode, into = "MainActCode", sep = "\\..*")  %>%
                        select(OperationCode, MainActCode) %>%
                        distinct() %>%
                        left_join(tblOperationLUT, by = "OperationCode") %>%
                        select(OperationCode,OperationName,  MainActCode) %>%
                        arrange(OperationCode)
}
