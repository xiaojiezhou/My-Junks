/***************************************************************************************************************************************************
	Name:		GROUPING									  			   									                      **************
	Dated:		18th June 2009
   	Updated:	5/6/10 Version 2

Macro-Grouping is used to perform grouping analysis on the data from macro-append as input and creates grouping dataset as output

	
 	Inputs datasets:	
 	    Inputdata          : The initial dataset that was used to run proc mixed
 		Estimates          : Appended dataset from from macro-append containg the following
 					         variables -- SortVar Effect classvar Estimate StdErr DF tValue Probt; 
 		Difference         : Appended dataset from from macro-append containg the following
 					         variables -- SortVar Effect classvar _classvar Estimate StdErr DF tValue Probt;
 		Tests          	   : Appended dataset from from macro-append containg the following
 					         variables -- SortVar Effect NUMDF DENDF FValue ProbF;
 	Intermediate Datasets in work directory:
        Estimates  			: Data-set formed after standardizing estimates in order to make it compatible to grouping-macro.
					         It contains the following variables -- SortVar classvar StdErr LSMEAN _NAME_ classvarA
        Difference 			: Data-set formed after standardizing estimates in order to make it compatible to grouping-macro.
					         It contains the following variables -- SortVar classvar _classvar PROB _NAME_ classvarA _classvarA
		test      			: Data-set formed after standardizing estimates in order to make it compatible to grouping-macro.
					         It contains the following variables -- SortVar PVAL _NAME_
 					
 	Outputs:
 	 	Grouping           : The final output datasets of Grouping Macro that has variables from input datasets and information
							 of grouping. It contains the following variables -- SortVar classvar NUMBER StdErr LSMEAN _NAME_ classvarA GROUPING PVAL

****************************************************************************************************************************************************/

*make changes here to store the macro catalogue;
*libname a '/data/Trainning/Sunita/P3-PG/P4';
Options macrogen symbolgen;
*options mstored sasmstore=a;

%MACRO GROUPING(INPUTDATA=,ESTIMATES=,DIFFERENCE=,TESTS=,GROUPING= );*/store;
options nomlogic nomprint nosource nosymbolgen nosource2 nomacrogen;

/****************** check for declaration of macro-variables required in this macro ****************************************************************/

%IF  %SYMEXIST(CLASSVAR) NE 1 
     OR %SYMEXIST(SORTVAR) NE 1
     OR %SYMEXIST(VAR) NE 1
     OR &SORTVAR = 
     OR &VAR =
     
%THEN %DO;
    %PUT UNINITIALIZED: DECLARATION OF MACRO VARIABLES -- " SORTVAR ,CLASSVAR and VAR " IS REQUIRED;
     ENDSAS;
    %END;
/****************************************************************************************************************************************************/

/*********** THIS SECTION PREPARES THE PROC MIXED OUTPUT DATA-SETS FOR GROUPING ANALYSIS ********************************/

* Note: Variable &CLASSVAR.A helps in formatting;

     %LET CLASSAVAR   = &CLASSVAR.A;
*This format is used only while preparing input datasets for grouping code;     
proc format;
     value $num 
			'A' = '1'
			'B' = '2'
			'C' = '3'
			'D' = '4'
			'E' = '5'
			'F' = '6'
			'G' = '7'
			'H' = '8'
			'I' = '9'
			'J' = '10'
			'K' = '11'
			'L' = '12'
			'M' = '13'
			'N' = '14'
			'O' = '15'
			'P' = '16'
			'Q' = '17'
			'R' = '18'
			'S' = '19'
			'T' = '20'
			'U' = '21'
			'V' = '22'
			'W' = '23'
			'X' = '24'
			'Y' = '25'
			'Z' = '26';
run;
    

*CLASSCNT Macro variable stores count of distinct values in Class variable (CLASSVAR) e.g. count of values of TRT ;

