recent_filings <- function(names, sec_data){
  setwd("C:/R/workspace/pshistory")
  source("helpers.R")
  
  result <- c()
  for (company in unique(names)){
    best_match <- ClosestMatch(company, unique(sec_data$name))
    loopK <- sec_data[sec_data$name %in% c(best_match) & sec_data$form %in% c("10-K"),]
    loopQ <- sec_data[sec_data$name %in% c(best_match) & sec_data$form %in% c("10-Q"),]
    if (dim(loopK)[1] > 0){
      result <- rbind(result, c(company, loopK$name[1],loopK$cik[1],  "10-K", loopK[1,"facts"]))
    }
    if (dim(loopQ)[1] > 0){
      loopQ <- loopQ[rev(order(loopQ$filing_date)), ] #redundant, but better to be sure
      how_many <- min(dim(loopQ)[1], 3)
      for(i in 1:how_many){
        result <- rbind(result, c(company, loopQ$name[1],loopQ$cik[1],
#                         paste(year(loopQ$filing_date[i]),"Q", ceiling(month(loopQ$filing_date[i])/3)," 10-Q", collapse = ""), 
                          paste(" 10-Q", i,  collapse = ""), 
                          loopQ[i,"facts"]))  
      }
    }
  }
  result <- as.data.frame(result)
  names(result) <- c("Account.Name", "SEC.Name","CIK",  "form", "facts")
  result$form <- trim.leading(result$form)
  
  result <- dcast(result, Account.Name ~ form + SEC.Name + CIK)
  result
  
}