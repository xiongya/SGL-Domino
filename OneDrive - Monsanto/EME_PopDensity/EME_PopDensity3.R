
### Modeling on Previous Year YE calculation

data <- read.csv("YLD_YE_ALL_EME.csv")

data.silage <- subset(data, setgroup == "Silage")

# fit <- lm(data.silage$YLD ~ poly(data.silage$density, data.silage$YieldEnv, degree = 2, 
#                                  raw = TRUE))

hybrid.silage <- unique(data.silage$hybrid)

coef.silage <- matrix(0, nrow=length(hybrid.silage), ncol=6)

for ( i in seq(length(hybrid.silage))){
  
  data.model <- subset(data.silage, hybrid == hybrid.silage[i])
  fit <- lm(data.model$YLD ~ poly(data.model$density, data.model$YieldEnv, degree = 2, 
                                      raw = TRUE))
  coef.pvalue <- summary(fit)$coefficients[,4]
  
  for ( j in seq(length(coef.pvalue))){
    if (coef.pvalue[j] > 0.05){
      coef.pvalue[j] <- 0
    }else{
      coef.pvalue[j] <- 1
    }
  }
  
  coef.silage[i,1:length(coef.pvalue)] <-  summary(fit)$coefficients[,1]*coef.pvalue
  
  print(i)
  
}

colnames(coef.silage) <- c("Intercept", "density", "density^2", "YE", "density*YE", "YE^2")
result <- cbind(hybrid.silage, data.frame(coef.silage))
