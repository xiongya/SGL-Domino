



/* SS MODS TO JD CODE TO RUN ON NEW 'ALL IN ONE' DATASET */



/* MISSING VARIABLES: STATE COUNTY DEACTIVATED */





**** EME PopDen project ****
**** 1. Data importing and computing yield environment for QC PROCESS ****


***libs;
/*
libname out 'C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\SASFILES\SASOUTPUT';
*/


DM LOG 'CLEAR';

/* NEWEST DATASET PROVIDED BY CLAIRE ON ... */

%LET IN_DIR=C:\Users\sbstar\sbstar\density\FINAL_ANALYSIS\DATA;

LIBNAME IN "&IN_DIR";

%LET OUT_DIR=C:\Users\sbstar\sbstar\density\FINAL_ANALYSIS\DATA\PROCESSED;

LIBNAME OUT "&OUT_DIR";




*********************;
** Data importing **;
*proc import datafile="C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\AggregatedData\early_agg.csv" 
out=dearly dbms=csv replace; *getnames=yes; run;
*proc import datafile="C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\AggregatedData\late_agg_across_year.csv" 
out=dlate dbms=csv replace; *getnames=yes; run;
*proc import datafile="C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\AggregatedData\mid_agg.csv" 
out=dmid dbms=csv replace; *getnames=yes; run;
*proc import datafile="C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\AggregatedData\silage_agg_across_year.csv" 
out=dsilage dbms=csv replace; *getnames=yes; run;



/*
proc import datafile="C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\AggregatedData\data_agg_by_plot_all_years.csv" 
out=dsets dbms=csv replace; *getnames=yes; run;
*/

proc import datafile="&IN_DIR.\data_agg_by_plot_all_years_RENAMED.csv" 
out=dsets dbms=csv replace; 
 GETNAMES=YES; 
 DATAROW=2;
 GUESSINGROWS=10000;
RUN;








proc print data=dsets(obs=10); run; 

** All names:
** merging all datasets and defining a common format for some key variables **;
data pdall; set dsets; *set dtearly dtmid dtlate dtsilage;
ye=catt('s:',year); reg=region; cou=country; loca=catt('f:',loc); 

/* NEW BLOCK DEFINITION */
/*
rep=block; 
*/
REP=NEW_BLOCK;

hybn=hybrid; hyb=Pre_commercial_name; hybc=Commercial_name; fam=Family_relatedness; 
pd=density; mois=13; 

/* NEW FIELD DEFINITION */
FIELD=NEW_LOC;

drop YEAR Region Country LOC Block HYBRID density Pre_commercial_name Commercial_name Family_relatedness;
run;
proc print data=pdall(obs=10); run; 


/*
proc freq data=pdall; tables setgroup season ; run;
*/

** Needed names: 
Year Set_Name Field_Name Rep_Number Plot_Deactivated Deactivation_Reason Base_Manufacturing_Name Manufacturing_Name Seed_Product_Name 
Group_2 State Country FIPS AZR Yield Percent_Moisture ;

** Data cleaning **;
** Fixing names and defining entries **;
data YLD; set pdall; 
season=ye; setgroup=reg; field=loca; hybrid=hyb; family=fam; commercial=hybc; country=cou; 
density=pd; block=rep; MST=mois; YLD=mean_yield;
if reg='Early central East' then setgroup='Early';
if reg='Late ME6' then setgroup='Late';
if reg='Late ME7' then setgroup='Late';
if reg='Mid East' then setgroup='Mid';
keep season setgroup country field density hybrid family commercial block MST YLD;
if yld ne .; if hybrid='' then delete; if density=. then delete; 
run;
proc freq data=yld; tables setgroup season ; run;


proc print data=yld(obs=10); run;
proc print data=yld(obs=10); where setgroup='Silage'; run;
proc print data=yld(obs=10); where hybrid='DKC2972'; run;
proc print data=yld(obs=10); where season='s:2017'; run;
proc print data=yld(obs=10); where hybrid='Mallory'; run;


******************************************************************;
*** First QC using basic model and extracting DF and residuals ***;
 
*** Model1: fitting basic model and extracting residuals;
proc sort data=yld; by season setgroup hybrid; run;
ods exclude all;
PROC MIXED DATA=yld;
by season setgroup hybrid;
class density block field;
MODEL YLD=density /solution outp=out residual influence;
random field block;
ods output SolutionF=SolutionF influence=influence fitstatistics=fitstatistics; RUN;
ods exclude none;
** Save data in permanent SAS data set **;
data out.Model1_by_field_solution; set solutionf; run;
data out.Model1_by_field_residual; set out; run;
data out.Model1_by_field_influence; set influence; run;
data out.Model1_by_field_fitstats; set fitstatistics; run;
proc export data=solutionf outfile="&OUT_DIR..\Model1_by_field_solution.CSV" dbms=csv replace; run;
proc export data=out outfile="&OUT_DIR..\Model1_by_field_residual.CSV" dbms=csv replace; run;
proc export data=influence outfile="&OUT_DIR..\Model1_by_field_influence.CSV" dbms=csv replace; run;
proc export data=fitstatistics outfile="&OUT_DIR..\Model1_by_field_fitstats.CSV" dbms=csv replace; run;

proc print data=fitstatistics(obs=10); run;

