library(reshape2)
library(plyr)

# Pull in import functions
setwd('C:/R/workspace/pshistory')
source("import_functions.r")

#import and cleanup
setwd('C:/R/workspace/pshistory/source')
services <- import_services()
timelog <- import_timelog()
sec_data <- import_sec()

pshistory <- merge(services, timelog, "Account.Name", all.x = T)

sec_avgs <- ddply(sec_data, .(name, cik, form), 
                     summarize, avg_facts=mean(facts))

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

