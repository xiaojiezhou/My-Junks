/*************Usage************
%include "C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\PrdComprVsCntrl.sas";

%PrdComprVsCtrl(indata=one , panel_id=uniq_id, product=bkumain, 
                DQlist=believe distinc purint , 
                outdata=CSDQs, control=03_Java);
********************************/

%macro PrdComprVsCtrl(indata=, panel_id=, product=, DQlist=, catcovar=, cntcovar=, outdata=, control=);

proc sort data=&indata;  by &panel_id; run;

* proc print data=one(obs=10); run;

proc transpose data=&indata out=temp(rename=(_name_=DQ )) prefix=Resp;
var &DQlist ;
by &panel_id &product &catcovar &cntcovar;
run;

data temp; set temp; length DQlabel $40.;  DQlabel=_label_;

proc sort data=temp;  by DQLabel;  run;

ods output lsmeans=lsmeans diffs=diffs;
ods listing close;
proc mixed data=temp noinfo noitprint noprofile noclprint;
class &product &catcovar  ;
model resp1 =&product &catcovar &cntcovar ;
lsmeans &product/pdiff=control("&control") ;
by DQLabel;
run;
ods listing;

data diffs; set diffs; diff=put(estimate,5.1)||" ("||put(probt,5.3)||')'; run;

proc sort data=diffs ; by DQLabel &product _&product; run;
proc sort data=lsmeans; by DQLabel &product ; run;

proc transpose data=diffs out=diffs1;
var diff;
by DQLabel &product;
ID _&product;
run;

data &outdata(drop=effect stderr df tvalue probt _name_);
 merge lsmeans diffs1;
 by DQLabel &product;
 run;

 proc sort data=&outdata;
 by DQlabel &product;
run; 

proc print data=&outdata; Title "Comparisons (&product) vs Control (&control)"; 
by DQlabel;
id DQlabel;
run;
%mend;
