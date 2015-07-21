/***************************************************************************************************************************************************
	Name:   	REPORTS_GRP_PVALUE_MULTIPLE									  			   									 **************
	Dated:		18th June 2009								                				  											 **************
	Updated:	5/24/10 Version 3

 This Macro creates grouping/pvalue reports from output of GROUPING-MACRO

 	Inputs:
		Reports        : List of reports name (grouping, pvalue or both) which needs to be generated
 		Datasets       : List of datasets required for genearting above mentioned reports in corresponding sequence
 
 	Outputs            : Final report is generated

********************************************************************************************************************************************************/

*make changes here to store the macro catalogue;
*libname a '/data/Trainning/Sunita/P3-PG/P4';
Options macrogen symbolgen;
*options mstored sasmstore=a;

%MACRO ReportMultipleGrpPvalue (REPORTS= ,DATASETS= );
options nomlogic nomprint nosource nosymbolgen nosource2 nomacrogen;

/****************** check for declaration of macro-variables required in this macro ********************************************************************/

%IF  %SYMEXIST(CLASSVAR) NE 1 
     OR %SYMEXIST(SORTVAR) NE 1
     OR %SYMEXIST(TEST) NE 1
     OR &SORTVAR = 
     OR &TEST = 
%THEN
%DO;
	%PUT UNINITIALIZED: DECLARATION OF MACRO VARIABLES -- "SORTVAR , CLASSVAR and TEST" IS REQUIRED;
	ENDSAS;
%END;

/*******************************************************************************************************************************************************/

*This format is used in GROUPING Report only;   
proc format;    
picture p (round)
			0.0000-<0.0001 = '<.0001*' (noedit)
			other = '9.9999*'
              . = '------'
           &test<-high  = '9.9999'
						;
picture pval (round)
			0.0000-<0.0001 = '<.0001' (noedit)
			other = '9.9999'
						;
run; 

/*******************************************************************************************************************************************************/

*Creates macro variables to read and store sort variables values and data types ;
%LET N = 1;
%DO %WHILE ( %SCAN(&SORTVAR, %EVAL(&N), %STR(" ")) NE );
	%LET SVAR&N. = %sysfunc(propcase(%SCAN(&SORTVAR, %EVAL(&N), %STR(" ")))); 
	%LET D = %SCAN(&DATASETS,1,%STR(" ") %STR(,));
	data temp;
		set  &D;
		call symput("svartype&n.",vtype(&&SVAR&N.));
		call symput("Classtype",vtype(&CLASSVAR));
	run;
	%LET N = %EVAL(&N + 1 );
%END;

%LET N = %EVAL(&N - 1 );

*Creates macro variables to read and store the reports name that needs to be generated ;
%LET COUNT1 = 1;
%DO %WHILE ( %SCAN(&REPORTS, %EVAL(&COUNT1), %STR(" ")) NE );
	%LET M&COUNT1. = %SCAN(&REPORTS, %EVAL(&COUNT1), %STR(" ")); 
   	%LET COUNT1=%EVAL(&COUNT1+1);
%END;
%LET COUNT1 = %EVAL(&COUNT1 - 1 );

*Reads and store the input data-set names and creates LASTSORT variable ;
%LET COUNT2 = 1;
%DO %WHILE ( %SCAN(&DATASETS, %EVAL(&COUNT2),%str(" ") %STR(,)) NE );
	%LET D&COUNT2. = %SCAN(&DATASETS, %EVAL(&COUNT2),%STR(" ") %STR(,));
	DATA TEMP&COUNT2.;
       	SET  &&D&COUNT2.;
		LASTSORT=CATS(&SVAR1.);
		%if (%EVAL(&N)>1) %then;
		%DO i=2 %to %eval(&N);
        	LASTSORT=CATS(LASTSORT,&&SVAR&i.);
        %END; 
	RUN; 
	PROC SORT DATA=TEMP&COUNT2.;
		BY &SORTVAR;
	RUN;

	%LET COUNT2=%EVAL(&COUNT2+1);
%END;

%LET COUNT2 = %EVAL(&COUNT2 - 1 );

PROC SQL noprint; SELECT DISTINCT(LASTSORT) INTO :LSVALUE SEPARATED BY '*' FROM TEMP1; QUIT;

