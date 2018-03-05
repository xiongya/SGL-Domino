





/* SS MODS TO RUN ON MOST RECENT 'ALL IN ONE' DATASET */


/* ISSUES WITH MIX OF NUMERIC AND ALPHA-NUMERIC BLOCK NAMES!!!!!!!!!!!!!! */



**** Gen V project ****
**** 2. Diagnostics and Data QC ****

** Settings **;
goptions device=png;
options mprint orientation=portrait ls=80 ps=55 NOOVP noxwait noxsync symbolgen;
** Set library **;
/*
libname out 'C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\SASFILES\SASOUTPUT';
*/



DM LOG 'CLEAR';

/* PARTIALLY PROCESSED DATASET FROM FIRST PROGRAM ... */

%LET IN_DIR=C:\Users\sbstar\sbstar\density\FINAL_ANALYSIS\DATA\PROCESSED;

LIBNAME IN "&IN_DIR";

%LET OUT_DIR=C:\Users\sbstar\sbstar\density\FINAL_ANALYSIS\DATA\PROCESSED;

LIBNAME OUT "&OUT_DIR";






** Calling dataset **;
DATA YLD; set IN.YLD_YE_ALL_EME; 
if yld=. then delete;
if yieldenv=. then delete; run;
proc print data=YLD(obs=10); run;

** missing values due to lack of estimation of YieldENv;
proc print data=IN.YLD_YE_ALL_EME; where yieldenv=. ; run;
*data test; 
*set out.YLD_YE_ALL_Comm; 
*if yieldenv=. ; run;
*proc print data=test; run;

** Checking dataset and creating ordered index **;
proc sort data=YLD; by season setgroup hybrid field block; run;
data yld; set yld; obsid=_n_; run;
proc print data=yld(obs=10); run;

*** Data QC Procedure ***
** Fit surface model to extract residuals **;
ods exclude all;
proc sort data=YLD; by season setgroup hybrid field block;
PROC MIXED DATA=YLD;
by season setgroup hybrid; 
MODEL YLD=density density*density YieldEnv density*YieldEnv /solution outp=outr residual influence; *left out for this analysis: YieldEnv YieldEnv*YieldEnv density*YieldEnv;
ods output SolutionF=SolutionFr influence=influencer fitstatistics=fitstatisticsr nobs=nobsr;
RUN;
ods exclude none;
proc print data=solutionfr(obs=10); run;
proc print data=outr(obs=10); run;
proc print data=influencer(obs=10); run;
proc print data=fitstatisticsr(obs=10); run;
proc print data=nobsr(obs=10); run;

** fixing outputs and merging;
data influencer; set influencer; obsid=_n_; run;
data nobsr; set nobsr; where label='Number of Observations Used'; keep season setgroup hybrid Label NObsUsed; run;
data influencer2; merge influencer nobsr; by season setgroup hybrid; run;
proc print data=influencer2(obs=10); run;
proc univariate data=influencer2 plot; var NObsUsed; run; 


* computing average yield per rep;
proc sort data=outr; by season setgroup field block; run; 
proc means data=outr noprint; by season setgroup field block; var yld;
output out=repyld(drop=_FREQ_ _TYPE_) mean=RepYield cv=RepCV; run;
proc sort data=outr; by season setgroup field block; run;
proc sort data=repyld; by season setgroup field block; run;
data outr2; merge outr repyld; by season setgroup field block; run;
data outr2; set outr2; 
if yld<repyield then devfromrep=((repyield-yld)/repyield)*100;
if yld>repyield then devfromrep=((yld-repyield)/repyield)*100;
devfromcv=devfromrep-(2*repcv); if devfromcv<0 then devfromcv=0;
run; 
proc print data=outr2(firstobs=20 obs=40); run;

/* proc univariate data=outr2; var repyield repcv devfromrep devfromcv; histogram repyield repcv devfromrep devfromcv; run; */

proc univariate data=yld; var yld yieldenv; run;

