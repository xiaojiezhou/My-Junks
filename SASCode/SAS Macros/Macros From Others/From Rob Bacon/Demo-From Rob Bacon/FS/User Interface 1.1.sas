  /***************************************************************************************************
 Name:		Parallel Study User Interface					
 Dated:		18th June 2009									
 Updated:	Updated July 14, 2010
****************************************************************************************************************/

%LET Ddata		=C:  \Stat Data Folder\;                * User Input1: Define the directory for the input data set;
%LET Dcodes		=C:  \Stat Program Folder\;               * User Input3: Define the directory for the SAS codes;
%LET Foutput	=C:  \Stat Results Folder\;   * User Input4: Define complete path (including filename) for output file;

%LET Title		= Study CRB 10-02-025 China Biomarkers;            	* Define the title for the study;
%LET Indata		= in.crb1002025Biomarkers_2b; 	* Define the input data set;
%LET Sortvar	= studyday;       				* List all the by variables. In case of more than one by variable,list them space seperated e.g. SORTVAR = Visit Age Side;
%LET Classvar	= TRT;                  	* Define the Class variable whose effect is being studied;
%LET Test		= 0.20;                 	* Define the two sided p-value for testing significance;
%LET VarList	= LogIL1aProtein LogIL1raProtein LogIL1raIL1aRatio LogIL8Protein LogProteinCytokine LogHsaProtein LogKerProtein LogInvProtein LogProteinSkinMap LogHistamineProtein LogProteinHistamine LogIL1a LogIL1ra LogIL8 LogHsa LogKeratins11011 LogInvolucrin LogHistamine;               	* List all the dependent variable. In case of more than one variable, list them space separated;

%LET ResultsFileName=CRB 10-02-025 China Study Biomarker Results;

options nodate nonumber symbolgen mprint mlogic;
libname in "&Ddata";
				
%include "&Dcodes.China025_FormatsBio.sas";   
	*This code has the formats for 'SORTVAR' (sort variables), 'CLASSVAR' (Class variables) and 'VAR' defined in Global macro variables ;

%include "&Dcodes.AppendVer3.sas";
%include "&Dcodes.GroupingVer3.sas";
*%include "&Dcodes.ReportSingleGrpPvalueVer3.sas";
%include "&Dcodes.ReportSingleGrpPvalueBiomarkerVer3.sas";
*%include "&Dcodes.ReportMultipleGrpPvalueVer3.sas";
*%include "&Dcodes.ReportAcrossGrpVer4.sas";
*%include "&Dcodes.GraphFullScalpByPanel pre data merge.sas";

data datause;	
	set &indata;
	*outliers, instrument error etc. data points can be dropped out here;
run;

proc sort data = datause;
	by &sortvar;
run;

ods rtf file = "&Foutput.&ResultsFileName..doc" title = "&title" ; title "&title"; run; 
		*Initialization of single output file;

*ods pdf file = "&Foutput.&ResultsFileName.Residuals.pdf";
*ods listing close;
*ods graphics on;

%macro  Analysis();
%LET DEP_COUNT=1;
%DO %WHILE ( %SCAN(&varlist, %EVAL(&DEP_COUNT)) NE );;
	%let var=%SCAN(&varlist, %EVAL(&dep_COUNT), %STR(" "));
      
	/*ods rtf file = "&Foutput.&var._result.doc" title = "&title" ; title "&title"; run; 
		*Initialization of output file; If you want a separate file for each variable then activate this code and the rtf code below */
	
		*Proc Mixed1 for baseline data;
  	proc mixed data = datause;* noitprint noclprint noinfo;    
		where StudyDay = 1;
		by &Sortvar;
		class trt gender;
		model &var.= trt gender age/residual;
		*random RandNo;
		lsmeans trt / diffs cl;
		ods rtf exclude all;
	*	ods select studentpanel;
		ods output  lsmeans = &Var.LsmBs  diffs = &Var.DiffBs  tests3= &Var.Tst3Bs;  *Baseline Dataset name;
	run;
		
		*Proc Mixed2 for rest of the values of sortvar;
	proc mixed data = datause noitprint noclprint noinfo;	
		where StudyDay ne 1;
		by &Sortvar;
		class trt gender;
		model &var.= trt gender age Base&Var. /residual;
		*random RandNo;
		lsmeans trt / diffs cl;
		ods rtf exclude all;
	*	ods select studentpanel;
		ods output lsmeans = &Var.LsmPtBs  diffs = &Var.DiffPtBs  tests3 = &Var.TstPtBs;   *Dataset name;
	run;
				
		*Additional Proc Mixed3 for 'Change in adjusted means from baseline' column in report;
	proc mixed data = datause noitprint noclprint noinfo;  
		where StudyDay ne 1; 
		by &Sortvar;
		class trt gender;
		model Diff&Var.= trt gender age Base&Var. /residual;
		*random RandNo;
		lsmeans trt / diffs cl;
		ods rtf exclude all;
	*	ods select studentpanel;
		ods output lsmeans = in.&Var.LsmDiff;   *Difference Dataset name;
	run;
							
	%APPEND(Condition1  = ;	  , 
			Input1      = &Var.LsmPtBs &Var.DiffPtBs &Var.TstPtBs   ,

			condition2  = StudyDay=1;	, 
			Input2      = &Var.LsmBs &Var.DiffBs &Var.Tst3Bs	, 

			output      = in.&Var.LsmApp in.&Var.DiffApp &Var.Tst3App   );
				
			*Use this macro only when baseline dataset or output of any other proc mixed are required to be
			 appended to output datasets of proc mixed2;
			* "condition" are where clause of proc mixed only when condition has equal sign(=) else it will
			  be blank with semicolon as shown here;
				
	%GROUPING
		(	INPUTDATA=DataUse,
			ESTIMATES=in.&Var.LsmApp,
			DIFFERENCE=in.&Var.DiffApp,
			TESTS=&Var.Tst3App,
			GROUPING=in.&var.GrpDsn);

			* This macro does the grouping of class variable;