*Creates subsets of grouping data for each distinct value of lastsort and generates the reports for that subset of data ;
*Report creation code. This piece can handle multiple by group variables and can pick corresponding formats for SORTVAR, CLASSVAR and VAR from format.sas;
%LET COUNT = 1;
%DO %WHILE ( %SCAN(&LSVALUE, %EVAL(&COUNT)) NE );
	%LET LSORTVALUE = %SCAN(&LSVALUE, %EVAL(&COUNT));
	%LET DN = 1;
	%DO %WHILE (%eval(&DN)<=%eval(&COUNT1));
		%IF %upcase(&&M&DN.)= GROUPING  %THEN 
		%DO;
		    data temp;
			    set temp&DN.;
			    where lastsort="&lsortvalue";
		    run;
			%if (%eval(&COUNT2.)>%eval(&COUNT1.)) %then
			%do;
				proc sort data=temp;
					by lastsort;
				run;
				proc sort data=temp&COUNT2.; 
					by lastsort;
				run;
						    
				data temp;
					merge temp(in=i) temp&COUNT2.(in=j) ;
					by lastsort;
					if i=1;
					if Estimate=. then Estimate=0;
				run;
			%end;
				    
			PROC SORT DATA = temp;
				BY &SORTVAR LSMEAN;
			RUN;				    
			ods rtf select all ;
			ods listing close;
			options nobyline;
			proc report data=temp nowd headline split='?'  spacing=0 box style(header)=[background=white font_size=10 pt  ];
	  			by &sortvar;
      			column _name_ &SortVar number &classvar.a grouping lsmean %if (%eval(&COUNT2.)>%eval(&COUNT1.)) %then estimate; stderr pval;
	  			define _name_   / order        left   format=$var.    width=23 'Attribute';
	  			%DO i=1 %to %eval(&N);
			        define &&SVAR&i. / order       center format=%if &&svartype&i..=C %then $&&SVAR&i...; %else &&SVAR&i...; width=12 id "&&SVAR&i." ;
			    %end;
	  			define number   / display      center format=3.            width=6  'Sample size';
	  			define &Classvar.a / display    left  format=%if &Classtype =C %then $&classvar..; %else &classvar..;  width=48 'Treatment';
	  			define grouping / display             format=$29.          width=30 'Grouping*'  style(column)=[asis=on];
	 			define lsmean   / analysis sum center format=7.3           width=6  'Adjusted?Mean' ;
	 			%if (%eval(&COUNT2.)>%eval(&COUNT1.)) %then
	  				define estimate  / analysis sum center  format=7.3         width=6  'Change in ?Adjusted Mean' ; ;
	  			define stderr   / analysis sum center format=5.3           width=5  'Standard Error';
	  			define pval  / analysis min noprint;
	  				
	  			compute after;
					line ' ';
					line @1 'Overall Treatment P-Value:' pval.min pval.;
	    			*line ' ';
	    			line '* There is insufficient evidence to conclude a difference between treatments with the same grouping letter.';
	   			endcomp;
			run;
					
		%END;	
		%IF %upcase(&&M&DN.)= PVALUE  %THEN 
		%DO;
		    *Data preparation for P-VALUE report;
		    data temp(drop= probt effect estimate stderr tvalue df);
				set temp&DN.;
				prob=probt;
				where lastsort="&lsortvalue";
			run; 
						 
			data s; set temp;
			data a; set s; vara=&classvar; varb=_&classvar;
			data b; set s; varb=&classvar; vara=_&classvar;
			data dreport(drop=lastsort); set a b;

			proc sort data=dreport;
				by &sortvar;
			run;
                    
			*Report creation code. This piece can handle multiple by group variables and can pick corresponding formats for SORTVAR, CLASSVAR and VAR from format.sas;
			ods rtf select all;
			ods listing close;
			options nobyline;
			proc report data=dreport nowd headline split='*' spacing=1  style(Header)=[BACKGROUND=white FONT_SIZE=10 pt  ];
	  			by &sortVar;
       			column (&sortvar vara prob,varb vara=vara2);
       			%DO i=1 %to %eval(&N);
			        define &&SVAR&i. / group   center format=%if &&svartype&i..=C %then $&&SVAR&i...; %else &&SVAR&i...; width=12 id "&&SVAR&i." ;
			    %end;
	         	define vara / group        center format=%if &Classtype.=C %then $&classvar.s.; %else &classvar.s.;   width=3  'Treatment' id;
	  			define varb / across       center format=%if &Classtype.=C %then $&classvar.s.; %else &classvar.s.;            ' ' style(Column)=[ASIS=ON];
	  			define prob / analysis sum center format=p.    width=6  ' ';
	  			define vara2/ group        left   format=%if &Classtype.=C %then $&classvar..; %else &classvar..; width=42 'Treatment Code Key' spacing=3;
	  			compute before _page_;
                line 'P-Values for Treatment Mean Pairwise Comparisons';
                endcomp;
	  			compute after;
	    		line "A p-value with a '*' indicates a significant difference between treatments (P<=&TEST).";
	  			endcomp;
			run;

			ods listing;
					
   		%END;
   		%LET DN = %EVAL(&DN+1);
   	%END;
    %LET COUNT=%EVAL(&COUNT+1);	      
%END; 
options mlogic symbolgen;
%MEND;

