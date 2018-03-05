### Check PopDensity Model ###

setwd("~/OneDrive - Monsanto/EME_PopDensity")

# Read Data
data <- read.csv("data_agg_by_plot_all_years_renamed_YE.csv")

# Only Silage
data.silage <- subset(data, Region=="Silage")


# number of hybrids
data.silage.DKC2931 <- subset(data.silage, HYBRID == data.silage$HYBRID[1])

# Fit previous model
fit.DKC2931=lm(mean_yield ~ density+I(density^2)+YE+I(YE*density), data=data.silage.DKC2931);
summary(fit.DKC2931)


# number of hybrids
data.silage.DKC3142 <- subset(data.silage, HYBRID == "DKC3142")

# Fit previous model
fit.DKC3142 =lm(mean_yield ~ density+I(density^2)+YE+I(YE*density), data=data.silage.DKC3142);
summary(fit.DKC3142)

# setwd("~/OneDrive - Monsanto/E-GWS/modeling")
# load("P2.5_4_y6_RM110_BID_Gene.RData")
# write.csv(P2.5_4_y6_RM110_BID_Gene2,"P2.5_4_y6_RM110_BID_Gene.csv")


# Model checking 

# Hybrid: DKC3640
data.silage.DKC3640 <- subset(data.silage, HYBRID == "DKC3640")
fit.DKC3640=lm(mean_yield ~ density+I(density^2)+YE+I(YE*density), data=data.silage.DKC3640);
summary(fit.DKC3640)

density=seq(1,4000,5)
pred.value <- predict(fit.DKC3640,newdat=data.frame(density=density,YE=19),interval='confidence')
plot(density,pred.value[,"fit"],type="l",lwd=2,main="DKC3640",ylab="Yield")

max(pred.value[,1])
# [1] 20.33225

density[which.max(pred.value[,1])]
# [1] 271


# Hybrid: DKC3341
data.silage.DKC3341 <- subset(data.silage, HYBRID == "DKC3341")
fit.DKC3341=lm(mean_yield ~ density+I(density^2)+YE+I(YE*density), data=data.silage.DKC3341);
summary(fit.DKC3341)

density=seq(1,4000,5)
pred.value <- predict(fit.DKC3341,newdat=data.frame(density=density,YE=19),interval='confidence')
plot(density,pred.value[,"fit"],type="l",lwd=2,main="DKC3341",ylab="Yield")

max(pred.value[,1])
# [1] 20.33225

density[which.max(pred.value[,1])]
# [1] 271