*	%ReportSingleGrpPvalue
		(	DATASETS=in.&var.GrpDsn in.&Var.DiffApp in.&Var.LsmDiff,
			REPORTS=grouping pvalue   );
			* This macro call creates two tables for grouping and pvalue and includes both the absolute values
			  and change from basleine.;
			* This macro generates one table  each for two types of report;
			* THE Arguments of REPORTS= can be of four types 1) grouping  2) pvalue   3) grouping pvalue      4) pvalue grouping;
			* THE Arguments of DATASET= will be the name of DIFFERENCE dataset and GROUPING dataset in the order of 4 types mentioned above for REPORTS=;
			* Incase of addition of column "Change in Adjusted mean" in the "Grouping" report, Add the lsmean dataset of proc mixed where dependent variable with "diff_" as prefix. Proc mixed 3 in the example;  


	%ReportSingleGrpPvalueBiomarker
		(	DATASETS	=in.&var.GrpDsn in.&Var.DiffApp in.&Var.LsmDiff,
			REPORTS		=Grouping Pvalue);
	
	
*	%ReportMultipleGrpPvalue
		(	DATASETS=in.&var.GrpDsn  in.&Var.LsmDiff,
			REPORTS=Grouping Pvalue);
			* This macro call creates two types of tables for grouping and pvalue;
			* This macro generates n tables each for two types of report where n=number of distinct combination 
			  of sort variables;
			* THE Arguments of REPORTS= can be of four types 1) grouping  2) pvalue   3) grouping pvalue 
			  4) pvalue grouping;
			* THE Arguments of DATASET= will be the name of DIFFERENCE dataset or appended Difference dataset, if more than one proc mixed are executed and GROUPING dataset name in the order of 4 types mentioned above for REPORTS=;
			* Incase of addition of column "Change in Adjusted mean" in the "Grouping" report, Add the lsmean dataset of proc mixed where dependent variable with "diff_" as prefix. Proc mixed 3 in the example;  
			* This dataset will be listed as the last datasets in the DATASETS argument;
	
	
*	%ReportAcrossGrp
		(	DATASETS=in.&var.GrpDsn in.&Var.LsmDiff,
			Across=StudyDay);

	* This macro call creates one table for grouping with one sortvar across the table;
	* This is GROUPING report with Horizotal representation of Across variable;
	* The code can handle only one across variable in this version;
	* Incase of addition of column "Change in Adjusted mean" in the "Grouping" report, Add the in.&Var.LsmDiff dataset;  
				 
 

*  	%GraphFullScalpbypanel(
			vargraph = in.&var.GrpDsn,
			changefrombaseline=Three Week Change from Baseline for ASFS Scores,
			xlabel1=Treatment, 
			ylabel1=Change from Baseline,
			absoluteestimate= Absolute Estimate,
			xlabel2=Treatment, 
			ylabel2=Absolute Estimate
			);
       
	* current this can only run if SortVar=StudyDay and if ReportSingleGrpPvalue is run first -  using file GraphFullScalpbyPanel pre data merged ver;
	* this version still needs to be cleaned up to be more flexible;

*ods rtf close;	*activate this rtf close when you want to create a separate file for each variable;

	%let DEP_COUNT=%eval(&DEP_COUNT+1);			
%end;
%mend;

options nodate nonumber symbolgen mprint mlogic;

%Analysis();

ods rtf close;
ods pdf close;
ods graphics off;



*this call is for a version of the macro that is supposed to run without running the singlegrppvalue macro
The macro needs some work before it can be used;
*	%graphfullscalpbypanel(
			changefrombaseline=Three Week Change from Baseline for ASFS Scores,
			xlabel1=Treatment, 
			ylabel1=Change from Baseline,
			absoluteestimate= Absolute Estimate,
			xlabel2=Treatment, 
			ylabel2=Absolute Estimate
			);
