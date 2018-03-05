/* 
THIS IS ORIGINAL JD CODE FROM 12/20/17
WITH DFFITS LEVERAGE POINT COMPUTATIONS
AND OTHER MINOR MODIFICATIONS.
NOTE THAT ORIGINAL 'PRE-PROCESSING' DATA QC
HAS BEEN MOVED TO 'POST-PROCESSING' QC IN THIS VERSION OF CODE.
ALSO, PLOT COUNTS, FIELD COUNTS AND YIELD ENVIRONMENT RANGE
ARE COMPUTED PRIOR TO DFFITS ELIMINATION OF OUTLIERS.
THIS IS THE SAME AS WAS ORIGINALLY IMPLEMENTED IN VALIDATION STUDIES.
*/


/* 
THIS VERSION HAS THE DFFITS COMPUTATIONS COMMENTED OUT FOR TROUBLESHOOTING!!!!!
*/

/* NEED TO DELETE HYBRID EA3204 DUE TO FLOATING POINT EXCEPTION */



**** Gen V project ****
**** 6. Surface analysis fitting cuadratic function to yield AND COST ****

** Settings **;

/*
goptions device=png;
options mprint orientation=portrait ls=80 ps=55 NOOVP noxwait noxsync symbolgen;
** Set library **;
libname out 'C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\SASFILES\SASOUTPUT';
*/


/******************************************************************************/
/* STARK CODE */

DM LOG 'CLEAR';

/* DIRECTORY WITH JD'S ORIGINAL YIELD DATASET */
/*
%LET IN_DIR=C:\Users\sbstar\sbstar\density\code\adapt_JD_code\from_12_20_17\SAS_outputs;
*/

DM LOG 'CLEAR';

/* PARTIALLY PROCESSED DATASET FROM FIRST PROGRAM ... */

%LET IN_DIR=C:\Users\sbstar\sbstar\density\FINAL_ANALYSIS\DATA\PROCESSED;

LIBNAME IN "&IN_DIR";

%LET OUT_DIR=C:\Users\sbstar\sbstar\density\FINAL_ANALYSIS\FINAL_ANALYSIS_RESULTS\QC_PRE_TO_POST_PROCESSING\BEFORE_POST_PROCESSING;

LIBNAME OUT "&OUT_DIR";

/* END STARK CODE */
/******************************************************************************/



** Importing new QCed Data with Hybrid names **;
** Brian include Hybrid in th eoriginal file ;
DATA YLDp; set IN.finalyld_QC_All_EME; run;
*proc print data=yldp(firstobs=1020 obs=1030); run;

*names: hybrid_b Trait_Code Hybrid_b Brand hybrid Hybrid_b2 fips   density block MST YLD 
Deactivated setgroup state county field n YieldEnv obsid RepCV devfromrep devfromcv wpen wflag Hybrid_david ;
data yld; set yldp ; 
keep season family hybrid density block mst yld setgroup state county field yieldenv RepCV devfromrep devfromcv wpen wflag;
run;

/*
proc freq data=yld; tables season setgroup ; run;
proc freq data=yld; tables hybrid  family; run;
*/

** fix on the fly;
data yld; set yld;
if Hybrid=' '  then delete;
*if setgroup='Late M' then setgroup='Late'; run;

** Checking dataset and creating ordered index **;
*proc print data=YLD (firstobs = 1020 obs = 1030); run; 
proc sort data=YLD; by setgroup Hybrid field block; run;
data yld; set yld; obsid=_n_; run;

** For each season set product combination: not needed here **;
** Calculate means of the products other than the one of interest for yield environments **;
** Calculate range of yield environments and range of population **;




/* STARK NOTE */
/* 
NOTE THAT MIN1 AND MIN2 ARE FOR YIELD ENVIRONMENT, NOT YIELD!!!!
THESE ARE RENAMED BELOW AS min_yield_level=min1; max_yield_level=max1;
THUS, THESE CAN BE USED FOR CHECKING FOR MINIMUM YIELD ENVIRONMENT RANGE
IN THE POST-PROCESSING CODE
*/


