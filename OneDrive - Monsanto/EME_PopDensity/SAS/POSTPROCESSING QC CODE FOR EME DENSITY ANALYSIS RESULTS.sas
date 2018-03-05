/* 

POSTPROCESSING QC TO ELIMINATE OUTPUTS THAT DON'T SATISFY THESE RULES:
R-SQUARED >= 0.7
POSITIVE RESPONSE TO YIELD ENVIRONMENT (POSITIVE MODEL COEFFICIENT FOR YIELD ENVIRONMENT)
DENSITY CURVE CONCAVE DOWN (I.E., NEGATIVE MODEL COEFFICIENT FOR DENSITY SQUARED)
OPTIMAL DENSITY WITHIN (A SLIGHTLY EXPANDED) RANGE OF DENSITIES USED IN DESIGN

HAVE NOT IMPLEMENTED AN OPTION FOR CASES WHERE YIELD ENVIRONMENT COEFFICIENT IS NEGATIVE

THIS ALSO NOW INCLUDES THE 'PRE-PROCESSING' DATA QC THAT WAS ORIGINALLY IN THE 
PREVIOUS ANALYSIS PROGRAM.  THAT QC INCLUDES:
MIN PLOTS PER HYBRID = 25
MIN FIELDS PER HYBRID = 5
MIN YIELD ENVIRONMENT RANGE = 4 T/HA

NOTE THAT IN JD CODE MIN__YIELD_LEVEL AND MAX_YIELD_LEVEL ARE FOR YIELD ENVIORNMENT 
NOT YIELD, SO CAN BE USED FOR ABOVE QC RULE ON YE!!!
*/

DM LOG 'CLEAR';

%LET IN_DIR=C:\Users\sbstar\sbstar\density\FINAL_ANALYSIS\FINAL_ANALYSIS_RESULTS\QC_PRE_TO_POST_PROCESSING\BEFORE_POST_PROCESSING;

LIBNAME IN "&IN_DIR";

%LET OUT_DIR=C:\Users\sbstar\sbstar\density\FINAL_ANALYSIS\FINAL_ANALYSIS_RESULTS\QC_PRE_TO_POST_PROCESSING\AFTER_POST_PROCESSING;

LIBNAME OUT "&OUT_DIR";

/* 
THESE WERE PRODUCED FROM SurfaceResultsYE IN ORIGINAL CODE 
WITH SUFFIXES TO IDENTIFY THAT ADDITIONAL DATA QC 
AND DFFITS OUTLIER DELETION WERE UTILIZED
*/

data RESULTS_ALL;
 SET IN.Results_EME_Set_AYr_Hyb_YE_DF;
RUN;

PROC SORT DATA=RESULTS_ALL;
 BY SETGROUP HYBRID;
RUN;

/*
PROC CONTENTS DATA=RESULTS SHORT;
RUN;
*/

/*
GAIN Intercept MINYLD_YE ModWarning OPTBound OPTPOP_SC OPTYLD_YE PDgain 
R_squared YE YieldEnv density density_YieldEnv density_density grid hybrid 
max_pop max_yield_level min_pop min_yield_level plot_count setgroup site_count 
testden testden2 testye
*/

/*
HOW OPTBound IS COMPUTED ...
if OPTPOP_SC<(min_pop*0.9) then OPTBound='Y'; 
if OPTPOP_SC>(max_pop*1.1) then OPTBound='Y'; 
*/

