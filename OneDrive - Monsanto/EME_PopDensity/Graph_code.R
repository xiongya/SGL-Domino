
### Modeling - Graphical results

 data <- read.csv("2016_cleanded_all_in_one_renamed.csv")
 
 
 data_6GRU2L <- subset(data, LOC == "6GRU2 L")
 
 data_6GRU2L_1 <- subset(data_6GRU2L, Block == "1")
 data_6GRU2L_2 <- subset(data_6GRU2L, Block == "2")
 data_6GRU2L_3 <- subset(data_6GRU2L, Block == "3")
 data_6GRU2L_4 <- subset(data_6GRU2L, Block == "4")
 
 plot(data_6GRU2L_1$Longitude, data_6GRU2L_1$Latitude, col="red", pch=16, xlim = c(36.460, 36.464), 
        ylim = c(50.405, 50.409), xlab = "Longitude", ylab = "Latitude", main = "LOC: 6GRU2 L")
 points(data_6GRU2L_2$Longitude, data_6GRU2L_2$Latitude, col="blue", pch=24)
 points(data_6GRU2L_3$Longitude, data_6GRU2L_3$Latitude, col="green", pch=7)
 points(data_6GRU2L_4$Longitude, data_6GRU2L_4$Latitude, col="orange", pch=13)
 legend("topleft", c("Block 1", "Block 2", "Block 3", "Block 4"), col=c("red", "blue", "green", "orange"),
          pch=c(16,24,7,13))
 