proc means data=YLD noprint;
by  setgroup Hybrid; var YieldEnv density;
output out=range(drop=_FREQ_ _TYPE_) min=min1 min2 max=max1 max2; run; 


** Calculate Number of sites used **;
proc sort data=YLD; by  setgroup Hybrid field; run;
proc means data=YLD noprint;
by  setgroup Hybrid field; var YLD;
output out=Sitetemp(drop=_FREQ_ _TYPE_) n=n; run; 
proc means data=Sitetemp noprint;
by  setgroup Hybrid; var n;
output out=Sites(drop=_FREQ_ _TYPE_) n=sites; run; 



/* COMMENTING OUT DFFITS CODE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */


/****************************************************************/
/* 
BEGIN STARK CODE FOR DFFITS TO DELETE LEVERAGE POINTS ONLY 
WHAT WAS 'PRE-PROCESSING' QC IS ELIMINATED 
AND IS NOW APPLIED AS 'POST-PROCESSING' QC
*/
/****************************************************************/

/*

PROC SORT DATA=YLD;
BY SETGROUP HYBRID FIELD BLOCK DENSITY;
RUN;

DATA YLD;
 SET YLD;
* NEED TO ADD FOR PROC REG;
 DENSITY_DENSITY=density*density;
 DENSITY_YIELDENV=density*YieldEnv;
RUN;

ODS EXCLUDE ALL;

PROC REG DATA=YLD;
BY SETGROUP HYBRID;
MODEL YLD=density density_density YieldEnv density_YieldEnv / INFLUENCE PRESS;
OUTPUT OUT=RESID_OTL DFFITS=DFFITS_OTL;
ods output nobs=nobs_OTL;
RUN;

ODS EXCLUDE NONE;

DATA NOBS_OTL;
 SET NOBS_OTL;
 IF LABEL='Number of Observations Used';
 NOBS_OTL=NOBSUSED;
 KEEP SETGROUP HYBRID NOBS_OTL;
RUN;

DATA RESID_NOBS_OTL;
 MERGE RESID_OTL NOBS_OTL;
 BY SETGROUP HYBRID;
RUN;

DATA OTL_FLAG;
 SET RESID_NOBS_OTL;
 NUM_PARMS=5; * INCLUDING INTERCEPT;
* USING MULTIPLIER 1.5 INSTEAD OF 2.0;
 DFFITS_CUT=1.5*SQRT(NUM_PARMS/NOBS_OTL);
 IF ABS(DFFITS_OTL) GT DFFITS_CUT THEN DFFITS_OUTLIER='Y'; 
 ELSE DFFITS_OUTLIER='N';
 KEEP SETGROUP HYBRID FIELD BLOCK DENSITY DFFITS_CUT DFFITS_OUTLIER;
RUN;

PROC SORT DATA=YLD;
 BY SETGROUP HYBRID FIELD BLOCK DENSITY;
RUN;

DATA YLD_OTL_FLAG;
 MERGE YLD OTL_FLAG;
 BY SETGROUP HYBRID FIELD BLOCK DENSITY;
RUN;

PROC FREQ DATA=YLD_OTL_FLAG;
 TABLE DFFITS_OUTLIER;
RUN;

* DROP OUTLIERS;
DATA YLD_NO_OTL;
 SET YLD_OTL_FLAG;
 IF DFFITS_OUTLIER='Y' THEN DELETE;
RUN;

* REPLACE ORIGINAL DATASET YLD WITH OUTLIER CLEANED DATA;
DATA YLD;
 SET YLD_NO_OTL;
RUN;

*/

/****************************************************************/
/* END STARK CODE */
/****************************************************************/


















*** A GENERAL GRID with simulated boundaries ***;
** creating a grid for future surface analysis, this can be used later on Agronomical and Economical estimates;
proc univariate data=yld; var density yieldenv; run;
proc freq data=yld noprint; tables setgroup*Hybrid/out=listset; run;
proc print data=listset; run;
data listset; set listset; grid=_n_; drop count percent; run;
data empty; 