DATA RESULTS_QC;
 SET RESULTS_ALL;
 IF PLOT_COUNT LT 25 THEN PLOT_COUNT_TOO_SMALL='Y';
 ELSE PLOT_COUNT_TOO_SMALL='N';
 IF SITE_COUNT LT 5 THEN SITE_COUNT_TOO_SMALL='Y';
 ELSE SITE_COUNT_TOO_SMALL='N';
 IF MAX_YIELD_LEVEL-MIN_YIELD_LEVEL LT 4 THEN YE_RANGE_TOO_SMALL='Y';
 ELSE YE_RANGE_TOO_SMALL='N';
 IF density_density GT 0 THEN POS_density_density='Y';
 ELSE POS_density_density='N';
 IF YieldEnv LT 0 THEN NEG_YieldEnv='Y';
 ELSE NEG_YieldEnv='N';
 IF R_squared LT 0.7 THEN R_squared_LOW='Y';
 ELSE R_squared_LOW='N';
 IF OPTBound='Y' THEN OPT_DEN_OOB='Y';
 ELSE OPT_DEN_OOB='N';
 IF PLOT_COUNT_TOO_SMALL='N' AND SITE_COUNT_TOO_SMALL='N' AND YE_RANGE_TOO_SMALL='N' AND
 POS_density_density='N' AND NEG_YieldEnv='N' AND R_squared_LOW='N' AND OPT_DEN_OOB='N' 
 THEN USE_RESULT='Y';
 ELSE USE_RESULT='N';
RUN;

/* REWRITE FILES WITH RESULTS FROM POSTPROCESSING QC */

DATA OUT.Results_EME_Set_AYr_Hyb_YE_FIN;
 SET RESULTS_QC;
RUN;

proc export data=RESULTS_QC 
outfile="&OUT_DIR.\Results_EME_Set_AcrossYear_Hybrid_wYE_FINAL.csv" 
dbms=csv replace; 
run;

/*
THESE WERE PRODUCED FROM EconOpttablepass IN ORIGINAL CODE 
WITH SUFFIXES TO IDENTIFY THAT ADDITIONAL DATA QC 
AND DFFITS OUTLIER DELETION WERE UTILIZED
*/

/* 
NOTE THAT I DON'T UNDERSTAND WHY THERE ARE MULTIPLE RECORDS PER HYBRID WITH DIFFERENT
OPTIMAL POPULATIONS ... THESE DON'T APPEAR TO BE TIED TO DIFFERENT YIELD ENVIRONMENTS??? 
*/

PROC IMPORT OUT=RESULTS_OPTPOPS_ALL DATAFILE="&IN_DIR.\EME_Results_Set_Hybrid_OPTPops_Sce3_Set_AcrossYear_DFFITS.csv"
 DBMS=CSV REPLACE; 
 GETNAMES=YES; 
 DATAROW=2;
 GUESSINGROWS=5000;
RUN; 

PROC SORT DATA=RESULTS_OPTPOPS_ALL;
 BY SETGROUP HYBRID;
RUN;

/* 
CROSSCHECKING RESULTS WITH RESULTS_OPTPOPS
THERE ARE JUST A FEW SETGROUP HYBRIDS IN ONE AND NOT THE OTHER
BUT DON'T KNOW WHY THIS WOULD BE THE CASE
*/
DATA RESULTS_BOTH RESULTS_NOMATCH;
 MERGE RESULTS_ALL (IN=IN1) RESULTS_OPTPOPS_ALL (IN=IN2);
 BY SETGROUP HYBRID;
 IF IN1 AND IN2 THEN OUTPUT RESULTS_BOTH;
 ELSE OUTPUT RESULTS_NOMATCH;
RUN;

/* NEED TO ADD QC FLAGS TO THIS FILE ... */
DATA RESULTS_QC_FLAGS;
 SET RESULTS_QC;
 KEEP SETGROUP HYBRID PLOT_COUNT_TOO_SMALL SITE_COUNT_TOO_SMALL YE_RANGE_TOO_SMALL
 POS_density_density NEG_YieldEnv R_squared_LOW OPT_DEN_OOB USE_RESULT;
;
RUN;

DATA RESULTS_OPTPOPS_QC_FLAG;
 MERGE RESULTS_OPTPOPS_ALL (IN=IN1) RESULTS_QC_FLAGS (IN=IN2);
 BY SETGROUP HYBRID;
 IF IN1 AND IN2;
RUN;

PROC EXPORT data=RESULTS_OPTPOPS_QC_FLAG
outfile="&OUT_DIR.\EME_Results_Set_Hybrid_OPTPops_Sce3_Set_AcrossYear_FINAL.csv" 
dbms=csv replace; run;
