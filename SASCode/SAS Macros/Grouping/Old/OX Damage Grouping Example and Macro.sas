options ls=135 ps=54;
ods html  close;
ods listing;


libname in "Q:\beauty_care\clinical\Biometrics\Lin Fei\2011\CRB 11-12-149 Oxidative Damage - Maaike Bose\data";


data t1(drop=diff: average: pcfb: baseaverage:  ) ;
 set in.crb1112149db(drop=hrlength hrweight );
* set in.crb1112149db(where=(visit^=2 and side ^="R") drop=hrlength hrweight );
 run;
 proc sort data=t1;
  by visit; run;
*  ods csv;
proc contents data=t1 varnum;
run;
ods csv close;


%let resp=IL1aNrm;


%let resp=LogHODE;
%let resp=LogHODEC18ratio;
%let resp=logSQ_OOH;
%let resp=LogSQ_OOHN;
%let resp=logEndPtFtz;

proc contents data=t1 varnum;
run;

ods output lsmeans=lsmeans diffs=diffs;
proc mixed data=t1;
class trt gender;
model &resp=gender age trt;
lsmeans trt/pdiff;
by visit;
where visit in (1,2,3);
run;
%letter(lsmdata=lsmeans,diffdata=diffs,byvars=visit,alpha=0.05,outdata=outdata, trtvar=trt);
proc sort data=d8; by visit trt; proc print data=d8; id visit; run;


proc sort data=d8; by visit descending lsmean ; proc print data=d8; id visit; run;



* this macro still has problem with all groups are not different.

**********************************;
run;
/********
%let lsmdata=lsmeans;
%let diffdata=diffs;
%let byvars=visit;
%let alpha=0.05;
%let outdata=outdata;
%let trtvar=trt;
 %letter(lsmdata=lsmeans,diffdata=diffs,byvars=visit,alpha=0.05,outdata=outdata, trtvar=trt);
*******/

 %macro letter(lsmdata=lsmeans,diffdata=diffs,byvars=attrib,alpha=0.05,outdata=outdata, trtvar=prd);
proc sql;
create table diffs1 as 
select diffs.*, put(estimate,5.1)||" ("||put(probt,5.3)||')' as diff, sum((probt>=0)) as count
from diffs
group by &byvars, &trtvar
order by &byvars, &trtvar, _&trtvar
;

proc transpose data=diffs1 out=diffs2;
var diff;
by &byvars &trtvar count;
ID _&trtvar ;
run;

data lsmeans_diffs(drop=effect  df tvalue probt _name_ rename=(estimate=lsmean));
 merge lsmeans(in=a) diffs2;
 by &byvars &trtvar;
 if a;
 run;  

 proc sort data=lsmeans_diffs;
 by &byvars descending count &trtvar;
run; 

proc print data=lsmeans_diffs; Title "Pairwise Comparisons Among &trtvar"; 
by &byvars;
id &byvars;
run;
*************;


data d1(drop=effect  stderr df tvalue temp rename=(estimate=diffs));
 set diffs diffs(in=a);
 if a then do;
  temp=&trtvar;
  &trtvar=_&trtvar;
  _&trtvar=temp;
  estimate=-estimate;
  end;
  proc print data=d1; run;
  proc sql;
   create table d2 as
   select a.*, b.estimate as lsmean
    from d1 as a left join lsmeans as b
	on a.&byvars=b.&byvars and a.&trtvar=b.&trtvar
	;
   create table d3 as
   select a.*, b.estimate as _lsmean
    from d2 as a left join lsmeans as b
	on a.&byvars=b.&byvars and a._&trtvar=b.&trtvar
	order by &byvars, lsmean desc, _lsmean desc
	;
	proc print data=d3; run;

	data d4;
	 set d3(where=( probt>&alpha and diffs>0));
	  by  &byvars descending lsmean descending _lsmean ;
	  retain grouping 1;
	  if first.&byvars then grouping=1;  
	  else if first.lsmean then grouping+1;
	  run;

	  proc print data=d4; run;

data d5(keep=&byvars &trtvar grouping);
 set d4 d4(in=a ) ;
 if a then &trtvar=_&trtvar;
run;
proc print data=d5; run;

proc sort data=d5  ;
 by &byvars &trtvar grouping;
 run;
proc transpose data=d5 out=d6;
 by &byvars &trtvar;
 var grouping;
 proc print; run;

data junk;
 array c {*} col1-col26;

data d6(drop=col: where=(&trtvar^="")); set d6 junk;
 letter=compress(COL1||col2||col3||col4||col5||col6||col7||col8||col9||col10||COL11||col12||col13||col14||col15||col16||col17||col18||col19||col20||COL21||col22||col23||col24||col25||col26);
letter =compress(letter,'.');
proc print; run;

proc sql;
 create table d7 as
 select a.*, b.letter
 from lsmeans_diffs as a left join d6 as b
 on a.&byvars=b.&byvars and a.&trtvar=b.&trtvar
order by a.&byvars, letter desc, lsmean desc, a.&trtvar 
 ;;
proc print; run;


 data d8(drop=count letter);
  set d7;
  by &byvars;
  retain cletter;
	  if  first.&byvars and letter="" then cletter=1;
      else if letter^="" then cletter=1*letter;  
	  else  cletter+1;
run;
proc print; run;
  

%mend;


