***************************************************************************************************
 Name:	User Interface for Split Scalp Studies where each treatment pair is analyzed separtely 					
 Dated:	5-3-10									
***************************************************************************************************/

* Define the directory for the input data set;
%LET Ddata		=C:\  Stat Data Folder;

* Define the directory for the SAS codes;
%LET Dcodes		=C:\ Stat Program Folder;

* Define the directory for output file;                    
%LET Foutput	=C:\ Stat Results Folder;

libname in "&Ddata";

%LET Title		= CRB ;		        * User Input5 : Define the title for the study;
%LET Test		= 0.1;     		                * User Input6 : Define the p-value for testing significance;
%LET Indata		= in.CRB;		* User Input7 : Define the input data set;
%LET Byvar	    = Group;    		                * User Input8 : Define the by variable;
%LET Classvar	= TRT;      		                * User Input9 : Define the Class variable whose effect is being studied;
%LET Sortvar	= StudyDay;    		                * User Input10: List variables for subsetting the input data for the analysis; 
%LET VarList	= LogHsaProtein ;*LogKeratins11011Protein LogInvolucrinProtein LogProteinSkinMap LogIL1raProtein LogIL1aProtein LogIL1raIL1aRatio LogIL8Protein LogProteinCytokine; 
%Let ResultsFileName=CRB ;           

                          		
/***************************************************************************************************/

options nodate nonumber symbolgen mprint mlogic;

*This code has the formats for 'SORTVAR' (sort variables), 'CLASSVAR' (Class variables) and 'VAR' defined in Global macro variables ;
%include "&Dcodes.\FormatsV1.sas";

%include "&Dcodes.\APPEND_Ver2.sas";
%include "&Dcodes.\REPORT_SSS_TRTDIFF_Ver2.sas";
%include "&Dcodes.\GRAPH_SSS_TRTDIFF_BARCHART_Ver1.sas";
%include "&Dcodes.\REPORT_SSS_ABS_Ver2.sas";
%include "&Dcodes.\REPORT_SSS_ABS_GeoMean_Attribute_Ver2a.sas";

data datause;
	set &indata;
	*Modify the anlaysis dataset here;
	if trt='A' or trt='B' then Group=1;
	if trt='C' or trt='D' then Group=2;
run;
			
proc sort data=datause; by &ByVar; run;					

* Initialize the ods file;
ods rtf file = "&Foutput.\&ResultsFileName..doc" title = "&title"; title "&title"; run;
ods pdf file = "&Foutput.\&ResultsFileName.Residuals.pdf";

%macro Analysis();
	%LET DEP_COUNT=1;
	%DO %WHILE ( %SCAN(&varlist, %EVAL(&DEP_COUNT)) NE );;
%let var=%SCAN(&varlist, %EVAL(&dep_COUNT), %STR(" "));

ods listing close;
ods graphics on;
 
title2"&var."; 

ods select studentpanel;
proc mixed data=datause;* noitprint noclprint noinfo;	*Proc Mixed1;
   where &sortvar=1; *baseline;
   by &byvar;
   class RandNo trt side;                                     
   model &var.= trt side /residual ;                                   
   random RandNo;
   lsmeans trt / diffs cl alpha=.1; 
   ods rtf exclude all;
   ods output lsmeans = &Var.LsmBs diffs = &Var.DiffBs;
run;

ods select studentpanel;
proc mixed data=datause;* noitprint noclprint noinfo;		*Proc Mixed2;
  where &sortvar=21; *week3;
  by &byvar;
  class RandNo trt side;
  model &var.= base&var. trt side /residual;
  random RandNo;
  lsmeans trt / diffs cl alpha=.1;
  ods rtf exclude all;
  ods output lsmeans = &Var.LsmPtBs diffs = &Var.DiffPtBs ;
run;

ods select studentpanel;
proc mixed data=datause;* noitprint noclprint noinfo;		*Proc Mixed3;
  where &sortvar=21; *week3 difference;
  by &byvar;
  class RandNo trt side;
  model diff&var.= base&var. trt side /residual;						
  random RandNo;
  lsmeans trt / diffs cl alpha=.1; 
  ods rtf exclude all;
  ods output lsmeans = in.&Var.LsmDiff diffs = DiffsDiffVar;
run; 

ods graphics off;
ods listing;

* Appends the datasets from proc mixed1 and proc mixed2 along with creating the columns using the condition of "where" clauses;
* This macro will create the input datasets for Adjusted Mean Table;
%APPEND(    condition1  =StudyDay=1;                    , 
			input1      =&Var.LsmBs &Var.DiffBs           , 
			condition2  =StudyDay=21;                ,
			input2      =&Var.LsmPtBs &Var.DiffPtBs     , 
			output      =in.&Var.LsmApp in.&Var.DiffApp      );

*This macro just creates the columns using the condition of "where" clauses from proc mixed3 without appending any dataset;
*The output of this macro is input to the Difference in treatment level table;
%APPEND(    condition1  =StudyDay=21;    ,
            Input1      =in.&Var.LsmDiff   ,
            condition2  =                ,
            Input2      =                , 
            Output      =);

*This macro creates Bar Chart With Error Bars;
*%GRAPH_SSS_TRTDIFF_BARCHART(GraphDS=DiffsDiffVar);
 
*This macro creates Difference in treatment level table;
*%REPORT_SSS_TRTDIFF(ESTIMATES=in.&Var.LsmDiff, DIFFERENCE=DiffsDiffVar);


*This macro creates Adjusted Mean Table;
*%REPORT_SSS_ABS(LibnameOutputDS=in, InputDSN=DataUse, APP_ESTIMATES=in.&Var._Lsm_app, APP_DIFFERENCE=in.&Var._Diffs_app, ESTIMATES=in.&Var.LsmDiff);

*This macro creates Adjusted Mean Table for Biomarkers;
%REPORT_SSS_ABS_GeoMean(LibnameOutputDS=in, InputDSN=DataUse, APP_ESTIMATES=in.&Var.LsmApp, APP_DIFFERENCE=in.&Var.DiffApp, ESTIMATES=in.&Var.LsmDiff);

%let DEP_COUNT=%eval(&DEP_COUNT+1);			
%end;
%mend;
%Analysis();

ods rtf close;
ods pdf close;