PROC SQL; SELECT COUNT( DISTINCT &CLASSVAR.) INTO :CLASSCNT1 FROM &INPUTDATA. ; QUIT;
%LET CLASSCNT=%SYSFUNC(COMPRESS(&CLASSCNT1.));

*Macro Variables COMPCNT and GRPLENGTH are calculated from CLASSCNT and are utilized in grouping code below ;
%LET COMPCNT     =%EVAL(&CLASSCNT*&CLASSCNT);
%LET GRPLENGTH  = %EVAL(2*&CLASSCNT);

*Counts total number of distinct SortVars and stores the values in macro variables VAR1, VAR2 and so on to create LASTSORT variable;
	%LET N = 1;
	%DO %WHILE ( %SCAN(&SORTVAR, %EVAL(&N)) NE );
	%LET VAR&N. = %SCAN(&SORTVAR, %EVAL(&N)); 
	%LET N = %EVAL(&N + 1 );
	%END;
	%LET N = %EVAL(&N - 1 );

/*    Section below concatenates the values of all Sortvars and creates variable LASTSORT which contain these values.     ****/
/*    LASTSORT helps in by-group execution of code where ever required i.e. each unique values of LASTSORT	              ****/
/*    will essentially represent a by-group and the count of distinct values of LASTSORT tells us the total               ****/
/*    number of by-groups. e.g. let "sortvar = visit age", (where visit = day1,day2 and age = 30,35) then	              ****/
/*    visit=day1 and age=30 will represent a value of by-group so that LASTSORT=day130.							          ****/

DATA ESTIMATES;   
	SET &ESTIMATES ;   
	LSMEAN=ESTIMATE; 
	_NAME_=UPCASE("&VAR");  
	&CLASSAVAR=PUT(&CLASSVAR,$2.);
	&CLASSVAR=PUT(&CLASSAVAR,$NUM.);
	LASTSORT=CATS(&VAR1.);
	%if (%EVAL(&N)>1) %then;
	%DO i=2 %to %eval(&N);
		LASTSORT=CATS(LASTSORT,&&VAR&i.);
    %END;
	 KEEP &CLASSVAR _NAME_ &SORTVAR  &CLASSAVAR LSMEAN STDERR LASTSORT ;
RUN;

DATA DIFFERENCE;   
	SET &DIFFERENCE;   
	PROB=PROBT;      
	_NAME_=UPCASE("&VAR");
	&CLASSAVAR=PUT(&CLASSVAR,$2.);
	_&CLASSAVAR=PUT(_&CLASSVAR,$2.);
	&CLASSVAR=PUT(&CLASSAVAR,$NUM.);
	LASTSORT=CATS(&VAR1.);
	%if (%EVAL(&N)>1) %then;
	%DO i=2 %to %eval(&N);
		LASTSORT=CATS(LASTSORT,&&VAR&i.);
	%END;  
	DROP PROBT EFFECT ESTIMATE STDERR TVALUE DF;
RUN;

%LET LASTSORT=LASTSORT;

*Sorting and dropping observations with missing values(if any);

DATA ALLNUM;
	SET ESTIMATES;
	KEEP &SORTVAR &CLASSVAR LSMEAN LASTSORT;
	IF &CLASSVAR NE . ;
RUN;

PROC SORT DATA=ALLNUM;
	BY &SORTVAR &LASTSORT LSMEAN;
RUN;

PROC SORT DATA=DIFFERENCE;
	BY &SORTVAR &LASTSORT;
RUN;

*Grouping Code Part1 - creates data-set ORDERNUM from ESTIMATES. ORDERNUM- has ordered ClassVar on the basis of estimates(LSMEANS) values in dataset ;

