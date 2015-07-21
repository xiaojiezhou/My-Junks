%macro PrdCompr(indata=, panel_id=, product=, DQlist=, outdata=);

proc sort data=&indata;  by &panel_id; run;

* proc transpose data=&indata out=temp(rename=(_name_=DQ _label_=DQLabel)) prefix=Resp;
proc transpose data=&indata out=temp(rename=(_name_=DQ )) prefix=Resp;
var &DQlist;
by &panel_id &product;
run;

data temp; set temp; length DQlabel $40.;  DQlabel=_label_;

proc sort data=temp;  by DQLabel;  run;

ods output lsmeans=lsmeans diffs=diffs;
ods listing close;
proc mixed data=temp noinfo noitprint noprofile noclprint;
class &product;
model resp1 =&product;
lsmeans &product/pdiff ;
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

proc print data=&outdata; Title "Pairwise Comparisons Among &product"; 
by DQlabel;
id DQlabel;
run;
%mend;
