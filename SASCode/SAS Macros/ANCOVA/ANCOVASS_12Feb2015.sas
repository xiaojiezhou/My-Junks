


%put "ANCOVASS(Indata=, Resp=, byVar=, TrtVar=,CovVar=, ClassVar= , 
		optinal_repeat_Statement= ,	optinal_random_Statement= , optinal_repeat_Statement= , 
		Tests3Out=, TableOut=, SolutionFOut=, ResidOut=, UnivarOut=, trtcomps=trtcomps)";

%macro ANCOVASS(Indata=, Resp=, byVar=, TrtVar=,CovVar=, ClassVar= , 
		optinal_repeat_Statement= ,
		optinal_random_Statement= ,
		Tests3Out=, TableOut=, SolutionFOut=, ResidOut=, UnivarOut=, trtcomps=trtcomps);

options mlogic symbolgen;

%include"\\qsfiles.pg.com\beauty_care\clinical\Biometrics\XiaojieZhou\SAS_R Code\SAS Code\SAS Macros\ANCOVA\ANCOVA_27Dec2013.sas"
/*****PostBL*****
%let Indata=PostBL;
%let Resp=CFB;
%let byVar=Selected Measure cGroup Week Visitlabel;
%let TrtVar=Trt_Cntrl;
%let CovVar= Side BL;
%let ClassVar= ArchiveID Trt_Cntrl Side;
%let optinal_random_Statement=random ArchiveID;
%let optinal_repeat_Statement= ;    
%let Tests3Out=CFB_Tests3Out;
%let TableOut=CFB_GrpCmprOut;
%let SolutionFOut=CFB_SolutionFOut;
%let ResidOut=CFB_ResidOut;
%let UnivarOut=CFB_ResiTest;
%let trtcomps=trtcomps;
****/;

data indata;
 set &indata;
run;

proc sort data=indata(keep=&trtvar) out=ntrt nodupkey;
 by &trtvar;
 run;

 proc sql noprint;
    select count(distinct &trtvar) into :ntrtvar from ntrt ;
	select &trtvar into :Trt1-:Trt2 from ntrt ;
	%put &ntrtvar &trt1 &trt2;
run;

data check1; num=&ntrtvar; if num=2 then result='TRUE  ';else result='FALSE';run;
data _null_; set check1; call symput('number',result);run;

%if &number=TRUE  %then %do;

%ANCOVA(Indata=&Indata, Resp=&Resp, byVar=&byVar, TrtVar=&TrtVar, CovVar=&CovVar, ClassVar=&ClassVar , 
		optinal_repeat_Statement=&optinal_repeat_Statement ,optinal_random_Statement=&optinal_random_Statement,
		 Tests3Out=&Tests3Out, TableOut=&TableOut,
		SolutionFOut=&SolutionFOut, ResidOut=&ResidOut, UnivarOut=&UnivarOut, trtcomps=trtcomps);

options spool;

	proc sort data=&indata; by ArchiveID &byvar;run;
 	proc transpose data=&indata out=outtr(drop=_name_) Prefix=_;
		id &trtvar;
		by archiveID &byvar;
		var &Resp;
	run;
	data outtr; set outtr; diff=_&TRT1 - _&Trt2;run;

	ods output TestsForLocation=wilcoxs(where=(Testlab="S") rename=(pvalue=wilcox_1));
	proc sort data=outtr;by &byvar; run;
	proc univariate data=outtr;
		var diff;
		by &byvar; run;

	proc sort data=&tableout;by &byvar;run;
	proc sort data=wilcoxs out=wilcoxs(keep=&byvar wilcox_1); by &byvar;run;
	data &tableout;
		merge &tableout wilcoxs;
		by &byvar;
	run;
	data &TableOut;
		set &TableOut;
		by &byvar;
		if est_1=. then wilcox_1=.;run;

	proc datasets lib=work;
	delete check1;
	quit;
%end;


%else %do;
proc datasets lib=work;
delete check check1;
quit;
%put WARNING:The number of treatment should not be larger than 2;
%end;


ods listing;
options nomlogic nosymbolgen;
%mend;



