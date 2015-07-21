***************************************************************************************************************************************************
	Name:		REPORT_SSS_ABS_GeoMean
	Dated:		18th June 2009												  											                   
   	Updated:	7-7-10 Version 3

 Version 3 - Added in change from baseline p-value

 Macro-REPORT_SSS_ABS_GeoMean creates a report for Adjusted Means .  

 	Output location:
		    LibnameOutputDS  :The libname for the output dataset
 	Inputs: 
           	InputDSN		 :The initial dataset which was used in all three proc mixed statements.
           	APP_ESTIMATES	 :Appended ADJUSTED MEANS Dataset, Output of first SSS_append MACRO.
           	APP_DIFFERENCE   :Appended DIFFERENCE Dataset, Output of first SSS_append MACRO.
           	ESTIMATES        :Estimates dataset from proc mixed 3 (Change from Baseline Analysis)
 	Outputs:	
  		    The Macro creates the report and a permanent data set that was used in proc report.             
****************************************************************************************************************************************************/

*make changes here to store the macro catalogue;
*libname a '/data/Trainning/Sunita/P3-PG/P4';
Options macrogen symbolgen;
*options mstored sasmstore=a;

%macro REPORT_SSS_ABS_GeoMean(LibnameOutputDS=,InputDSN=, APP_ESTIMATES=, APP_DIFFERENCE=, ESTIMATES=);*/store;
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
data &LibnameOutputDS..&Var._BioRpt (drop= df probt tvalue alpha upper lower);
	merge 
		&APP_ESTIMATES  (rename=(estimate=adjusted_mean)       in=a) 
		&ESTIMATES (rename=(estimate=week_adjusted_mean probt=basechangepvalue) drop=stderr ) 
		&APP_DIFFERENCE (rename=(probt=pvalue)                 drop=_trt estimate stderr ) 
		MEANS;
		by &Sortvar &classvar;
		if a=1;
		if week_adjusted_mean=. then week_adjusted_mean=0;
run;

data &LibnameOutputDS..&Var._BioRpt;
	set &LibnameOutputDS..&Var._BioRpt;

	*calculate geometric mean;
	gm 	= 10**(adjusted_mean);

	*Include %change from baseline;
	if week_adjusted_mean = 0 then do;
		cfb1 = 0;
		cmsefb1 = 0;
		cpsefb1 = 0;	
	end;

	else if week_adjusted_mean ne 0 then do;
		CFB1 	=	(10**(week_adjusted_mean) - 1)*100;
		CMSEFB1	=	(10**(week_adjusted_mean-stderr)-1)*100;
		CPSEFB1	=	(10**(week_adjusted_mean+stderr)-1)*100;;
	end;

run;

data _null_;
	set &InputDSN;
	call symput("svartype",vtype(&Sortvar));
	call symput("Classtype",vtype(&CLASSVAR));
run;

/*creates reports*/
ods rtf select all;
ods listing close; 

proc report data=&LibnameOutputDS..&Var._BioRpt nowd headline split='_' spacing=1  style(Header)=[BACKGROUND=white FONT_SIZE=10 pt  ];
	column	&Byvar &Sortvar &classvar number adjusted_mean Week_adjusted_mean basechangepvalue stderr gm cfb1 cmsefb1 cpsefb1 pvalue;
	define	&Byvar /group noprint "&Byvar.";
	define	&Sortvar /order order=data center format= %if &svartype.=C %then $&SortVAR..; %else &SortVAR..; "&SortVAR.";
	define	&classvar   /order left format= %if &classtype.=C %then $&classvar..; %else &classvar..;		"&classvar.";
	define	number   /display center 'Sample_Size';
	define	Adjusted_mean / display center format=6.3 "Adjusted_Mean";
	define	Week_Adjusted_Mean / display center format=6.3 "Change_from Baseline_Adjusted Mean";
	define  basechangepvalue / display center 'Change from Baseline P-Value' ;
	define	stderr / display  center 'Standard_Error' format=8.4;
	define	gm / display center 'Geometric_Mean' format=6.2;
	define	cfb1 / display center '% Change_From_Baseline' format=5.2 ;
	define	cmsefb1 / display center '% Change - SE From_Baseline' format=5.2;
	define	cpsefb1 / display center '% Change + SE From_Baseline' format=5.2;
	define	pvalue / display center 'P-Value_(Two-Sided)';

	title2 "Analysis for &Var.";

	compute after group;
	line ' ';
	endcomp;
run;

ods listing;
 options mlogic symbolgen;
%mend;

