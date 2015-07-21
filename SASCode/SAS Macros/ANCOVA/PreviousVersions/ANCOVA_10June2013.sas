*******************************************************************************************************;
*     Author:  Xiaojie Zhou
*    Purpose:  Performs ANCOVA, 
*              Ouput residual,
*              Perfomes ANCOVA excluding extrement value (abs(StudentResid)<1.96)
*              Check normality, symmetricity of residues from the model with all data
*              Check normality, symmetricity of residues from the model excluding extreme value
*			   Performs nonparametric Wilcoxon Rank Sum test for pairwise differences between treatment groups
*			   Performs nonparametric Wilcoxon Saigned Rank test for each treatment group ( avg response not sig different from 0)
*              Input macro variables: indata= Input database, RESP=Response variable, 
*                                     Byvar= By variables that proc mixed will be performed by, 
*                                     TrtVar=Treatment or group variable.  It is of primary interest to compare the different levels of TrtVar
*                                     CovVar=Covariate variable, ClassVar=Class variable in the proc mixed statement
*              Dataset Output from macro:  Tests3Out= Dataset contains Type 3 test output results
*                                          TableOut = Dataset contrains LSMEANS and DIFFs;
*                                          SolutionFOut = Dataset contraints parameter estimate 
*                                          ResidOut = Dataset contrains residue from proc mixed model with all data
*                                          R_ResidOut= Dataset contrains residue from proc mixed model without extreme values
*                                          UnivarOut = Dataset contrains sysmetricity, skewness and normality test of residue    
*										   optinal_random_Statement = optional random effects	
*										   optinal_repeat_Statement = optional repeated measures effect 
* Updates 03/13/2013(Yasser): added by statement in merging the fixed effects solutions from analysis of full data and outliers-excluded data;
*****************Trt Comparisons macros****************;
run;

/**

*----- CFB ----*;
%let Indata=wk8;    
%let Resp=CFB;    
%let byVar=cGroup Measure;    
%let TrtVar=Trt_Cntrl;    
%let CovVar= BL Side Trt_Cntrl*BL ;    
%let ClassVar= ArchiveID Trt_Cntrl Side;    
%let optinal_random_Statement=random ArchiveID;    
%let optinal_repeat_Statement= ;    
%let Tests3Out=wk8_Tests3Out;    
%let TableOut=wk8_GrpCmprOut;    
%let SolutionFOut=wk8_SolutionFOut;    
%let ResidOut=wk8_ResidOut;    
%let UnivarOut=wk8_UnivarOut;

*****/
%put "ANCOVA(Indata=, Resp=, byVar=, TrtVar=, CovVar=, ClassVar= , 
		optinal_repeat_Statement= ,	optinal_random_Statement= , optinal_repeat_Statement= , 
		Tests3Out=, TableOut=, SolutionFOut=, ResidOut=, UnivarOut=)";

%macro ANCOVA(Indata=, Resp=, byVar=, TrtVar=, CovVar=, ClassVar= , 
		optinal_repeat_Statement= ,
		optinal_random_Statement= ,
		Tests3Out=, TableOut=, SolutionFOut=, ResidOut=, UnivarOut=);

options mlogic symbolgen;

** Get Response Variables;
** Get Continuous Covariates and store them in a macro variable;
%let CovVar=%qcmpres(%upcase(&CovVar));
%let ncovs=%eval(%sysfunc(countc(&CovVar,' '))+1);
%let ClassVar=%qcmpres(%upcase(&ClassVar));
%let nclass=%eval(%sysfunc(countc(&ClassVar,' '))+1);

%let contcov=;
%do cov=1 %to &ncovs;
	%let covar&cov=%scan(&CovVar,&cov,%str( ));
	%if %index(&ClassVar,&&covar&cov)=0 %then %let contcov=&contcov &&covar&cov;
%end;

%put &CovVar**&ncovs*&ClassVar*&nclass;
%put *** Continuous Covariates= &contcov ***;


** Get the rightmost variable of by variables and store it;
*  for later use in first and last statements of a data step;
%let byVar=%qcmpres(%upcase(&byVar));
%let nbyVars=%eval(%sysfunc(countc(&byVar,' '))+1);
%let byVarLast=%scan(&byVar,&nbyVars,%str( ));
%put *** The Rightmost By-Variable= &byVarLast ***;

*** Create a label for _trt column for the diff table;
%let _trtvar=_&trtvar;

***************************************************************;
data indata;
 set &indata; run;  

