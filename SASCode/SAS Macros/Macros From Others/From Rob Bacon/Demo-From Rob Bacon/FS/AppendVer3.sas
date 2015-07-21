/***************************************************************************************************************************************************
	Name:		APPEND										  			   									                  **************
	Dated:		18th June 2009	
	Updated:	5-3-10 Version 3

 Macro-append combines (appends) data-sets generated from proc-mixed1 and proc-mixed2.
 It can append only two datasets into one datasets at time, 
 however it can appended n pairs of datasets in input1 and input2 to create n output datasets in one macro call.
 
 Inputs:		
 	    Input1             :  output of proc mixed1 whose outputs are required to be appended to output 
 	    Condition1         :  its value is "where clause" condition in proc mixed1 only if condition has equal to sign "=" else  condition1=;              
 	    Input2             :  output of proc mixed2 whose outputs are required to be appended to output 
 	    Condition2         :  its value is "where clause" condition in proc mixed2 only if condition has equal to sign "=" else  condition2=;   
 
 Outputs:	
 	    Output             :  Appended datasets
  		
****************************************************************************************************************************************************/

*make changes here to store the macro catalogue;
*libname a '/data/Trainning/Sunita/P3-PG/P4';
Options macrogen symbolgen;
*options mstored sasmstore=a;

%MACRO APPEND(condition1=,Input1=,condition2=,Input2=, Output=);*/store;
options nomlogic nomprint nosource nosymbolgen nosource2 nomacrogen;

/****************** check for declaration of macro-variables required in this macro ****************************************************************/

* 	The purpose of this macro is to create two datasets defined in the output call
of the macro.  In the first step it takes the datasets from a specific visit
and places the visit information in that dataset.  The reason is that the datasets
are SAS output and do not contain visit information.  Next they take the two datasets
and use a set statement to stack them together.  The resulting dataset is named
according to the output call in the macro.

    
*creates the where conditions and appends two input datasets;
%DO COUNT = 1 %to 2;
    %LET COUNT1 = 1;
	%DO %WHILE ( %SCAN(&&Input&count.., %EVAL(&COUNT1), %STR(" ")) NE );
		%LET D&count.&count1.= %SCAN(&&Input&count.., %EVAL(&COUNT1), %STR(" "));
    	%LET Out&count1.= %SCAN(&Output., %EVAL(&COUNT1), %STR(" "));
*so if there were two datasets in input1 then they would resolve to D11 and D21;
*if there were two datasets in input2 then they would resolve to D21 and D22 ;           
		%LET COUNT2=1;
	        %DO %WHILE ( %SCAN(&&Condition&count.., %EVAL(&COUNT2), %STR(";")) NE );
            	%LET C&count2.= %SCAN(&&Condition&count.., %EVAL(&COUNT2), %STR(";"));
            
			            * Creates the variables/column in the dataset using the conditions;
				DATA &&D&count.&count1.;
					set &&D&count.&count1.;
			    	&&C&count2.;  *This line creates the visit information;
				run;
			
				%LET COUNT2 = %EVAL(&COUNT2 + 1 );
			%END;
    	%LET COUNT1 = %EVAL(&COUNT1 + 1 );
    %END;
%END;

*This code stacks together D11 and D21 together;
%do j=1 %to %eval(&count1-1);
   data &&out&j;
   	set &&D1&j. &&D2&j.;
   run;
%end;
options mlogic symbolgen;
%MEND;
