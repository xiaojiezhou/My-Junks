
**********************************************************************************************;
*  Author:  Xiaojie Zhou                                                                      ;
* Purpose: Verbatim Impact Analysis                                                           ;
* Example: %Vimpact(indata=VImpact, resp=upurint, cmmnt_var=fv: uf:, product=groups, uniq_id=uniq_id, weight=wt,
           exppath=C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\Test Programs\Junk);
* Restrictions: formats are required for all variables                                         ;
***********************************************************************************************;


**/******************** Macro **********************;
%macro Vimpact(indata=, resp=, cmmnt_var=, product=, uniq_id=, weight=, exppath=);
*********Transpose data*********;
proc sort data=&indata; by uniq_id;
proc transpose data=&indata out=two(rename=(_Name_=Name _label_=Label)) prefix=Resp;
 var &cmmnt_var;
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

Category_Impact=rowpercent*estimate;
COL=.;

****************Cosmetic fix on labels*********************;
if index(label, "(net)")>=1          then label=' '||label;
else if index(label, "(sub-net)")>=1 then label='     '||label;
else                                      label='         '||label;

label=TRANWRD(label,'Undup'   , '    Undup');

label=TRANWRD(label,'unfav '   , '');
label=TRANWRD(label,'fav '   , '');
run;

data pct;
 merge temp2 temp1;
by name;
 drop _name_ _label_ ;
 if N<=2 then probt=.;
 type=substr(name,1,2);
run;

******************Export the results*********************;

data Sign_undup; 
  set pct(where=(index(label,"Undup")>=1  and 1E-90<probt<0.05)); 
  label=COMPBL(label);  
  temp=abs(Category_Impact);
  run;
proc sort data=Sign_undup out=Sign_undup; 
by type temp;
run;

PROC EXPORT DATA= WORK.Sign_undup(drop=type temp)
            OUTFILE= "&exppath\&indata._&resp..xls" 
            DBMS=EXCEL REPLACE;
			Sheet="Sign Undup"; 
RUN;

PROC EXPORT DATA= WORK.pct(drop=type where=(index(label,"Undup")>=1  or 1E-90<probt<0.1))
            OUTFILE= "&exppath\&indata._&resp..xls" 
            DBMS=EXCEL REPLACE;
			Sheet="Sign_or_Undup"; 
RUN;

PROC EXPORT DATA= WORK.pct(drop=type)
            OUTFILE= "&exppath\&indata._&resp..xls" 
            DBMS=EXCEL REPLACE;
			Sheet="&cmmnt_var.&resp"; 
RUN;

%mend;
