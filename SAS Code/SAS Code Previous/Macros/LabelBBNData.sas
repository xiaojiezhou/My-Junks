/**********************************************************
Example:
%include "C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\LabelBBNData.sas";

* the first CSV is data;   
* the second CSV is labels;

%let CSVFileIn1=C:\Documents and Settings\tx3950\Desktop\CMK\2008\Java Benchmarking\BBN NO ES\CAU Final\FM Data\FM data.csv;
%let CSVFileIn2=C:\Documents and Settings\tx3950\Desktop\CMK\2008\Java Benchmarking\BBN NO ES\CAU Final\FM Data\FM Comments.csv;

********For Semi-column seperated file**************;
PROC IMPORT OUT= WORK.data 
            DATAFILE= "&CSVFileIn1" 
            DBMS=DLM REPLACE;
     DELIMITER='3B'x; 
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*********For comma seperated file**************;
PROC IMPORT OUT= WORK.data 
            DATAFILE= "&CSVFileIn1" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*********Import labelbames from BBN comments file ***********;
proc import out=work.labelnames
                    datafile="&CSVFileIn2"
					dbms=csv replace;
	getnames=no;
	datarow=2;
run;

%LabelBBNData(
	dataIn=data, 
	labelIn=labelnames,
	dataOut=result
);
***********************/
*-----------------------------------------------------------------------*;
%macro LabelBBNData(
/* SAS Dataset for the data*/   								dataIn=, 
/* SAS Dataset for the labels*/ 								labelIn=,
/* An output dataset with right value and labels*/ 	dataOut=
);
*-----------------------------------------------------------------------*;

ods listing close;
proc contents data=&dataIn varnum;
	ods output position = var_list;
run;
ods listing;

proc sql;
	select variable into : list_factor separated by ' ' from var_list
		where upcase(variable) like '%FACTOR%';						/* all column names has FACTOR in it */ 
	select count(variable) into : num_factor from var_list
		where  upcase(variable) like '%FACTOR%';
quit;

data &datain ;
	set &datain ;
	%do i = 1 %to &num_factor;
		start=index(trim(left(%scan(&list_factor, &i))),"(");
		end=index(trim(left(%scan(&list_factor, &i))),")");
		%scan(&list_factor, &i) = substr(trim(left(%scan(&list_factor, &i))),start+1, end-start-1);
		tmp&i =input(%scan(&list_factor, &i), best12.);					/* a temporary numeric variable */
	%end;
	drop &list_factor;										/* drop the original factor variables, which is char */
run;

data &datain ;
	set &datain ;
	%do i = 1 %to &num_factor;
		rename tmp&i=%scan(&list_factor, &i);				/* rename the temporary variable back to the original name*/
	%end;
run;

*------------ this part is for extraction of labels -------------*;

data  labelnames1;
	set &LabelIn;
	var1=compbl(var1);											/* remove multiple blanks */
	var1=compress(var1,'&%*;"');								/* remove macro tokens */
	length1=length('<html> \n<head>\n \n </head>\n <body>\n <p style\="margin-top\: 0">\n');
	start1=index(var1,'<html>');
	substr(var1,start1,length1-1)='"';    						/* remove the first string */
	length2=length('\n </p>\n </body>\n</html>\n');
	start2=index(var1,'\n </p>');
	substr(var1,start2)='"';							/* remove the second string */
	var1=tranwrd(var1,'[','_');
	var1=tranwrd(var1,']','_');
	var1=compbl(var1);											/* remove multiple blanks */
run;

proc sql noprint;
	select count(*) into : num_label from labelnames1;							/* how many labels we can get */
	select var1 into : list_statement separated by ';' from labelnames1;			/* a list of label statement */
quit;

data &dataOut;
	set &datain;
	%do i = 1 %to &num_label;						/* a bunch of label statements here */
		label %scan(&list_statement, &i,';') ;
	%end;
	drop end start;
run;

%mend;
