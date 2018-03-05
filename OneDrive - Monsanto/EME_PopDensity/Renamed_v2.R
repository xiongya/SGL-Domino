
### Location Rename

data <- read.csv("2016_cleanded_all_in_one.csv")
data2 <- read.csv("List_location_renaming v2.csv")


library(plyr)

Data <- merge(data, data2, by = c("LOC", "Block"))
write.csv(Data, "2016_cleanded_all_in_one_Renamed_v2.csv")

