####################
### Calculate YE ###
####################

# install.packages("plyr")
library(plyr)

#Input data:
#setwd("C://Users/xxli12/OneDrive - Monsanto/EME_PopDensity")
setwd("~/OneDrive - Monsanto/EME_PopDensity")
data=read.csv("data_agg_by_plot_all_years_renamed.csv")

total=nrow(data)

#create a new dataset
data.new=cbind(data,rep(0,total));

#data maniputation
for (i in seq(total)){
  
  names=data$HYBRID[i];
  new_loc=data$NEW.LOC[i];
  new_block=data$NEW.Block[i];
  data_others=data[which(data$NEW.LOC==new_loc & data$NEW.Block==new_block & data$HYBRID!=names),]
  mean_others=mean(data_others$mean_yield)
  data.new[i,15]=mean_others
  
}

colnames(data.new)[15] <- "YE"

### debug ###

#P9903, M2 block
temp=data.new[which(data.new$HYBRID=="P9903"),15]
temp[59]=temp[58]
data.new[which(data.new$HYBRID=="P9903"),15]=temp

#temp=data.new[which(data.new$HYBRID=="DKC6664"),] 
#temp[148:154,]

#index.NA=which(is.na(data.new$YE)=="TRUE")
#data.new=data.new[-index.NA,]

#save new dataset
write.csv(data.new,"data_agg_by_plot_all_years_renamed_YE.csv")
# data.new=read.csv("data_agg_by_plot_all_years_renamed_YE.csv")

#############################
### Model Fitting ###########
### note: adding R square ###
#############################

# Year 2015;
data.new.15=data.new[which(data.new$YEAR==2015),]
names.h=unique(data.new.15$HYBRID)

results.15=matrix(0,nrow=length(names.h),ncol=8)
colnames(results.15) <- c("Year","Hybrid","intercept","density","density^2","YE","YE*density","R-squared")
results.15[,1]=rep(2015,length(names.h))


for (i in seq(length(names.h))){
  data.new.15.h=data.new.15[which(data.new.15$HYBRID==names.h[i]),];
  fit.15=lm(mean_yield ~ density+I(density^2)+YE+I(YE*density), data=data.new.15.h);
  results.15[i,-1]=c(as.vector(names.h)[i],coef(fit.15),summary(fit.15)$r.squared)
}

results.15=as.data.frame(results.15)

# Year 2016
data.new.16=data.new[which(data.new$YEAR==2016),]
names.h=unique(data.new.16$HYBRID)

results.16=matrix(0,nrow=length(names.h),ncol=8)
colnames(results.16) <- c("Year","Hybrid","intercept","density","density^2","YE","YE*density","R-squared")
results.16[,1]=rep(2016,length(names.h))

results2.16=matrix(0,nrow=length(names.h),ncol=13)
colnames(results2.16) <- c("Year","Hybrid","intercept","se.inter","density","se.den","density^2","se.den2","YE","se.ye","YE*density","se.yeden","R-squared")
results2.16[,1]=rep(2016,length(names.h))


for (i in seq(length(names.h))){
  data.new.16.h=data.new.16[which(data.new.16$HYBRID==names.h[i]),];
  fit.16=lm(mean_yield ~ density+I(density^2)+YE+I(YE*density), data=data.new.16.h);
  
  results.16[i,-1]=c(as.vector(names.h)[i],coef(fit.16),summary(fit.16)$r.squared)
  
  sd.tmp=summary(fit.16)$coefficients[,2]
  coef.tmp=summary(fit.16)$coefficients[,1]
  results2.16[i,-1]=c(as.vector(names.h)[i],coef.tmp[1],sd.tmp[1],coef.tmp[2],sd.tmp[2],coef.tmp[3],sd.tmp[3],coef.tmp[4],sd.tmp[4],coef.tmp[5],sd.tmp[5],summary(fit.16)$r.squared)
  
}

results.16=as.data.frame(results.16)
results2.16=as.data.frame(results2.16)

# Year 2017 
data.new.17=data.new[which(data.new$YEAR==2017),]
names.h=unique(data.new.17$HYBRID)

results.17=matrix(0,nrow=length(names.h),ncol=8)
colnames(results.17) <- c("Year","Hybrid","intercept","density","density^2","YE","YE*density","R-squared")
results.17[,1]=rep(2017,length(names.h))