** cutting using threshold **;
proc univariate data=out plot; var df; run;
data newyld1; set out; 
if df<2 then delete; 
*if resid<-50 then delete; 
*if resid>50 then delete;
*if studentresid<-3.5 then delete; 
*if studentresid>3.5 then delete; 
keep season hybrid family commercial density block mst yld setgroup field; run;
data out.Model1_new_yld1; set newyld1; run;


** Either importing back the new file or clean the file based on rules ***
*** Model2 **;
proc sort data=newyld1; by season setgroup hybrid; run;
ods exclude all;
PROC MIXED DATA=newyld1;
by season setgroup hybrid;
class density block field;
MODEL YLD=density /solution outp=out2 residual influence;
random field block;
ods output SolutionF=SolutionF2 influence=influence2 fitstatistics=fitstatistics2; RUN;
ods exclude none;
** Save data in permanent SAS data set **;
data out.Model2_by_field_solution; set solutionf2; run;
data out.Model2_by_field_residual; set out2; run;
data out.Model2_by_field_influence; set influence2; run;
data out.Model2_by_field_fitstats; set fitstatistics2; run;
proc export data=solutionf2 outfile="&OUT_DIR..\Model2_by_field_solution.CSV" dbms=csv replace; run;
proc export data=out2 outfile="&OUT_DIR..\Model2_by_field_residual.CSV" dbms=csv replace; run;
proc export data=influence2 outfile="&OUT_DIR..\Model2_by_field_influence.CSV" dbms=csv replace; run;
proc export data=fitstatistics2 outfile="&OUT_DIR..\Model2_by_field_fitstats.CSV" dbms=csv replace; run;


** cutting using threshold **;
data newyld2; set out2; 
if df<3 then delete; 
keep season hybrid family commercial density block mst yld /* deactivated */ setgroup /* state county */ field; run;
data out.Model2_new_yld2; set newyld2; run;
proc export data=newyld2 outfile="&OUT_DIR..\Model2_new_yld2.CSV"
dbms=csv replace; run;

** importing again always;
data yld; set out.Model2_new_yld2;  run;
proc print data=yld(obs=10); run;


***********************************;
*** Computing Yield environment ***;

** Sorting datasets and computing means **;
** by hybrid and set and year **;
proc sort data=yld; by season setgroup hybrid; run;
proc means data=yld noprint; by season setgroup hybrid; var YLD;
output out=names(drop=_FREQ_ _TYPE_ YLD) mean=YLD; run;
data out.names; set names; Count=_N_; run;
proc print data=names; run;



/* STARK NOTE: OLD CODE WENT TO 256 */


** Read in all combination of Set, Prod, and Count **;
PROC SQL noprint;
 select season, setgroup, hybrid, Count
 into /*Check and change count number from Names file always*/
 	  :season1 - :season275,
      :setgroup1 - :setgroup275,
      :hybrid1 - :hybrid275,
	  :Count1 - :Count275
 from out.names;
quit;

%macro listan;
 %put Total Number of Models: &sqlobs..;
 %do i=1 %to &sqlobs.;
 %put &&season&i &&setgroup&i &&hybrid&i &&Count&i;
 %end;
%mend;
%listan; 

** Macro to compute yield environment values **;
%macro CreateDataset();
%do k=1 %to &sqlobs.;  /*For each season set product combination*/;
** calculate means of the products other than the one of interest for yield environments **;
DATA MeansData; set yld;
	where season in ("&&season&k") and setgroup in ("&&setgroup&k") and hybrid notin ("&&hybrid&k");
	keep season /* state county */ setgroup hybrid family field density block YLD MST /* Deactivated */; run; 
proc sort data=MeansData;
	by season setgroup field ; run;
proc means data=MeansData noprint;
	by season setgroup field ;
	where season in ("&&season&k") and setgroup in ("&&setgroup&k");
	var YLD;
	output out=means(drop=_FREQ_ _TYPE_) n=n mean=YieldEnv; run;
** Data for the analysis **;
DATA ProdYLD; set yld;
	where season in ("&&season&k") and setgroup in ("&&setgroup&k") and hybrid in ("&&hybrid&k");
	keep season /* state county */ setgroup hybrid family field density block YLD MST /* Deactivated */; run;
proc sort data=ProdYLD;
	by season setgroup field ; run;
data ProdYLD&&Count&k;
merge ProdYLD means;
	by season setgroup field ;
	if YLD=. then delete; run; 
%end; *** end do loop ***;
ods RTF close;
%mend CreateDataset;
%CreateDataset;

** Merging all datasets on one **;
data ProdYLD_YldEnv; 

/* STARK NOTE:  OLD CODE WAS 256 */

set ProdYLD1-ProdYLD275; /*Check and change count number from Names file always*/
run;



** Save data in permanent SAS data set **;
data out.YLD_YE_ALL_EME; set ProdYLD_YldEnv; run;
/* ????? */
/*
data 'C:\AgStatistics\17-11-20-EME Density 17-Barbara Meisel\SASFILES\SASOUTPUT\YLD_YE_ALL_EME'; set ProdYLD_YldEnv; run;
*/
proc export data=ProdYLD_YldEnv
outfile="&OUT_DIR..\YLD_YE_ALL_EME.CSV"
dbms=csv replace; run;

proc print data=ProdYLD_YldEnv; where field='f:6GRU2'; run;
