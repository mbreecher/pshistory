library(reshape2)
library(plyr)
library(RecordLinkage)

# Pull in import functions
setwd('C:/R/workspace/shared')
source("import_functions.R")
setwd('C:/R/workspace/pshistory')
source("helpers.R")
source("recent_filings.R")

#import base info
  setwd('C:/R/workspace/source')
  services <- import_services(output = 'psh')
  timelog <- import_timelog()

# mold time data to ps history form
    #aggregate time by billable and non-billable
    time_billable <- aggregate(Hours ~ Account.Name + reportingPeriod + Billable, FUN = sum, data = timelog)
    names(time_billable) <- c("Account.Name", "reportingPeriod", "Billable", "Hours") #change names to something meaningful
    time_billable$xbrl_status <- NA
    time_billable[time_billable$Billable == 0 & !is.na(time_billable$Billable), ]$xbrl_status <- "Full Service"
    time_billable[time_billable$Billable == 1  & !is.na(time_billable$Billable), ]$xbrl_status <- "Billable"
    time_billable <- time_billable[!names(time_billable) %in% "Billable"]
    #aggregate total time
    time_total <- aggregate(Hours ~ Account.Name + reportingPeriod, FUN = sum, data = timelog)
    names(time_total) <- c("Account.Name", "reportingPeriod", "Hours") #change names to something meaningful
    time_total$xbrl_status <- "Total" #add billable status
    time_total <- time_total[,names(time_billable)] #rearrange to match ordering in time_by_qtr
    
    timelog <- rbind(time_billable, time_total)
    timelog <- dcast(time_all, Account.Name ~ reportingPeriod + xbrl_status, value.var = "Hours")

sec_data <- import_sec()
sales_rec <- import_sales_recommendations()

pshistory <- merge(services, timelog, "Account.Name", all.x = T)
recent_filings <- recent_filings(unique(services[,names(services) %in% c("Account.Name", "CIK")]), sec_data, flag = "QA")
pshistory <- merge(pshistory, recent_filings, "Account.Name", all.x = T)
pshistory <- merge(pshistory, sales_rec, "Account.Name", all.x = T)

#reorder columns
names <- c( names(services[grep('[a-z,A-Z]+', names(services), perl = T)]), #character column names
            names(recent_filings)[!(names(recent_filings) %in% c("Account.Name"))], #filing information
            names(services[grep('[1-9]+', names(services), perl = T)]), #scheduled services data
            names(sales_rec)[grep('[1-9]+', names(sales_rec), perl = T)], #sales recommendations
            names(timelog[grep('[1-9]+', names(timelog), perl = T)])) #timelog data

pshistory <- pshistory[,names]


# code to export 
setwd('C:/R/workspace/pshistory/output')
export <- pshistory
export <- data.frame(lapply(export, as.character), stringsAsFactors = F)
export[is.na(export)] <- ""
names(export) <- names(pshistory)
write.csv(export, file = "PSHistoryR.csv", row.names = F, na = "")

# #remove common names except Services.ID (collapsed time)
# duplicate_names <- names(services)[names(services) != "Services.ID"]
# timelog <- timelog[, -which(names(timelog) %in% duplicate_names)]


