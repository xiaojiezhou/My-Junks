/***************************************************************************************************************************************************
	Name:		REPORT_SSS_ABS
	Dated:		18th June 2009												  											                   
   	Updated:	5-3-10 Version 2
 Macro-REPORT_SSS_ABS creates a report for Adjusted Means .  

 	Output location:
		    LibnameOutputDS              :The location of the output dataset
 	Inputs: 
           	InputDSN		 :The initial dataset which was used in all three proc mixed.
           	APP_ESTIMATES	 :Appended ADJUSTED MEANS Dataset, Output of first SSS_append MACRO.
           	APP_DIFFERENCE   :Appended DIFFERENCE Dataset, Output of first SSS_append MACRO.
           	ESTIMATES        :Estimates dataset from proc mixed 3 (Change from Baseline Analysis)
 	Outputs:	
  		    The Macro creates the report.             
****************************************************************************************************************************************************/

*make changes here to store the macro catalogue;
*libname a '/data/Trainning/Sunita/P3-PG/P4';
Options macrogen symbolgen;
*options mstored sasmstore=a;

%macro REPORT_SSS_ABS(LibnameOutputDS=,InputDSN=, APP_ESTIMATES=, APP_DIFFERENCE=, ESTIMATES=);*/store;
options nomlogic nomprint nosource nosymbolgen nosource2 nomacrogen;

%let sortvar=%sysfunc(propcase(&sortvar));
%let Byvar=%sysfunc(propcase(&Byvar));
%let classvar=%sysfunc(propcase(&classvar));

proc sort data=&InputDSN; by &Byvar &Sortvar;run;

/*Calculates the sample size in each treatment level and sortvar */
PROC MEANS DATA=&InputDSN NOPRINT NWAY;
	by &Byvar &Sortvar;
	CLASS &classvar;
	VAR &Var.;
	OUTPUT OUT=MEANS N=NUMBER;
run;

proc sort data= means; by &Sortvar &classvar;run;
proc sort data=&APP_ESTIMATES ; by &Sortvar &classvar;run; 
proc sort data=&ESTIMATES; by &Sortvar &classvar;run;      
proc sort data=&APP_DIFFERENCE; by &Sortvar &classvar;run;

/*merging of additional column of change in adjusted means from baseline value to the table*/
data &LibnameOutputDS..&Var._SSS_ABS_ReportDS(drop= df probt tvalue alpha upper lower);
	merge 
		&APP_ESTIMATES  (rename=(estimate=adjusted_mean)       in=a) 
		&ESTIMATES (rename=(estimate=week_adjusted_mean) drop=stderr ) 
		&APP_DIFFERENCE (rename=(probt=pvalue)                 drop=_trt estimate stderr ) 
		MEANS;
		by &Sortvar &classvar;
		if a=1;
		if week_adjusted_mean=. then week_adjusted_mean=0;
run;

data _null_;
	set &InputDSN;
	call symput("svartype",vtype(&Sortvar));
	call symput("Classtype",vtype(&CLASSVAR));
run;

/*creates reports*/
ods rtf select all;
ods listing close; 

proc report data=&LibnameOutputDS..&Var._SSS_ABS_ReportDS nowd headline split='_' spacing=1  style(Header)=[BACKGROUND=white FONT_SIZE=10 pt  ];
	column &Byvar &Sortvar &classvar number adjusted_mean Week_adjusted_mean stderr pvalue;
	define &Byvar /group noprint "&Byvar.";
	define &Sortvar /order order=data center format= %if &svartype.=C %then $&SortVAR..; %else &SortVAR..; "&SortVAR.";
	define &classvar   /order left format= %if &classtype.=C %then $&classvar..; %else &classvar..; "Treatment"; *"&classvar.";
	define number   /display center 'Sample_Size';
	define Adjusted_mean / display center format=6.3 "Adjusted_Mean";
	define Week_Adjusted_Mean / display center format=6.3 "Change_from Baseline_Adjusted Mean";
	define stderr / display  center 'Standard_Error';
	define pvalue / display center 'P-Value_(Two-Sided)';
	compute after group;
	line ' ';
	endcomp;
run;

ods listing;
 options mlogic symbolgen;
%mend;

