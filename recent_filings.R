recent_filings <- function(names, sec_data, flag = "standard"){
  setwd("C:/R/workspace/pshistory")
  source("helpers.R")
  
  names$found <- NA
  
  result <- c()
  #first pass, try using CIK
  for (loop_cik in unique(names[!is.na(names[,2]),2])){
    loopK <- sec_data[sec_data$cik %in% loop_cik & sec_data$form %in% c("10-K"),]
    loopQ <- sec_data[sec_data$cik %in% loop_cik & sec_data$form %in% c("10-Q"),]
    if (dim(loopK)[1] > 0){
      names[names$CIK %in% loop_cik,]$found <- 1
      loopK <- loopK[rev(order(loopK$filing_date)), ] #redundant, but better to be sure
      result <- rbind(result, c(loop_cik, unique(loopK$name)[1],unique(loopK$cik)[1],  
                                "10-K", loopK[1,"facts"]))
    }
    if (dim(loopQ)[1] > 0){
      names[names$CIK %in% loop_cik,]$found <- 1
      loopQ <- loopQ[rev(order(loopQ$filing_date)), ] #redundant, but better to be sure
      how_many <- min(dim(loopQ)[1], 3)
      for(i in 1:how_many){
        result <- rbind(result, c(loop_cik, unique(loopQ$name)[1],unique(loopQ$cik)[1], 
                                  paste(" 10-Q", i,  collapse = ""), 
                                  loopQ[i,"facts"]))  
      }
    }
  }
  
  #second pass for names
  for (company in unique(names[is.na(names[,3]),1])){
    best_match <- ClosestMatch(company, unique(sec_data$name))
    loopK <- sec_data[sec_data$name %in% best_match & sec_data$form %in% c("10-K"),]
    loopQ <- sec_data[sec_data$name %in% best_match & sec_data$form %in% c("10-Q"),]
    if (dim(loopK)[1] > 0){
      names[names$Account.Name %in% company,]$found <- 2
      loopK <- loopK[rev(order(loopK$filing_date)), ] #redundant, but better to be sure
      result <- rbind(result, c(company, unique(loopK$name)[1],mean(loopK$cik),  "10-K", loopK[1,"facts"]))
    }
    if (dim(loopQ)[1] > 0){
      names[names$Account.Name %in% company,]$found <- 2
      loopQ <- loopQ[rev(order(loopQ$filing_date)), ] #redundant, but better to be sure
      how_many <- min(dim(loopQ)[1], 3)
      for(i in 1:how_many){
        result <- rbind(result, c(company, unique(loopQ$name)[1],unique(loopQ$cik)[1],
#                         paste(year(loopQ$filing_date[i]),"Q", ceiling(month(loopQ$filing_date[i])/3)," 10-Q", collapse = ""), 
                          paste(" 10-Q", i,  collapse = ""), 
                          loopQ[i,"facts"]))  
      }
    }
  }
  result <- as.data.frame(result)
  names(result) <- c("Match", "SEC.Name","SEC.CIK",  "form", "facts")
  result$form <- trim.leading(result$form)
  result$facts <- as.numeric(as.character(result$facts))
  result <- dcast(data = result, formula = Match + SEC.Name + SEC.CIK ~ form, fun.aggregate = sum)

  if (flag %in% "standard"){
    result[, !names(result) %in% c("SEC.Name", "CIK")]
  }else if(flag %in% "QA"){
    result
  }
  
}