for (i in seq(length(names.h))){
  data.new.17.h=data.new.17[which(data.new.17$HYBRID==names.h[i]),];
  fit.17=lm(mean_yield ~ density+I(density^2)+YE+I(YE*density), data=data.new.17.h);
  results.17[i,-1]=c(as.vector(names.h)[i],coef(fit.17),summary(fit.17)$r.squared)
}

results.17=as.data.frame(results.17)


results.final.coef=rbind(results.15,results.16,results.17)
write.csv(results.final.coef,"data_agg_by_plot_all_years_renamed_YE_coef.csv")
# results.final.coef=read.csv("data_agg_by_plot_all_years_renamed_YE_coef.csv")

#################
### YE Levels ###
#################

#Year 2015

#data.new.15
names.h=unique(data.new.15$HYBRID)

range.h.15=matrix(0,nrow=length(names.h),ncol=4);
colnames(range.h.15) <- c("Year", "Hybrid", "min", "max")
range.h.15[,1] <- rep(2015, length(names.h))

for (i in seq(length(names.h))){
  range.temp=range(data.new.15[which(data.new.15$HYBRID==names.h[i]),15]);
  range.h.15[i,-1] <- c(as.vector(names.h)[i],range.temp)
}

range.h.15=as.data.frame(range.h.15)



#Year 2016

names.h=unique(data.new.16$HYBRID)

range.h.16=matrix(0,nrow=length(names.h),ncol=4);
colnames(range.h.16) <- c("Year", "Hybrid", "min", "max")
range.h.16[,1] <- rep(2016, length(names.h))

for (i in seq(length(names.h))){
  range.temp=range(data.new.16[which(data.new.16$HYBRID==names.h[i]),15]);
  range.h.16[i,-1] <- c(as.vector(names.h)[i],range.temp)
}

range.h.16=as.data.frame(range.h.16)


#Year 2017

names.h=unique(data.new.17$HYBRID)

range.h.17=matrix(0,nrow=length(names.h),ncol=4);
colnames(range.h.17) <- c("Year", "Hybrid", "min", "max")
range.h.17[,1] <- rep(2017, length(names.h))

for (i in seq(length(names.h))){
  range.temp=range(data.new.17[which(data.new.17$HYBRID==names.h[i]),15]);
  range.h.17[i,-1] <- c(as.vector(names.h)[i],range.temp)
}

range.h.17=as.data.frame(range.h.17)

results.final.range=rbind(range.h.15,range.h.16,range.h.17)
results.final.coef.range=cbind(results.final.coef,results.final.range[,-c(1:2)])
write.csv(results.final.coef.range,"data_agg_by_plot_all_years_renamed_YE_coef_range.csv")
# results.final.coef.range=read.csv("data_agg_by_plot_all_years_renamed_YE_coef_range.csv")

#############################################
### Calculate Plot_Number and Site_Number ###
#############################################


#Year 2015
#head(data.new.15)
#data.new=data.new[,-1]
data.plot.15=data.new.15[,c(1,6,13,14)]
#names.h=unique(data.new.15$HYBRID)
#data.plot.15=unique(data.plot.15)
num.row=length(unique(data.plot.15$HYBRID))
data.plot.15=cbind(rep(2015,num.row),count(data.plot.15,'HYBRID'))
colnames(data.plot.15)[1]<-"YEAR"
colnames(data.plot.15)[3]<-"Plot_Num"

data.site.15=data.new.15[,c(1,6,13)]
data.site.15=unique(data.site.15)
data.site.15=cbind(rep(2015,num.row),count(data.site.15,'HYBRID'))

data.plot.site.15=cbind(data.plot.15,data.site.15[,3])
colnames(data.plot.site.15)[4]<-"Site_Num"


#Year 2016
data.plot.16=data.new.16[,c(1,6,13,14)]
#data.plot.16=unique(data.plot.16)
num.row=length(unique(data.plot.16$HYBRID))
data.plot.16=cbind(rep(2016,num.row),count(data.plot.16,'HYBRID'))
colnames(data.plot.16)[1]<-"YEAR"
colnames(data.plot.16)[3]<-"Plot_Num"

data.site.16=data.new.16[,c(1,6,13)]
data.site.16=unique(data.site.16)
data.site.16=cbind(rep(2016,num.row),count(data.site.16,'HYBRID'))

data.plot.site.16=cbind(data.plot.16,data.site.16[,3])
colnames(data.plot.site.16)[4]<-"Site_Num"


