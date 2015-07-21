/************************************************************************/
/*** Program: 		ShapeIT2.sas	              								***/
/*** Date:	 	06/06/2004  						  		      				***/
/*** Reference:	ShapeIT.sas
/*** Date Modified:	03/30/2010																***/
/*** This macro shape an input data set without BaseVars DiffVars  	***/
/***			and output data with corresponding Basevars & DiffVars 	***/
/*** Modification: add PCFBVars (Percentage change from baseline)	to the output dataset ***/
/*** Author:  		Jim Li & Min Lin							                 ***/
/************************************************************************/
/*** Datain: 	Input data set name					***/
/*** Datatout:	Output data set name					***/
/*** TimeVar:	Variable name of the visit. ex. Visit, Week		***/
/*** BaseTime:	Baseline value of the time variable. ex. 0, 1  		***/
/*** VarList:	List of Variables to create Base and Diff. ex. Q1 Q2 Q3 ***/
/*** NoOfVars:	No. of variables. ex. 3					***/
/*** Sortvars:  Sort-by variables. ex. Subject Side Site		***/

*** Example of Invokation of ShapeIT;
*** ;
%put 'Usage:  %ShapeIt(datain=b2, dataout=b3, TimeVar=StudyDay, BaseTime=1, VarList=Diameter, NoofVars=1, SortVars=ArchiveID Group Age  side trt Measure);';

%macro ShapeIt(datain=, dataout=, TimeVar=, BaseTime=, VarList=, NoofVars=, SortVars=);

data temp;
  set &datain;
run;

%do i=1 %to &NoofVars;

%let VarWork=%scan(&varlist,&i);

data base;
  set &datain(keep=&sortvars &timeVar &Varwork);
  if &timeVar=&basetime;
  rename &varwork.=Base&varwork.;
  drop &timevar.;
  label &varwork.=;
  run;

proc sort data=base out=base nodupkey;
  by &SortVars;
  run;

proc sort data=temp out=whole;
  by &SortVars;
  run;

data temp;
  merge whole base;
  by &SortVars;
  Diff&varwork.=&varwork. - Base&varwork.;
  run;

%end;

data &dataout; 
  set temp; 
  run;

* proc print data=&dataout;
  run;

/*proc datasets nolist;*/
/*  delete temp base whole;*/
/*  run;*/
/*  quit;*/

%mend ShapeIt;