proc datasets lib=work memtype=data;
   modify indata; 
     attrib _all_ label=' '; 
run;

proc sort data=indata;
 by &byvar &TrtVar;
 run;
****** Calculate Raw Baseline Statistics ********;
proc means data=indata nway noprint  N Min Max Mean maxdec=1;
var &Resp;
class &byvar &TrtVar ;
output out=&resp._Mean(drop=_Type_ _Freq_) N=N mean=Mean Stddev=Stddev Stderr=Stderr Median=Median Min=Min Max=Max P25=P25 P75=P75;
run;

ods listing close;
****** Proc Mixed All Data ********;
ods output  diffs=diffs lsmeans=lsmeans tests3=tests3 solutionF=SolutionF;
proc mixed data=indata plots=none;
	Class &TrtVar &ClassVar;
	model &Resp=&TrtVar &CovVar /s ddfm=kr Outp=resid_temp1 residual;;
	&optinal_repeat_Statement;
	&optinal_random_Statement;
	lsmeans &TrtVar /pdiff;
	by &byvar ;
run;

proc sort data=diffs;
  by &byvar &trtVar &_trtVar;
  run;

data diffs;
set diffs;
trt_trt=cat(trim(left(&trtvar.)),' vs. ',trim(left(&_trtvar.)));
run;

*** Get trt comparisons (assumuming same trts across by variables);
proc sort data=diffs out=trtcomps(keep=&trtVar &_trtVar trt_trt) nodupkey;
by trt_trt;
run;

data _null_;
set trtcomps end=eof;
call symput('comp'||left(trim(_n_)),left(trim(trt_trt)));
if eof then call symput('ncomps',left(trim(_n_)));
run;


proc transpose data=Diffs out=est(drop=_name_) prefix=EST_;
by &byvar ;
var estimate;
run;
proc transpose data=Diffs out=se(drop=_name_) prefix=SE_;
by &byvar ;
var stderr;
run;
proc transpose data=Diffs out=p(drop=_name_) prefix=PROB_;
by &byvar ;
var probt;
run;


data &resp._all; 
merge lsmeans(in=a rename=(Estimate=LSMEAN Stderr=SE Probt=Prob_t) drop=effect DF tValue) 
	  est se p;
by &byvar;
run;

proc sort data=&resp._all;
by &byvar &TrtVar ;
run;


****** Wilconxon Rank Sum test ********;
%do w=1 %to &ncomps;
	data _null_;
	set trtcomps;
	if _n_= &w then do;
	call symput('trt1',&trtVar);
	call symput('trt2',&_trtVar);
	end;
	run;

	ods output WilcoxonTest=wilcox&w;
	proc npar1way data=indata wilcoxon correct=no ;
	by &byvar;
	where &trtVar in ("&trt1","&trt2");
	   class &trtVar;
	   var &resp;
	run;
data wilcox&w;
set wilcox&w;
if name1='P2_WIL';
rename nValue1=Wilcox_&w;
keep &byvar nvalue1;
run;
%end;
data wilcox;
merge %do w=1 %to &ncomps; Wilcox&w %end;;
by &byvar;
run;

****** Signed Rank Test ********;
ods output TestsForLocation=signrank;
proc univariate data=indata;
by &byvar &trtvar;
   var &resp;
run;
data signrank;
set signrank;
if test='Signed Rank';
run;


****** Proc Mixed Extreme Value Excluded ********;
ods output  diffs=diffsr lsmeans=lsmeansr tests3=tests3r(rename=(ProbF=Prob_excl_extr)) SolutionF=R_SolutionF;
proc mixed data=resid_temp1(where=(abs(StudentResid)<1.96))  plots=none;
	Class &TrtVar &ClassVar;
	model &Resp=&TrtVar &CovVar /s ddfm=kr Outp=resid_temp2 residual;
	&optinal_repeat_Statement;
	&optinal_random_Statement;
	lsmeans &TrtVar /pdiff;
	by &byvar ;
run;

proc sort data=diffsr;
  by &byvar &trtVar &_trtVar;
  run;

data diffsr;
set diffsr;
trt_trt=cat(trim(left(&trtvar.)),' vs. ',trim(left(&_trtvar.)));
run;

proc transpose data=Diffsr out=estr(drop=_name_) prefix=ESTr_;
by &byvar ;
var estimate;
run;
proc transpose data=Diffsr out=ser(drop=_name_) prefix=SEr_;
by &byvar ;
var stderr;
run;
proc transpose data=Diffsr out=pr(drop=_name_) prefix=PROB_r_;
by &byvar ;
var probt;
run;


