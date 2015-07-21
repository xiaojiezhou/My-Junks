
options ps=54 ls=135 macrogen mprint symbolgen;
**********Import file************;
%macro importdata(path=,infile=);
PROC IMPORT OUT= WORK.temp 
            DATAFILE= "&path\&infile" 
            DBMS=SAV REPLACE;
RUN;
%mend;
*%importdata(path=C:\Documents and Settings\tx2524\My Documents\mvic\Xiaojie\VerbatimImpactAnalysis\make files pretty\data,
            infile=US101684_cleaned.sav);
%importdata(path=C:\Documents and Settings\tx3950\Desktop\CMK\CMK HomeCare\2010\Dish\UnitDose\Data,
            infile=US101684_cleaned.sav);


proc format; 
  value Sample
    1='ActionPcs-Grp5'
    2='Powerball-Grp6'
    3='Complete-Grp7'
    4='Quantum-Grp8'
    ;
run;

data Vimpact(keep=groups upurint ratprod fv: uf: uniq_id wt ); 
set temp(where=(upurint^=.) drop=fvun: ufun:); 
length uniq_id $12.;
uniq_id=substr(serial,1,12);
wt=1;
format groups Sample.;
run;
proc contents data=VImpact   varnum; 
run;

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
data pct_bylegs2; set pct_bylegs; rowpercent=round(rowpercent,1.0); run ; **bambi added to round**;

proc transpose data=pct_bylegs2 out=temp1 prefix=P_;
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

********Cosmetic fix on labels***********;
if index(label, "(net)")>=1          then label=' '||label;
else if index(label, "(sub-net)")>=1 then label='     '||label;
else                                      label='         '||label;


label=TRANWRD(label,'Undup'   , '    Undup');

label=TRANWRD(label,'unfav '   , '');
label=TRANWRD(label,'fav '   , '');
run;

data pct;
 merge temp2       
       temp1
;
by name;  
type=substr(name, 1,2); **bambi added**;
 drop _name_ _label_ ;
 if N<=2 then probt=.;
run;
data Sign_undup; 
  set pct(where=(index(label,"Undup")>=1  and 1E-90<probt<0.05)); 
  label=COMPBL(label);  
  type=substr(name, 1,2);
  temp=abs(Category_Impact);
  run;
proc sort data=Sign_undup out=Sign_undup(drop=temp);  **bambi changed: used to be drop=type**; 
by type temp;
run;

/*******bambi added*******/
data subpct; set pct;
 if index(label,"Undup")>=1  or 1E-90<probt<0.1;
 type=substr(name, 1,2);
run; 
proc print data=subpct;run;
proc sort data=subpct; by type;  run;
proc sort data=pct; by type;  run;
ods html file="&exppath\signundup&indata._&resp..xls" ; 
proc print data=sign_undup noobs; format pct 8.0 impact 8.0 probt 8.4 category_impact 8.0; 
  by type; id type; run;
ods html close;

ods html file="&exppath\signORundup&indata._&resp..xls" ; 
proc print data=subpct noobs; format pct 8.0 impact 8.0 probt 8.4 category_impact 8.0; 
  by type; id type; run;
ods html close;

ods html file="&exppath\All&indata._&resp..xls" ; 
proc print data=pct noobs; format pct 8.0 impact 8.0 probt 8.4 category_impact 8.0; 
  by type; id type; run;
ods html close;
/*******end of code bambi added*******/

/*PROC EXPORT DATA= WORK.Sign_undup
            OUTFILE= "&exppath\&indata._&resp..xls" 
            DBMS=EXCEL REPLACE;
			Sheet="Sign Undup"; 
RUN;

PROC EXPORT DATA= WORK.pct(where=(index(label,"Undup")>=1  or 1E-90<probt<0.1))
            OUTFILE= "&exppath\&indata._&resp..xls" 
            DBMS=EXCEL REPLACE;
			Sheet="Sign_or_Undup"; 
RUN;

PROC EXPORT DATA= WORK.pct
            OUTFILE= "&exppath\&indata._&resp..xls" 
            DBMS=EXCEL REPLACE;
			Sheet="&cmmnt_var.&resp"; 
RUN;*/

%mend;

%Vimpact(indata=VImpact, resp=upurint, cmmnt_var=fv: uf:, product=groups, uniq_id=uniq_id, weight=wt,
         exppath=C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\Test Programs\Junk);
*%Vimpact(indata=VImpact, resp=upurint, cmmnt_var=fv: uf:, product=groups, uniq_id=uniq_id, weight=wt,
         exppath=C:\Documents and Settings\tx2524\My Documents\mvic\Xiaojie\VerbatimImpactAnalysis\make files pretty\output);

proc print data=pct; where index(label,"Undup")>=1; run;