DATA ORDERNUM (DROP=COUNTR LSMEAN);
	SET ALLNUM;
	ARRAY ORDER{&CLASSCNT};
  	RETAIN ORDER1-ORDER&CLASSCNT.;
  	BY &SORTVAR &LASTSORT LSMEAN;
  	COUNTR+1;
  	ORDER(COUNTR)=&CLASSVAR;
  	IF LAST.&LASTSORT THEN
	DO;
    	COUNTR=0;
    	OUTPUT;
  	END;
RUN;

*Grouping Code Part2 - creates data-set PROBS from DIFFERENCE. PROBS- has significance indicator(0 or 1) of CLASSVAR combinations represented in form of a matrix;

DATA PROBS;
	SET DIFFERENCE ;
	BY &SORTVAR &LASTSORT;
	KEEP &SORTVAR &LASTSORT A B SIGNF1-SIGNF&COMPCNT;
	RETAIN SIGNF1-SIGNF&COMPCNT;
	ARRAY SIGNF[&CLASSCNT,&CLASSCNT];
  *IF INONE;
  	A=RANK(&CLASSAVAR)-64; B=RANK(_&CLASSAVAR)-64;
  	IF A=1 AND B=2 THEN
	DO;
    	DO X=1 TO &CLASSCNT;
       		DO Y=1 TO &CLASSCNT;
        		SIGNF(X,Y)=1;
       		END;
     	END;
  	END;

	IF PROB<=&TEST OR PROB=. THEN
	DO;
     	SIGNF(A,B)=0;
     	SIGNF(B,A)=0;
  	END;

  	IF LAST.&LASTSORT THEN
	DO;
    	OUTPUT;
  	END;
RUN;

*Grouping Code Part3 - creates data-set SIG by merging ORDERNUM & PROBS. 
This combines the Classvar and corresponding Significance indicator of its combination with other values of CLASSVAR in form of a matrix ;

PROC SORT DATA=PROBS;
	BY &SORTVAR A B;
RUN;

DATA SIG;
	MERGE ORDERNUM (IN=INONE) PROBS (IN=INTWO);
  	BY &SORTVAR &LASTSORT;
  	ARRAY ORD[&CLASSCNT] ORDER1-ORDER&CLASSCNT;
  	ARRAY SIG[&CLASSCNT,&CLASSCNT] SIGNF1-SIGNF&COMPCNT;
  	ARRAY ROWS[&CLASSCNT];
  	IF INONE AND INTWO;
  	IF LAST.&LASTSORT THEN 
	DO;
   		DO X=1 TO &CLASSCNT;
    		DO Y=&CLASSCNT TO 1 BY -1;
       			COL=ORD(X);
       			ROW=ORD(Y);
       			ROWS((&CLASSCNT+1)-Y)=SIG(COL,ROW);
    		END;
    	OUTPUT;
   		END;
  	END;
RUN;

* Grouping Code Part4 - creates data-set GROUPING from SIG ;

DATA GROUPING;
	SET SIG;
  	BY &SORTVAR &LASTSORT;
  	ARRAY ORD[&CLASSCNT] ORDER1-ORDER&CLASSCNT;
  	ARRAY SIG[&CLASSCNT,&CLASSCNT] SIGNF1-SIGNF&COMPCNT;
  	ARRAY ROWS[&CLASSCNT];
  	ARRAY GROUP[&CLASSCNT,&CLASSCNT] $ _TEMPORARY_;
  	ARRAY LETTR[15] $ _TEMPORARY_ ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o');
  	RETAIN HLSIG HOLD;
  	LENGTH HOLD $ &CLASSCNT GROUPING $ &GRPLENGTH;
  	IF FIRST.&LASTSORT THEN
	DO;
    	HLSIG=0; COUNTR+1;
      	DO X=1 TO &CLASSCNT;
        	DO Y=1 TO &CLASSCNT;
          		GROUP(X,Y)='*';
        	END;
      	END;
  	END;

  	LSIG=0;
  	DO X=1 TO &CLASSCNT;
    	IF ROWS(X)=1 THEN
		DO;
       		IF LSIG=0 THEN LSIG=X;
       		IF LSIG=HLSIG THEN GOTO NEXTOBS;
       		IF (COUNTR=1) OR (COUNTR>1 AND SIG(ORD((&CLASSCNT+1)-LSIG),ORD((&CLASSCNT+1)-X))=1) THEN 
			DO;
          		GROUP(COUNTR,X)=LETTR(COUNTR);
       		END;
    	END;
  	END;

  	HLSIG=LSIG;
  	COUNTR+1;
	NEXTOBS:
  	IF LAST.&LASTSORT THEN
	DO;
    	DO X=&CLASSCNT TO 1 BY -1;
    		HOLD='';
       		DO Z=1 TO &CLASSCNT;
         		HOLD=TRIM(LEFT(HOLD))||TRIM(LEFT(GROUP(Z,X)));
       		END;
       	GROUPING=TRANWRD(HOLD,'*','  ');
       	&CLASSVAR=ORD((&CLASSCNT+1)-X);
       	OUTPUT;
     	END;
     COUNTR=0;
  	END;