data &resp._r; 
merge lsmeansr(in=a rename=(Estimate=LSMEANr Stderr=SEr Probt=Prob_t_r) drop=effect DF tValue) 
	  estr ser pr;
by &byvar;
run;

proc sort data=&resp._r;
by &byvar &TrtVar ;
run;

********Combined All Data results and Extreme Value Excluded Results ******;
proc sort data=&resp._Mean;  by &byvar &trtvar; run;
proc sort data=&resp._all; by &byvar &trtvar;run;
proc sort data=wilcox; by &byvar;run;
proc sort data=&resp._r; by &byvar &trtvar;run;
proc sort data=signrank; by &byvar &trtvar;run;



data &TableOut;
 merge &resp._Mean &resp._all &resp._r signrank(keep=&byvar &trtvar pValue rename=(pValue=Prob_signrank));
 by &byvar &trtvar;
 RespVar="&Resp";
 run;

 data &TableOut;
 merge &TableOut wilcox;
 by &byvar;
 run;

data &TableOut;
set &TableOut;
by &byvar;
%do k=1 %to &ncomps;
	if first.&byVarLast then do;
		est_&k=est_&k;
		se_&k=se_&k;
		prob_&k=prob_&k;
		estr_&k=estr_&k;
		ser_&k=ser_&k;
		prob_r_&k=prob_r_&k;
		Wilcox_&k=Wilcox_&k;
	end;
	else do;
		est_&k=.;
		se_&k=.;
		prob_&k=.;
		estr_&k=.;
		ser_&k=.;
		prob_r_&k=.;
		Wilcox_&k=.;
	end;
%end;
run;


proc sort data=tests3 ;  
by effect &byvar ;
run;
proc sort data=tests3r ;  
by effect &byvar ; 
run;

data &Tests3Out;
 merge  tests3(drop=NumDf DenDF FValue rename=(ProbF=Prob_all_data)) 
        tests3r(drop=NumDf DenDF FValue );
label
	prob_all_data='Prob>F All Data' Prob_excl_extr='Prob>F Excluding Extremes';
by effect &byvar ;
run;

********Combined Solution F from All Data & Extreme Values Excluded ******;
data &SolutionFOut(drop=df tvalue stderr);
 merge SolutionF(rename=(Estimate=All_Estimate Probt=Prob_t_ALL)) R_SolutionF(rename=(Estimate=R_Estimate Probt=Prob_t_R));
 if effect="Intercept" then delete;
run;
proc sort data=&SolutionFOut ;  
by effect &byvar ;
run;
******************* Check Residuals **********;
Data &ResidOut;
 set resid_temp1 resid_temp2(in=a );
 if ^a then Set="All Data       ";
 else  do;
 	Resid=Resid2;
	StudentResid=StudentResid2;
	PearsonResid=PearsonResid2;
	Set="Extreme Removed"; 
	drop Resid2 StudentResid2 PearsonResid2;
	end;
run;

ods output  Moments= Moments TestsForNormality=TestsForNormality;
proc univariate data=&ResidOut normal;
 var StudentResid;
 by Set &byvar;
 run;

Data Moments(rename=(cValue1=Skewness cValue2=Kurtosis) drop=nValue1 nValue2 VarName Label1 Label2);
 set Moments;
 if Label1="Skewness" ;
run;
Data TestsForNormality(rename=(pValue=prob_Shapiro_Wilk) drop=Test TestLab Stat pType pSign VarName);
 set TestsForNormality(where=(Test="Shapiro-Wilk"));
proc sort data=Moments; by &byvar;
proc sort data=TestsForNormality; by &byvar; run;

proc means data=&ResidOut nway noprint  N Min Max Mean maxdec=1;
var StudentResid;
class  &byvar Set ;
output out=Tmp(drop=_Type_ _Freq_) N=N mean=Mean Median=Median Stddev=Stddev;
run;

data &UnivarOut;
 merge TMP Moments TestsForNormality;
 by  &byvar Set;
 rename n=n_r mean=mean_r median=median_r Stddev=Stddev_r Skewness=Skewness_r Kurtosis=Kurtosis_r;
 label n='N' mean='Mean' median='Median' Stddev='Stddev' 
       Skewness='Skewness' Kurtosis='Kurtosis' prob_Shapiro_Wilk='P-value Shapiro Wilk';
 run;

 ods listing;
 options nomlogic nosymbolgen;
 %mend;

