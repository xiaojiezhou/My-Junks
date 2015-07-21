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

%let optinal_repeat_Statement= ;
%let optinal_random_Statement= ;
%let optional_where_statement= ;

%let Tests3Out=Tests3Out;
%let TableOut=BLEndptOut;
%let SolutionFOut=SolutionFOut;
%let ResidOut=ResidOut;
%let UnivarOut=UnivarOut;

%let Indata=d1;
%let Resp=BaseMean_YM;
%let byVar=PCTL StudyDay;
%let TrtVar=Trt;
%let CovVar=Age Side;
%let ClassVar= ArchiveID Side Group;
%let optinal_repeat_Statement= repeated /group=Group;
%let optinal_random_Statement= random ArchiveID ;
%let optional_where_statement= where studyDay in (57, 113);
%let Tests3Out=Tests3Out;
%let TableOut=TableOut;
%let SolutionFOut=SolutionFOut;
%let ResidOut=ResidOut;
%let UnivarOut=UnivarOut;


*****/
%macro ANCOVA(Indata=, Resp=, byVar=, TrtVar=, CovVar=, ClassVar= , 
		optinal_repeat_Statement= ,
		optinal_random_Statement= ,
		optional_where_statement= ,
		Tests3Out=, TableOut=, SolutionFOut=, ResidOut=, UnivarOut=);

%let _trtvar=_&trtvar;
****** Calculate Raw Baseline Statistics ********;
proc means data=&indata nway noprint  N Min Max Mean maxdec=1;
	var &Resp;
	class &byvar &TrtVar ;
	output out=BLMean(drop=_Type_ _Freq_) N=N mean=Mean Stddev=Stddev Stderr=Stderr Median=Median Min=Min Max=Max P25=P25 P75=P75;
	&optional_where_statement;
run;

proc sort data=&indata; by &byvar; run;
* ods listing close;
****** Proc Mixed All Data ********;
ods output  diffs=diffs lsmeans=lsmeans tests3=tests3 solutionF=SolutionF;
proc mixed data=&indata plots=none;
	Class &TrtVar &ClassVar;
	model &Resp=&TrtVar &CovVar /s ddfm=kr Outp=T_ResidOut residual;
	&optinal_repeat_Statement;
	&optinal_random_Statement;
	&optional_where_statement;
	lsmeans &TrtVar /pdiff;
	by &byvar ;
run;

proc sort data=diffs;
  by &byvar &trtVar &_trtVar;
  run;

proc transpose data=Diffs out=est prefix=Est_;
 var estimate;
 by &byvar &trtVar ;
 ID &_TrtVar; run;

proc transpose data=Diffs out=se prefix=SE_;
 var stderr;
 by &byvar &trtVar ;
 ID &_TrtVar; run;

proc transpose data=Diffs out=p prefix=Prob_;
 var probt;
 by &byvar &trtVar ;
 ID &_TrtVar; run;

data &resp(drop=_name_ _label_); merge lsmeans(in=a rename=(Estimate=LSMEAN_&Resp Stderr=SE_&Resp Probt=Probt_&resp) drop=effect DF tValue ) est se p;
by &byvar &trtVar;
if a;
run;


****** Proc Mixed Extreme Value Excluded ********;
ods output  diffs=diffsr lsmeans=lsmeansr tests3=tests3r(rename=(ProbF=Prob_excl_extr)) SolutionF=R_SolutionF;
proc mixed data=T_ResidOut(where=(abs(StudentResid)<1.96))  plots=none;;
	Class &TrtVar &ClassVar;
	model &Resp=&TrtVar &CovVar /s ddfm=kr Outp=&ResidOut residual;
	lsmeans &TrtVar /pdiff;
	&optinal_repeat_Statement;
	&optinal_random_Statement;
	&optional_where_statement;
	by &byvar ;
run;

proc sort data=diffsr;
  by &byvar &trtVar &_trtVar;
  run;

proc transpose data=Diffsr out=estr prefix=R_Est_;
 var estimate;
 by &byvar &trtVar ;
 ID &_TrtVar; run;

proc transpose data=Diffsr out=ser prefix=R_SE_;
 var stderr;
 by &byvar &trtVar ;
 ID &_TrtVar; run;

proc transpose data=Diffsr out=pr prefix=R_Prob_;
 var probt;
 by &byvar &trtVar ;
 ID &_TrtVar; run;

data &resp.r(drop=_name_ _label_); merge lsmeansr(in=a rename=(Estimate=R_LSMEAN_&Resp Stderr=R_SE_&Resp Probt=R_Probt_&resp) drop=effect DF tValue ) estr ser pr;
by &byvar &trtVar;
if a;
run;

********Combined All Data results and Extreme Value Excluded Results ******;
proc sort data=&resp; by &byvar &trtvar;
proc sort data=&resp.r; by &byvar &trtvar;
proc sort data=BLMean;  by &byvar &trtvar;

data &TableOut;
 merge BLMean &resp &resp.r;
 by &byvar &trtvar;
 RespVar="&Resp";
 run;

proc sort data=tests3 ;  by effect &byvar ;
proc sort data=tests3r ;  by effect &byvar ; run;

data &Tests3Out;
 merge  tests3(drop=NumDf DenDF FValue rename=(ProbF=Prob_all_data)) tests3r(drop=NumDf DenDF FValue );
by effect &byvar ;
run;

********Combined Solution F from All Data & Extreme Value Excluded ******;
data &SolutionFOut(drop=df tvalue stderr);
 merge SolutionF(rename=(Estimate=All_Estimate Probt=All_Probt)) R_SolutionF(rename=(Estimate=R_Estimate Probt=R_Probt));
 if effect="Intercept" then delete;
run;

******************* Check Residues **********;
Data resid;
 set T_ResidOut &ResidOut(in=a);
 if ^a then Set="All Data       ";
 else       Set="Extreme Removed";

ods output  Moments= Moments TestsForNormality=TestsForNormality;
proc univariate data=Resid normal;
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

proc means data=resid nway noprint  N Min Max Mean maxdec=1;
var StudentResid;
class  &byvar Set ;
output out=Tmp(drop=_Type_ _Freq_) N=N mean=Mean Median=Median Stddev=Stddev;
run;

data &UnivarOut;
 merge TMP Moments TestsForNormality;
 by  &byvar Set;
 run;

%mend;

