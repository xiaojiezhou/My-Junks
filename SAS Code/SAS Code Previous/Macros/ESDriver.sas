
**********************************************************************************************;
*  Author:  Xiaojie Zhou                                                                      ;
* Purpose: T Driver Analysis for ES dat                                                       ;
* Example: 
*  %include "C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\ESDriver.sas"              ;
*  %ESDriver(indata=ES, resp=Purin, Attrib=fv: uf:, product=groups, uniq_id=uniq_id, weight=wt,
           exppath=C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\Test Programs\Junk)  ;
* Restrictions: formats are required for all variables                                         ;
***********************************************************************************************;


**/******************** Macro **********************;
%macro ESDriver(indata=, resp=, Attrib=, product=, uniq_id=, weight=, exppath=);
*********Transpose data*********;
proc sort data=&indata; by &uniq_id;
proc transpose data=&indata out=two(rename=(_Name_=Name _label_=Label)) prefix=Resp;
 var &Attrib;
 by &uniq_id &product &resp  &weight;
run;

*************Calculate % response with V Comments*********;
ods output crossTabFreqs=pct_all;
ods listing close;
proc freq data=two ;
table name*label*resp1/nopercent nocol;
weight &weight;
run;
ods output crossTabFreqs=pct_bylegs;
proc freq data=two ;
table &product*name*resp1/nopercent nocol;
weight &weight;
run;
proc sort data=two; by name;
ods output SolutionF=SolutionF;
proc mixed data=two noinfo noitprint noprofile noclprint;
model &resp =resp1/s;
weight &weight;
by name;
run;
ods listing;

proc sort data=pct_bylegs;
by name &product;
where (_type_='111' and resp1=1 and rowpercent^=.);
run;
proc transpose data=pct_bylegs out=temp1 prefix=P_;
var rowpercent ;
by name ;
id &product;
run;

data temp2;
 merge pct_all(where=(_type_='111' and resp1=1 and rowpercent^=.)  )
	   solutionF(where=(Effect='Resp1') )       
;
by name;
rename frequency=N rowpercent=Pct estimate=Impact;
 drop table resp1 _type_ _table_ missing  effect stderr df tvalue;

Total_Impact=rowpercent*estimate;

Potential_Impact=(100-rowpercent)*estimate;
COL=.;
run;

data pct;
 merge temp2 temp1;
by name;
 drop _name_ _label_ ;
 if N<=2 then probt=.;
 type=substr(name,1,2);
run;

proc  print data=pct;
run;


/******************Export the results*********************;
PROC EXPORT DATA= WORK.pct(drop=type)
            OUTFILE= "&exppath\&indata._&resp..xls" 
            DBMS=EXCEL REPLACE;
			Sheet="&indata"; 
RUN;
*******/
%mend;
