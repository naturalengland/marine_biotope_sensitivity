# set user choice

choice <- OpsAct %>% filter(OperationCode == ops.number)
print(paste0("Your choice, Operation Code: ", choice$OperationCode, ", operation name: ", 
      choice$OperationName, ", Main Activity Code: ", choice$MainActCode, ". All activities within ",choice$MainActCode ," will be inlcuded."))

main.act.code <- paste0(choice$MainActCode,".")
