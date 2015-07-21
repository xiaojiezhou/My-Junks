/****************************************************************************************************************************
	Name:		REPORT_SSS_TRTDIFF						  			   									                   
	Dated:		18th June 2009	
	Updated:	5-3-10 Version 2

 Macro-REPORT_SSS_TRTDIFF creates a report for difference in the Treatment levels.  

 	Inputs: 
			Estimates		:Input dataset for generating report
			Difference      :Input dataset for generating report
 	Outputs:	
  		    The Macro creates the report.             
*****************************************************************************************************************************/
	
*make changes here to store the macro catalogue;
*libname a '/data/Trainning/Sunita/P3-PG/P4';
Options macrogen symbolgen;
*options mstored sasmstore=a;

%macro REPORT_SSS_TRTDIFF(ESTIMATES= ,DIFFERENCE=);*/store;
options nomlogic nomprint nosource nosymbolgen nosource2 nomacrogen;

data _null_;
	set &DIFFERENCE;
	call symput("Classtype",vtype(&CLASSVAR));
run;

%if &classtype.=C %then %let classformat=$&classvar; 
%else %let classformat=&classvar; 

%let per=%sysevalf((1.0-&test)*100);

*The code below until proc report creates part of the title for the adjusted mean difference column in the report below;
proc sql noprint;
	select distinct &sortvar into: s separated by "*" from &ESTIMATES;
quit;

proc sql noprint;
	select count( distinct &sortvar) into: scount separated by "*" from &ESTIMATES;
quit;

%do i=1 %to &scount;
%let stemp1=%scan(&s,&i); 
data _null_;
	call symput('stemp2',put(&stemp1,&SortVAR..));
run;
%if %upcase(&stemp2) ne BASELINE %then %let svar=&stemp2;;
%end;

ods rtf select all;
ods listing close; 
proc report data=&DIFFERENCE nowd headline split='_' spacing=1  style(Header)=[BACKGROUND=white FONT_SIZE=10 pt  ];
	column &classvar _&classvar treatment estimate stderr probt lower upper;
	define &classvar  / order center noprint;
	define _&classvar / order center noprint ;
	define treatment / computed left 'Treatment Pair';
	define estimate  / display center format=6.3 "&svar._Adjusted_Mean_Difference";
	define stderr    / display center 'Std Err';
	define probt     / display center 'P-Value (Two-Sided)';
	define lower     / display center format=6.3 "Lower_&per.% Confidence_Bound";
	define upper     / display center format=6.3 "Upper_&per.% Confidence_Bound";

	compute treatment/ char length=175;
	treatment= cats(put(&classvar, &classformat..),'-',put(_&classvar, &classformat..));
	endcomp;
run;

ods listing;
 options mlogic symbolgen;
%mend;