/* 
STARK NOTE:
THIS RAN TO 169 IN ORIGINAL CODE
BUT NEED TO RUN TO 193 OTHERWISE SILAGE GETS DELETED
*/
do grid=1 to 192; *169; ** change the number based on the list;



do density=50 to 140 by 15 ; 
do YieldEnv=4 to 25 by 3;
output; end; end; end; run;
proc print data=empty(obs=10); run;
proc sort data=listset; by grid; run;
proc sort data=empty; by grid; run;
data newlist; merge listset empty; by grid; yld=.; Field='plot'; run;
data yld2; set yld newlist; run;
proc print data=yld2(obs=10); where field='plot'; run;


*** A basic model to compute COEFFICIENTS ***;
** Fit surface model AGAIN without outliers **;
** This model will fit only YLD response, trying to fit Agronomical surface for now;
proc sort data=yld2; by  setgroup Hybrid; run;
ods exclude all;
PROC MIXED DATA=YLD2;


/* HYBRID GENERATES FLOATING POINT EXCEPTION */
WHERE HYBRID NE 'EA3204';



by  setgroup Hybrid;
class field ; *block;
MODEL YLD=density density*density YieldEnv  density*YieldEnv /solution outp=out residual influence;
random field ; *block;
ods output SolutionF=SolutionF influence=influence fitstatistics=fitstatistics;
RUN;
ods exclude none;
proc print data=out(obs=10); where field='plot'; run;


** Transpose model **;
proc transpose data=SolutionF out=indmodel let;
by   setgroup Hybrid;
id Effect; var Estimate; run;
proc transpose data=SolutionF out=tmodel let;
by   setgroup Hybrid;
id Effect; var probt; run;
data testmodel; set tmodel; 
testden=density; testden2=density_density; testye=YieldEnv; 
keep   setgroup Hybrid testden testden2 testye;  run; 

** Calculate adjusted R2 **;
proc sort data=YLD; by   setgroup Hybrid;
proc means data=YLD noprint;
by   setgroup Hybrid; var YLD;
output out=means4r2(keep=   setgroup Hybrid YLD_MEAN) mean=YLD_MEAN;run;
data prersquare; set out; keep   setgroup Hybrid YLD resid; run;
proc sort data=prersquare; by   setgroup Hybrid;
data prersquare2; merge prersquare means4r2;
by   setgroup Hybrid;
sr=(resid)**2; st=(YLD-YLD_MEAN)**2; run;
proc means data=prersquare2 noprint;
by   setgroup Hybrid;
var sr st;
output out=sr_st(keep=   setgroup Hybrid n sr st) n=n n1 sum=sr st; run;
data rsquare; set sr_st;
r2=1-sr/st;	
adjustedR2=1-(1-r2)*((n-1)/(n-5-1));
keep   setgroup Hybrid n adjustedR2; run;

* Genrate surface Response table **;
proc sort data=indmodel; by   setgroup Hybrid;
proc sort data=testmodel; by   setgroup Hybrid;
proc sort data=rsquare; by   setgroup Hybrid;
proc sort data=Sites; by   setgroup Hybrid;
proc sort data=range; by   setgroup Hybrid;
data SurfaceRes; merge indmodel testmodel rsquare Sites range;
by   setgroup Hybrid; run;
data SurfaceResults; set SurfaceRes;
min_yield_level=min1; max_yield_level=max1;
R_squared=adjustedR2; plot_count=n;
site_count=sites; min_pop=min2; max_pop=max2;
ModWarning='GreenPass'; if R_squared<0.7 then ModWarning='LowR2';
if site_count<10 then ModWarning='LowNoLocs'; if site_count<10 and R_squared<0.7 then ModWarning='LowR2&Loc';
drop _NAME_ n adjustedR2 sites min1 min2 max1 max2;
run;
proc print data=surfaceresults(obs=10); run;

