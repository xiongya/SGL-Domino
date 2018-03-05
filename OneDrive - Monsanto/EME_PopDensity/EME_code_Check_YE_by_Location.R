####################
### Calculate YE 
### By location
####################

setwd("~/OneDrive - Monsanto/EME_PopDensity")
data=read.csv("data_agg_by_plot_all_years_renamed.csv")

total=nrow(data)
# > total
# [1] 11881

#create a new dataset
data.new=cbind(data,rep(0,total));

for (i in seq(total)){
  
  names=data$HYBRID[i];
  loc=data$LOC[i];
  #new_loc=data$NEW.LOC[i];
  season=data$YEAR[i]
  #new_block=data$NEW.Block[i];
  region=data$Region[i]
  data_others=data[which(data$NEW.LOC==new_loc & data$HYBRID!=names & data$YEAR == season & data$Region == region),]
  mean_others=mean(data_others$mean_yield)
  data.new[i,15]=mean_others
  
}

colnames(data.new)[15] <- "YE"

#
data.new[which(data.new$Pre.commercial.name == "EF6506"),]
