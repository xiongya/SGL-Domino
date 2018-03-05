### Read in Data ###

setwd("~/Downloads")

list <- read.csv("List_location_renaming_v2.csv")
cleanded_all_in_one_2016 <- read.csv("2016_cleanded_all_in_one.csv")

tmp <- merge(cleanded_all_in_one_2016, list, by.x = c("LOC","Block"), by.y = c("LOC","Block"), all.x = TRUE)

write.csv(tmp, "2016_cleanded_all_in_one_renamed.csv",row.names = FALSE)