** Optimal Agronomical Population: Basic Math derivation **;
** Generating a new output table with optimal population **;
data relistset; set SurfaceResults; grid=_n_; keep   setgroup Hybrid grid; run;
data empty; 



/* 
STARK NOTE:
THIS RAN TO 169 IN ORIGINAL CODE
BUT NEED TO RUN TO 193 OTHERWISE SILAGE GETS DELETED
*/
do grid=1 to 192; *169; ** change the number based on the list;





do YE=4 to 25 by 3;
output; end; end;  run; 
proc sort data=relistset; by grid; run;
proc sort data=empty; by grid; run;
data newlist; merge relistset empty; by grid; run;
proc sort data=newlist; by   setgroup Hybrid; run;
proc sort data=surfaceresults; by   setgroup Hybrid; run;
data SurfaceResultsYE; merge surfaceresults newlist; by   setgroup Hybrid; 
if YE<min_yield_level then delete;
if YE>max_yield_level then delete;
*** CHANGE HERE ****;
*m1 and m2;
OPTPOP_SC=-(density+(density_YieldEnv*YE))/(2*density_density);
*m3;
*OPTPOP_SC=-(density+(density_YieldEnv*YE))/(2*(density_density+(densit_densit_YieldE*YE)));
OPTBound='N';
if OPTPOP_SC<(min_pop*0.9) then OPTBound='Y'; 
if OPTPOP_SC>(max_pop*1.1) then OPTBound='Y'; 
OPTYLD_YE=Intercept+(density*OPTPOP_SC)+(density_density*(OPTPOP_SC*OPTPOP_SC))+(YieldEnv*YE)+(density_YieldEnv*(OPTPOP_SC*YE));
MINYLD_YE=Intercept+(density*min_pop)+(density_density*(min_pop*min_pop))+(YieldEnv*YE)+(density_YieldEnv*(min_pop*YE));
GAIN=OPTYLD_YE-MINYLD_YE;
PDgain=OPTPOP_SC-min_pop;
run;
proc print data=SurfaceResultsYE(obs=20); run;
data srda; set surfaceresultsYE; if optbound='Y' then delete; run;
proc print data=srda(obs=20); run;

/* Save data in permanent SAS data set */
data out.Results_EME_Set_AYr_Hyb_YE_NODF; set SurfaceResultsYE; run;
proc export data=SurfaceResultsYE 
outfile="&OUT_DIR.\Results_EME_Set_AcrossYear_Hybrid_wYE_NO_DFFITS.csv" dbms=csv replace; run;


**** Preparing dataset for Economical Analysis ***;
*** Merginf for raws only within the range of YE **;
*** Using Agronomical estimates not original data ***;
proc sort data=range; by  setgroup Hybrid; run;
proc sort data=out; by  setgroup Hybrid; run;
data outplot; merge out range; by setgroup Hybrid; 
if field='plot' AND yieldenv>min1 AND yieldenv<max1; 
run;
proc print data=outplot(obs=10); run;

** Including COST/PRICE information for ECOnomical **;
data outplot2; set outplot;
*seep=240, 330; *commodity=3.00, 4.00;
sp1=240; sp2=320; co1=3.0*39.36; co2=4.0*39.36; * adjusting european values of bag seed;
seedcost1=(sp1*(density/80)); seedcost2=(sp2*(density/80));
benefit1=(co1*pred); benefit2=(co2*pred); 
NetValue11=benefit1-seedcost1; NetValue12=benefit1-seedcost2; NetValue21=benefit2-seedcost1; NetValue22=benefit2-seedcost2; 
run;
proc print data=outplot2(obs=10); run;


