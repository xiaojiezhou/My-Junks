%macro PrdCompr(indata=, panel_id=, product=, DQlist=, catcovar=, cntcovar=, outdata=);

proc sort data=&indata;  by &panel_id; run;

proc transpose data=&indata out=temp(rename=(_name_=DQ )) prefix=Resp;
var &DQlist;
by &panel_id &product &catcovar &cntcovar;
run;

data temp; set temp; length DQlabel $40.;  DQlabel=_label_;

proc sort data=temp;  by DQLabel;  run;

ods output lsmeans=lsmeans diffs=diffs;
ods listing close;
proc mixed data=temp noinfo noitprint noprofile noclprint;
class &product &catcovar ;
model resp1 =&product &cntcovar &catcovar;
lsmeans &product/pdiff ;
by DQLabel;
run;
ods listing;

proc sort data=lsmeans; by DQLabel &product ; run;

proc sql;
create table diffs as 
select diffs.*, put(estimate,5.1)||" ("||put(probt,5.3)||')' as diff, sum((probt>=0)) as count
from diffs
group by DQlabel, Effect, &product
order by DQLabel, Effect, &product, _&product
;

proc transpose data=diffs out=diffs1;
var diff;
by DQLabel &product count;
ID _&product ;
run;

data &outdata(drop=effect stderr df tvalue probt _name_);
 merge lsmeans(in=a) diffs1;
 by DQLabel &product;
 if a;
 run;  

 proc sort data=&outdata;
 by DQlabel descending count &product;
run; 

proc print data=&outdata; Title "Pairwise Comparisons Among &product"; 
by DQlabel;
id DQlabel;
run;
%mend;