** Error metrics and Average residuals by SITE **;
proc sort data=outr2; by obsid; run;
proc sort data=influencer2; by obsid; run;
data outallres; merge outr2 influencer2; by obsid; drop label; * modified to TOn/ha;
* yield; yldscore=0;
if yld<7 then yldscore=0.8+((100-0.8)/(1+((yld/4)**7))); if yld>20 then yldscore=100+((1.5-100)/(1+((yld/22)**24)));
* Average yield per rep and deviation from rep; repscore=0;
repscore=100+((0.5-100)/(1+((devfromcv/13)**10)));
* moisture; mstscore=0;
if mst<15 then mstscore=0.1+((98.3-0.1)/(1+((mst/10.3)**14.2))); if mst>18 then mstscore=95.3+((0.01-95.3)/(1+((mst/22.2)**41.5))); 
** agronomics penalization; agpen=(yldscore*0.4)+(mstscore*0.4)+(repscore*0.2); 
agflag='Greenpass'; if agpen>50 then agflag='Yellow'; if agpen>60 then agflag='Red'; 
** CV for each Rep; repcvscore=0;
repcvscore=100+((0.5-100)/(1+((repcv/25)**3.9)));
repflag='Greenpass'; if repcvscore>70 then repflag='Yellow'; if repcvscore>80 then repflag='Red';
* absolute of Residual; absres=abs(resid); resscore=0;
resscore=100+((1.8-100)/(1+((absres/6)**7.7)));
* absolute of PRESS; abspress=abs(pressres); pressscore=0;
pressscore=100+((1.8-100)/(1+((abspress/6)**7.7)));
* absolute of Studentized residual; absstu=abs(student); stuscore=0;
stuscore=98+((0.1-98)/(1+((absstu/2)**15.4)));
* Leverage; gammalev=14.6*(nobsused**-0.9); levscore=0;
levscore=100+((2.3-100)/(1+((leverage/gammalev)**8)));
* Cooks Dist; gammaCook=2.3*(nobsused**-0.53); cookscore=0;
cookscore=100+((2.3-100)/(1+((cookd/gammacook)**7)));
* absolute of CovRatio minus one; gammaCov=20.7*(nobsused**-0.85); covminus1=abs(covratio-1); covscore=0;
covscore=99+((2.5-99)/(1+((covminus1/gammacov)**14.5)));
** influence in parameter estimation; parpen=(levscore*0.4)+(cookscore*0.6); 
parflag='Greenpass'; if parpen>75 then parflag='Yellow'; if parpen>85 then parflag='Red'; if levscore>95 OR cookscore>95 then parflag='Red';
** influence in precision; accpen=covscore; 
accflag='Greenpass'; if accpen>85 then accflag='Yellow'; if accpen>95 then accflag='Red';
** influence in predicted values; prepen=(resscore*0.2)+(pressscore*0.5)+(stuscore*0.3); 
preflag='Greenpass'; if prepen>80 then preflag='Yellow'; if prepen>90 then preflag='Red'; if resscore>95 OR pressscore>95 OR stuscore>95 then preflag='Red'; 
** modeling penalization; modpen=(parpen*0.45)+(accpen*0.1)+(prepen*0.45); 
modflag='Greenpass'; if modpen>50 then modflag='Yellow'; if modpen>60 then modflag='Red'; 
** weighted score; wpen=0;
wpen=(agpen*0.35)+(modpen*0.65);
wflag='GreenPass'; if wpen>35 then wflag='Yellow'; if wpen>40 then wflag='Red';
run;
proc print data=outallres(obs=20); run;

** checking distribution of scores;
proc univariate data=outallres normal plot; var agpen modpen wpen; run; 

** Extracting all extreme observations in new tables;
data ExtremeAg; set outallres; where agflag='Yellow' OR agflag='Red'; 
keep season Field YLD MST hybrid setgroup region density block obsid Pred Resid yldscore mstscore repscore agpen agflag modflag wpen wflag; run;
*proc print data=ExtremeAg; run;
data ExtremeMod; set outallres; where modflag='Yellow' OR modflag='Red'; 
keep season Field YLD MST hybrid setgroup region density block obsid Pred Resid parpen accpen prepen modpen modflag wpen wflag; run;
*proc print data=ExtremeMod; run;

