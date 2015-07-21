/*****************************************************************************************************************/
/*  Name:                Demographics Summary.sas                                                                */
/*  Inputs:              Indata:    Subject-Level Dataset
                         contvars:   List of Continous variables separated by blank to do ANOVA model
						 catvars:    List of categorical variables separated by blank to do Chisquare Test of Association
						 FisherVars: List of Categorical Variables Separated by blank to do Fisher Exact Test
                         ordvars :   List of ordinal variables separated by blank
                         nonparvars: List of nonparametric variables separated by blank
						 groupvar:   name of group variable (e.g, population or trtgrp)
                         outfile:     path and name of output RTF file including .RTF extension
/*****************************************************************************************************************/
/*  Example run
-----------
%let indata        = Subj;
%let Contvars      =  Age; 
%let CatVars       = Cosm_1_RatDiameter_ Demo_99_EyeColor_ ;
%let CatVars       = Cosm_1_RatDiameter_ race;
%let GroupVar      = cGroup;
%let outdata=DemogOut;
*/
%put 'Example Run:';
%put '%DemogSmry(indata=Subj, ContVars=Age, CatVars=Race , GroupVar=cGroup, outdata=Demogout);';

run;

%macro DemogSmry(indata=, ContVars=, CatVars=, GroupVar=, outdata=);

proc sort data=&indata out=indata;
by &groupvar;
run;

data indata;
 set indata;
 obs=_n_;
run;
ods trace off;

data demogtable;
set _null_;
format Vars $32. Stat $32.; 
run;
proc print; run;

****  Total Number of Subjects per Group *****;
run;
%macro m1;
	ods output OneWayFreqs=T1(Keep=&groupvar Frequency);
	proc Freq data=indata;
	table &GroupVar/list;
	run;
	data T1;
	 set T1;
	 length N $32.;
	 Vars="No_Subj";
	 N=compress(Frequency);
	proc transpose data=T1 out=T2(Rename=(_name_=Stat));
	var N;
	ID &groupvar;
	by Vars;
	run;
	data demogtable;
	set demogtable T2;
	run;
%mend;
%m1;
proc print data=demogtable;
run;

**** Continous Variable:ContVars *****;
run;
%macro m2;
%if %length(&contvars)>0 %then %do;

	proc transpose data=indata(keep=obs &ContVars &GroupVar) out=t1;
	 var &ContVars;
	 by obs &groupvar;
	 run;
	proc sort data=t1;
	 by _name_; run;

	ods output summary=t2(drop=NObs rename=(_name_=ContVars));
	Proc means data=T1 Mean Stddev Min Max;
	 class &groupVar;
	 Var Col1;
	  by _name_;
	  run;

	Data T2(drop=Col1_:);
	 set T2;
	  Mean_SD=strip(put(Col1_Mean,8.1))||" ("||strip(put(Col1_StdDev,8.1))||")";
	  Min_Max=strip(put(Col1_Min,8.1))||" - "||strip(put(Col1_Max,8.1));
	proc transpose data=T2 out=T3;
	 Var Mean_SD Min_max;
	 by ContVars;
	 ID &GroupVar;
	 run;
   
	ods output Tests3=Temp(keep=_name_ ProbF);
	proc mixed data=T1;
	class &groupVar;
	model Col1 = &groupVar;
	by _name_;
	run;

data T4;
	 set _null_;
	 length ContVars $24.;
	data T4;
	 set T4 temp(rename=(_Name_=ContVars ProbF=Prob));
	 run;

data T5(rename=(_name_=Stat));
	 merge T3 T4;
	 by ContVars;
	 if ^first.ContVars then Prob=.;
	  proc print ; run;

	data demogtable;
	set demogtable T5(rename=(ContVars=Vars));
	run;
%end;
%mend;
%m2;

proc print data=demogtable; run;

**** Cat Variable: CatVars *****;
run;
%macro m3;
%if %length(&CatVars)>0 %then %do;


	proc transpose data=indata out=t1;
	 var &CatVars;
	 by obs &groupvar;
	 run;
	proc sort data=t1;
	 by _name_;

	ods output CrossTabFreqs=freqs(where=(Col1^="" and &groupvar^="") drop=Table ) chisq=temp(where=(statistic="Chi-Square") keep=_name_ statistic Prob);
	Proc freq data=T1 ;
	 table  &groupVar*Col1/nopercent nocol chisq ;
	 by _name_;
	  run;

	Data freqs(drop=Missing  rename=(_name_=CatVars Col1=Stat));
	 set freqs;
	  N_RowPct=strip(put(Frequency,8.0))||" ("||strip(put(RowPercent,8.1))||"%)";
	  proc print data=freqs; run;
	proc sort data=freqs;
	 by CatVars Stat &groupvar;
	proc transpose data=freqs out=T2(drop=_name_);
	 Var N_RowPct;
	 by  CatVars Stat;
	 ID &GroupVar;

	data chisq;
	 set _null_;
	 length catvars $24.;
	data chisq;
	 set chisq temp(keep=_name_ Prob rename=(_name_=CatVars));
	 run;

	data T3;
	merge T2(in=a) chisq;
	by CatVars;
	if a ;
	 if ^first.CatVars then Prob=.;

	data demogtable;
	set demogtable T3(rename=(CatVars=Vars));
	run;


%end;
%mend;
%m3;

 data &outdata(drop=temp);
   SET demogtable;
   retain order temp;
   if _n_=1 then do; order=1; temp=Vars; end;
   if temp^=Vars then do; order+1; Temp=Vars; end;
RUN;
%mend DemogSmry;




