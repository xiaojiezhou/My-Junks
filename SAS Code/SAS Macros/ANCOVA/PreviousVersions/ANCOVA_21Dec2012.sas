*******************************************************************************************************;
*     Author:  Xiaojie Zhou
*    Purpose:  Performs ANCOVA, 
*              Ouput residual,
*              Perfomes ANCOVA excluding extrement value (abs(StudentResid)<1.96)
*              Check normality, symmetricity of residues from the model with all data
*              Check normality, symmetricity of residues from the model excluding extreme value
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
*****************Trt Comparisons macros****************;
run;

/**
%let indata=BL;
%let RESP=log10_abs_BL;
%let byvar=MeasureGroup Measure IDVar;
%let TrtVar=TrtLabel6;
%let CovVar=age;
%let ClassVar=HairColor PctGray Coarsness Curvature;
%let Tests3Out=Tests3Out;
%let TableOut=BLEndptOut;
%let SolutionFOut=SolutionFOut;
%let ResidOut=ResidOut;
%let UnivarOut=UnivarOut;


%let optinal_repeat_Statement= repeat /group=Group;
%let optinal_random_Statement= random archiveID;

*****/
%put "ANCOVA(Indata=, Resp=, byVar=, TrtVar=, CovVar=, ClassVar= , 
		optinal_repeat_Statement= ,	optinal_random_Statement= ,
		Tests3Out=, TableOut=, SolutionFOut=, ResidOut=, UnivarOut=)";

%macro ANCOVA(Indata=, Resp=, byVar=, TrtVar=, CovVar=, ClassVar= , 
		optinal_repeat_Statement= ,
		optinal_random_Statement= ,
		Tests3Out=, TableOut=, SolutionFOut=, ResidOut=, UnivarOut=);
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
****** Calculate Raw Baseline Statistics ********;
proc means data=&indata nway noprint  N Min Max Mean maxdec=1;
var &Resp;
class &byvar &TrtVar ;
output out=&resp._Mean(drop=_Type_ _Freq_) N=N mean=Mean Stddev=Stddev Stderr=Stderr Median=Median Min=Min Max=Max P25=P25 P75=P75;
run;

ods listing close;
****** Proc Mixed All Data ********;
ods output  diffs=diffs lsmeans=lsmeans tests3=tests3 solutionF=SolutionF;
proc mixed data=&indata plots=none;
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


proc transpose data=Diffs out=est(drop=_name_  _label_) prefix=EST_;
by &byvar ;
var estimate;
run;
proc transpose data=Diffs out=se(drop=_name_  _label_) prefix=SE_;
by &byvar ;
var stderr;
run;
proc transpose data=Diffs out=p(drop=_name_  _label_) prefix=PROB_;
by &byvar ;
var probt;
run;


data &resp._all; 
merge lsmeans(in=a rename=(Estimate=LSMEAN Stderr=SE Probt=Probt) drop=effect DF tValue) 
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
	proc npar1way data=&indata wilcoxon correct=no ;
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

****** Proc Mixed Extreme Value Excluded ********;
ods output  diffs=diffsr lsmeans=lsmeansr tests3=tests3r(rename=(ProbF=Prob_excl_extr)) SolutionF=R_SolutionF;
proc mixed data=resid_temp1(where=(abs(StudentResid)<1.96))  plots=none;;
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

proc transpose data=Diffsr out=estr(drop=_name_  _label_) prefix=ESTr_;
by &byvar ;
var estimate;
run;
proc transpose data=Diffsr out=ser(drop=_name_  _label_) prefix=SEr_;
by &byvar ;
var stderr;
run;
proc transpose data=Diffsr out=pr(drop=_name_  _label_) prefix=PROBr_;
by &byvar ;
var probt;
run;


data &resp._r; 
merge lsmeansr(in=a rename=(Estimate=LSMEANr Stderr=SEr Probt=Probtr) drop=effect DF tValue) 
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


data &TableOut;
 merge &resp._Mean &resp._all &resp._r;
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
		probr_&k=probr_&k;
		Wilcox_&k=Wilcox_&k;
	end;
	else do;
		est_&k=.;
		se_&k=.;
		prob_&k=.;
		estr_&k=.;
		ser_&k=.;
		probr_&k=.;
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
 merge SolutionF(rename=(Estimate=All_Estimate Probt=All_Probt)) R_SolutionF(rename=(Estimate=R_Estimate Probt=R_Probt));
 if effect="Intercept" then delete;
run;

proc sort data=&SolutionFOut ;  
by effect &byvar ;
run;

%let cateffcts=&ClassVar %upcase(&TrtVar);
%let ncateffcts=%eval(%sysfunc(countc(&cateffcts,' '))+1);
data &SolutionFOut;
length EffectLev $200;
set &SolutionFOut;
%do l=1 %to &ncateffcts;
%let cateffct&l=%scan(&cateffcts,&l,%str( ));
if upcase(effect)="&&cateffct&l" then EffectLev=&&cateffct&l;
%end;
label 
	All_Estimate='Estimate All Data' R_Estimate='Estimate Excluding Extremes'
	All_Probt='Prob>|t| All Data' R_Probt='Prob>|t| Excluding Extremes';
keep &byvar Effect EffectLev All_Estimate All_Probt R_Estimate R_Probt;
run;

%do f=1 %to &nbyvars;
%if &f<&nbyvars %then %let byvar&f=%scan(&byvar,&f,%str( ))%str(,);
%if &f=&nbyvars %then %let byvar&f=%scan(&byvar,&f,%str( ));
%end;
proc sql;
create table &SolutionFOut as
select %do f=1 %to &nbyvars; &&byvar&f %end; ,effect,EffectLev,All_Estimate,All_Probt,R_Estimate,R_Probt
from &SolutionFOut
order by effect, %do f=1 %to &nbyvars; &&byvar&f %end;,EffectLev;
quit;
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
Data TestsForNormality(rename=(pValue=pValue_Shapiro_Wilk) drop=Test TestLab Stat pType pSign VarName);
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
       Skewness='Skewness' Kurtosis='Kurtosis' pValue_Shapiro_Wilk='P-value Shapiro Wilk';
 run;

 ods listing;
%mend;