RUN;

PROC SORT DATA=GROUPING;
	BY &SORTVAR &CLASSVAR;
RUN;

/*THIS SECTION MERGES INFORMATION FROM GROUPING CODE OUTPUT WITH THE OUTPUT FROM PROC MIXED AND PROC MEANS to create final grouping dataset *****/

*Proc means used to calculate the sample sizes for different treatments;

PROC SORT DATA=&INPUTDATA;
	BY &SORTVAR;
RUN;

PROC MEANS DATA=&INPUTDATA NOPRINT NWAY;
	BY &SORTVAR;
	CLASS &CLASSVAR.;
	VAR &VAR;
	OUTPUT OUT=MEANS N=NUMBER;
Run;

DATA MEANS;   
	SET MEANS;   
	&CLASSAVAR=PUT(&CLASSVAR,$2.);
	&CLASSVAR=PUT(&CLASSAVAR,$NUM.);       
	KEEP &SORTVAR &CLASSVAR NUMBER;
RUN;
     
PROC SORT DATA=MEANS;
	BY &CLASSVAR &SORTVAR;
Run;

PROC SORT DATA=ESTIMATES;
	BY &CLASSVAR &SORTVAR;
Run;

PROC SORT DATA=GROUPING; 
	BY &CLASSVAR &SORTVAR;
Run;

DATA ESTIMATES_REPORT;  
	MERGE MEANS ESTIMATES GROUPING;
	BY &CLASSVAR &SORTVAR;RUN;
Run;

DATA TESTS; 
	SET &TESTS;
	IF UPCASE(EFFECT)=UPCASE("&CLASSVAR");  
    PVAL=PROBF;      
    _NAME_=UPCASE("&VAR");	
    KEEP &SORTVAR PVAL _NAME_ ;	
RUN;
     
PROC SORT DATA=ESTIMATES_REPORT;
	BY _NAME_ &SORTVAR;
Run;

PROC SORT DATA=TESTS;
	BY _NAME_ &SORTVAR;
Run;
/*
Delete this out after testing is complete
DATA &ESTIMATES.REPORT;
	MERGE ESTIMATES_REPORT TESTS;	 
	BY _NAME_ &SORTVAR;RUN;
Run;

DATA &GROUPING;
	SET &ESTIMATES.REPORT ;
	IF LSMEAN NE .;
RUN;
*/ 

DATA ESTIMATES_REPORT2;
	MERGE ESTIMATES_REPORT TESTS;	 
	BY _NAME_ &SORTVAR;RUN;
Run;

DATA &GROUPING;
	SET ESTIMATES_REPORT2;
	IF LSMEAN NE .;
RUN;

PROC SORT DATA = &GROUPING;
	BY &SORTVAR LSMEAN;
RUN;

options mlogic symbolgen;
%MEND;
/*END OF GROUPING CODE */