*** Surface response using anova estimates for Economical Recommendation ***;
** Using rsreg to get optimum populations;
proc sort data=outplot2; by setgroup  Hybrid YieldEnv; run;
*ods graphics on;
proc rsreg data=outplot2; by setgroup  Hybrid YieldEnv; model pred = density/ lackfit;
ods output stationarypoint=agpointe; run;
proc rsreg data=outplot2; by setgroup  Hybrid YieldEnv; model netvalue11 = density/ lackfit;
ods output stationarypoint=ec11pointe; run;
proc rsreg data=outplot2; by setgroup  Hybrid YieldEnv; model netvalue12 = density/ lackfit;
ods output stationarypoint=ec12pointe; run;
proc rsreg data=outplot2; by setgroup  Hybrid YieldEnv; model netvalue21 = density/ lackfit;
ods output stationarypoint=ec21pointe; run;
proc rsreg data=outplot2; by setgroup  Hybrid YieldEnv; model netvalue22 = density/ lackfit;
ods output stationarypoint=ec22pointe; run;
*ods graphics off;
* Extracting/fixing tables with optimum ;
data agpoint; set agpointe; where factor='density'; OptPopAg=round(uncoded,0.01)*1000; run;
data ec11point; set ec11pointe; where factor='density'; OptPop11=round(uncoded,0.01)*1000; run;
data ec12point; set ec12pointe; where factor='density'; OptPop12=round(uncoded,0.01)*1000; run;
data ec21point; set ec21pointe; where factor='density'; OptPop21=round(uncoded,0.01)*1000; run;
data ec22point; set ec22pointe; where factor='density'; OptPop22=round(uncoded,0.01)*1000; run;
data ecparmse; merge agpoint ec11point ec12point ec21point ec22point; by setgroup  Hybrid YieldEnv; 
YEclass=YieldEnv;
keep setgroup  Hybrid YEclass OptPopAg OptPop11 OptPop12 OptPop21 OptPop22; run;
proc print data=ecparmse(obs=10); run;



*** EXTRACTING TABLE FOR BRIAN 2. AGR and ECON **;
*****************************************;
proc print data=ecparmse(obs=10); run;
proc print data=surfaceresults(obs=10); run;
proc sort data=surfaceresults; by setgroup  Hybrid ; run;
proc sort data=ecparmse; by setgroup  Hybrid ; run;
data EconOpttable; merge ecparmse surfaceresults; by setgroup  Hybrid ; 
Hybrid=Hybrid; Yield_Env_class=YEclass; 
if optpop12<48000 then optcomm='ns_pop_oobo';
if optpop22<48000 then optcomm='ns_pop_oobo';
if optpop12<0 then optcomm='ns_pop_flat';
if optpop22<0 then optcomm='ns_pop_flat';
if optpopag<48000 then optpopag=.; if optpopag>142000 then optpopag=.;
if optpop11<50000 then optpop11=.; if optpop11>140000 then optpop11=.;
if optpop12<50000 then optpop12=.; if optpop12>140000 then optpop12=.;
if optpop21<50000 then optpop21=.; if optpop21>140000 then optpop21=.;
if optpop22<50000 then optpop22=.; if optpop22>140000 then optpop22=.;
if optpopag=. then delete;
Opt_Agronomic=optpopag;
Opt_Econ_s240_c30=optpop11;
Opt_Econ_s320_c30=optpop12;
Opt_Econ_s240_c40=optpop21;
Opt_Econ_s320_c40=optpop22;
keep Setgroup  Hybrid Opt_Agronomic Opt_Econ_s240_c30 Opt_Econ_s240_c40 Opt_Econ_s320_c30 Opt_Econ_s320_c40 optcomm
min_yield_level max_yield_level plot_count site_count min_pop max_pop ModWarning ; run;
proc print data=EconOpttable(obs=10); run;

data econopttablepass; set econopttable; *if modwarning='GreenPass'; run;
proc print data=EconOpttablepass(obs=30); run;


/* Save data in permanent SAS data set */
proc export data=EconOpttablepass 
outfile="&OUT_DIR.\EME_Results_Set_Hybrid_OPTPops_Sce3_Set_AcrossYear_NO_DFFITS.csv" dbms=csv replace; run;