#Year 2017
data.plot.17=data.new.17[,c(1,6,13,14)]
#data.plot.17=unique(data.plot.17)
num.row=length(unique(data.plot.17$HYBRID))
data.plot.17=cbind(rep(2017,num.row),count(data.plot.17,'HYBRID'))
colnames(data.plot.17)[1]<-"YEAR"
colnames(data.plot.17)[3]<-"Plot_Num"

data.site.17=data.new.17[,c(1,6,13)]
data.site.17=unique(data.site.17)
data.site.17=cbind(rep(2017,num.row),count(data.site.17,'HYBRID'))

data.plot.site.17=cbind(data.plot.17,data.site.17[,3])
colnames(data.plot.site.17)[4]<-"Site_Num"

data.plot.site=rbind(data.plot.site.15,data.plot.site.16,data.plot.site.17)
colnames(data.plot.site)[1]="Year"
colnames(data.plot.site)[2]="Hybrid"

results.final.coef.range.plot.site=merge(results.final.coef.range,data.plot.site,by=c("Year","Hybrid"),all=TRUE)
write.csv(results.final.coef.range.plot.site,"data_agg_by_plot_all_years_renamed_YE_coef_range_plot_site.csv")

#####################################
### New file ########################
### After manual data maniputation###
#####################################

setwd("C://Users/xxli12/OneDrive - Monsanto/EME_PopDensity")
data.final=read.csv("data_agg_by_plot_all_years_renamed_YE_coef_range_plot_site.csv")
data.final=data.final[,-1]

index.pick=which(data.final$PLOT_COUNT_TOO_SMALL=="N" & data.final$SITE_COUNT_TOO_SMALL=="N" & data.final$YE_RANGE_TOO_SMALL=="N" & data.final$POS_density_densit=="N" & data.final$NEG_YieldEnv=="N" & data.final$R_squared_LOW=="N")
data.final.use=cbind(data.final, rep(0,nrow(data.final)))
colnames(data.final.use)[20] <- "Use"
data.final.use[index.pick,20] <- "Y"
data.final.use[-index.pick,20] <- "N"


data.final.use[index.pick,] 


den_curve=function(b_0,b_1,b_2,b_3,b_4,x,y){
  b_0+b_1*x+b_2*x^2+b_3*y+b_4*x*y
}


density=seq(1,140,2)
#YE=seq(3,25,length.out = length(density))
#data.tmp=cbind(density,YE)

new.pred=predict(fit.16,newdat=data.frame(density=density,YE=16),interval='confidence')
plot(density,new.pred[,"fit"],type="l",xlim=c(-10,150),ylim=c(5,20),lwd=2,main="EQ3472",ylab="Yield")
lines(density,new.pred[,"lwr"],lty="dotted",col="red",lwd=2)
lines(density,new.pred[,"upr"],lty="dotted",col="red",lwd=2)
new.pred2=predict(fit.17,newdat=data.frame(density=density,YE=16),interval='confidence')
lines(density,new.pred2[,"fit"],type="l",col="blue",lwd=2)
legend("bottomright",c("2016","2017"),lty=rep(1,2),col=c("red","blue"),lwd=rep(2,2))






C1=den_curve(-4.14,0.13,-0.000825667,0.81,0.000849279,density,10)
C2=den_curve(-6.08,0.13,-0.000640285,1.03,0.000274531,density,10)
C3=-3.271065 0.1290663 -0.001039858 0.4110967 0.006739447
C4=

plot(density,C1,type="l",xlim=c(-1,150),ylim=c(3,15))
points(density,C2,col="red",type="l")


### Graphic results ###
data.graph=read.csv("plot.csv")


den_curve=function(b_0,b_1,b_2,b_3,b_4,x,y){
  b_0+b_1*x+b_2*x^2+b_3*y+b_4*x*y
}

density=seq(0,140,2)
C1=den_curve(-4.5770998, 0.19019585, -0.001595681, 0.1062936,  0.010072010,density,10)
C2=den_curve(-5.7295759, 0.16073393, -0.001015546, 0.6082961,  0.004242743,density,10)
plot(density,C1,type="l",xlim=c(-1,150),ylim=c(3,15),ylab="Yield",xlab="Density",main="Hybrid: DKC4069, YE_range(4,16), value=10",lwd=3)
points(density,C2,col="red",type="l",lwd=3)
legend("topright",c("2017","2016"),lty=rep(1,2),col=c("black","red"),lwd=rep(3,2))