* Extracting for Wflag;
data OutliersW; set outallres; where wflag='Red'; 
keep season Field YLD MST hybrid setgroup density block obsid PlotRange PlotColumn Pred Resid agpen modpen wpen wflag Deactivated; run;
proc print data=OutliersW; run;


** Checking penalization scores by field and hybrid **;
proc univariate data=outliersw; var wpen; histogram wpen; run;
proc sort data=outliersw; by season setgroup; run;
proc freq data=outliersw; where wpen>40; by season setgroup; tables field*hybrid; run;
proc freq data=outliersw; where wpen>40; by season ; tables field*setgroup; run;
/* 
symbol1 v=dot ;
proc gplot data=outallres; plot wpen*modpen/href=70 vref=45; run;
proc gplot data=outallres; plot wpen*agpen/href=80 vref=45; run;
*/

** Save data in permanent SAS data set **;
proc print data=outallres(obs=10); run;
data out.DBFlags_QC_All_EME; set outallres; run;

/* ????? */
/*
data 'C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\SASFILES\SASOUTPUT\DBFlags_QC_All_EME'; set outallres; run;
*/

proc export data=outallres outfile="&OUT_DIR.\DBFlags_QC_All_EME.CSV" 
dbms=csv replace; run;

data finalyld; set outallres;
if wpen>40 then delete; if modpen>80 then delete; if agpen>80 then delete;
keep season hybrid family density block MST YLD Deactivated setgroup state county field n YieldEnv obsid 
RepCV devfromrep devfromcv wpen wflag; run; 
data out.finalyld_QC_All_EME; set finalyld; run;

/* ????? */
/*
data 'C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\SASFILES\SASOUTPUT\finalyld_QC_All_EME'; set finalyld; run;
*/

proc export data=finalyld outfile="&OUT_DIR.\finalyld_QC_All_EME.CSV" 
dbms=csv replace; run;


**** QC by REP ***;
** Number of extreme plots by site and rep **;
data outalltab; set outallres;
wcat='NormalPlot'; if wpen>40 then wcat='BiasPlot'; 
if modpen>80 then wcat='BiasPlot'; if agpen>80 then wcat='BiasPlot'; run;
proc freq data=outalltab; table season*setgroup*field*block*wcat/out=tablebias outpct nocol nopercent; run;
data tablebiasplots; set tablebias; where wcat='BiasPlot'; PercBiasPlots=pct_row; drop PERCENT PCT_TABL PCT_ROW PCT_COL; run;
proc print data=tablebiasplots; run;
proc export data=tablebiasplots outfile="&OUT_DIR.\NoBiasPlots_QC_All_EME.CSV" 
dbms=csv replace; run;

** average value of CV by REP **;
data BlockW; set outallres; *where repflag='Yellow' OR repflag='Red'; 
keep season Field YLD MST hybrid setgroup density block obsid Pred Resid wpen wflag repcvscore repflag Deactivated; run;
proc sort data=BlockW; by season setgroup field block repflag; run;
proc means data=BlockW noprint; by season setgroup field block repflag; var repcvscore wpen;
output out=cvbyreptable(drop=_FREQ_ _TYPE_) mean=repcvscore repenalization; run;
data cvbyreptable; set cvbyreptable; 
/* ISSUES WITH MIX OF NUMERIC AND ALPHA-NUMERIC BLOCK NAMES!!!!!!!!!!!!!! */
/*
if block=. then delete; 
*/
IF BLOCK='' THEN DELETE;
if field='' then delete; if setgroup='' then delete; run;
proc print data=cvbyreptable; run;
proc export data=cvbyreptable outfile="&OUT_DIR.\CVByRep_QC_All_EME.CSV" 
dbms=csv replace; run;


*** END QC process ***;

