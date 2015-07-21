options ls=150 ps=54;
ods html  close;
ods listing;


libname in "Q:\beauty_care\clinical\Biometrics\XiaojieZhou\2013\BodyWash\Meta-analysis\Yasser\Olay Body Wash\Data";

*******Read in dataset************;
proc contents data= in.combined varnum;
run;
proc print data= in.combined(obs=20); run;

proc freq data= in.combined;
table pno*trt*trtdesc/list;
tables pno*Measure*evalvisit*visitlabel*rep/list;
run;


data  CRB1305070 CRB0609079;
 set in.combined;
 if measure ^="Corn";
 if pno="1305070" then output CRB1305070;
 else if pno="0609079" then output CRB0609079;
 run;


*---- Baseline ----*;
%macro anal(pno=);
	proc glimmix data=CRB&pno noitprint noclprint;
		where Evalvisit in (1) ;
		by pno evalvisit measure;
		class  trt archiveID  side site pno ;
		model value = trt side site side*site;*/residual;
		Random ArchiveID ;
		lsmeans trt/ pdiff ;
        ods output lsmeans=BL_lsmeans_&pno diffs=BL_diffs_&pno;
	run;
	proc glimmix data=CRB&pno noitprint noclprint;
		where Evalvisit in (2) ;
		by pno evalvisit measure;
		class  trt archiveID  side site pno ;
		model value = trt side site side*site basevalue;
		Random ArchiveID ;
		lsmeans trt/ diffs ;
        ods output lsmeans=D5_lsmeans_&pno diffs=D5_diffs_&pno;
	run;
%mend;
%anal(pno=1305070);
%anal(pno=0609079);

*------- Adding Grouping Letter ----------*;
%letter(lsmdata=BL_lsmeans_1305070,diffdata=BL_diffs_1305070,byvars=measure,alpha=0.05,outdata=outdata, trtvar=trt);
proc sort data=outdata; by measure   lsmean ; proc print data=outdata(drop=B C D E F G H I); run;

%letter(lsmdata=D5_lsmeans_1305070,diffdata=D5_diffs_1305070,byvars=measure,alpha=0.05,outdata=outdata, trtvar=trt);
proc sort data=outdata; by measure lsmean ; proc print data=outdata(drop=B c d e f g h ); run;

%letter(lsmdata=BL_lsmeans_0609079,diffdata=BL_diffs_0609079,byvars=measure,alpha=0.1,outdata=outdata, trtvar=trt);
proc sort data=outdata; by measure   lsmean ; proc print data=outdata; run;

%letter(lsmdata=D5_lsmeans_0609079,diffdata=D5_diffs_0609079,byvars=measure,alpha=0.1,outdata=outdata, trtvar=trt);
proc sort data=outdata; by measure lsmean ; proc print data=outdata(drop=B c d e f g h ); run;



**********************************;

**********************************;
run;
/********
 %let lsmdata=D5_lsmeans_1305070;
 %let diffdata=D5_diffs_1305070;
 %let byvars=measure;
 %let alpha=0.05;
 %let trtvar=trt;
 %let outdata=outdata;
 %letter(lsmdata=lsmeans,diffdata=diffs,byvars=measure,alpha=0.05, outdata=, trtvar=trt);
*******/
run;
%macro letter(lsmdata= ,diffdata= ,byvars= ,alpha= , outdata=, trtvar=);
proc sql;
create table diffs1 as 
select a.*, put(estimate,5.1)||" ("||put(probt,5.3)||')' as diff, sum((probt>=0)) as count
from &diffdata as a
group by &byvars, &trtvar
order by &byvars, &trtvar, _&trtvar
;
proc print; run;
proc transpose data=diffs1 out=diffs2;
var diff;
by &byvars &trtvar count;
ID _&trtvar ;
run;

data lsmeans_diffs(drop=effect  df tvalue probt _name_ rename=(estimate=lsmean));
 merge &lsmdata(in=a) diffs2;
 by &byvars &trtvar;
 if a;
 run;  

 proc sort data=lsmeans_diffs;
 by &byvars descending count &trtvar;
run; 


 proc sort data=lsmeans_diffs;
 by &byvars  lsmean &trtvar;
run; 

proc print data=lsmeans_diffs; Title "Pairwise Comparisons Among &trtvar"; 
by &byvars;
id &byvars;
run;
*************;


data d1(drop=effect  stderr df tvalue temp rename=(estimate=diffs));
 set &diffdata &diffdata(in=a);
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
    from d1 as a left join &lsmdata as b
	on a.&byvars=b.&byvars and a.&trtvar=b.&trtvar
	;
   create table d3 as
   select a.*, b.estimate as _lsmean
    from d2 as a left join &lsmdata as b
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

data d5(keep=&byvars &trtvar grouping lsmean);
 set d4 d4(in=a ) ;
 if a then do; &trtvar=_&trtvar; lsmean=_lsmean; end;
run;
proc print data=d5; run;

proc sort data=d5  out=j1 nodupkey;
 by &byvars grouping lsmean &trtvar ;
proc sort data=j1 ;
 by &byvars grouping &trtvar ;
 proc print; run;
 run;

 **************;
proc transpose data=j1 out=j2 prefix=trt;
 by &byvars grouping;
 var &trtvar;
 proc print; run;

 data jj3;
  set j2;
  format trt1-trt26 $32.;
  trtcomb=compress(trt1||trt2||trt3||trt4||trt5||trt6||trt7||trt8||trt9||trt10||trt11||trt12||trt13||trt14||trt15||trt16||trt17||trt18||trt19||trt20||trt21||trt22||trt23||trt24||trt25||trt26);
  proc print; run;

  proc transpose data=jj3 out=jj4 prefix=grouping; 
  by &byvars;
  var trtcomb;
  id grouping;
  proc print; run;


data jj5; set jj4;
format grouping1-grouping26 $32.;
 array g {*} $ grouping1-grouping26 ;
 do i=1 to 25;
   do j=i+1 to 26;
   if g[i]^="" and g[j]^="" then 
     do;
	     if compress(g[i],g[j])="" then g[i]="";
	     else if compress(g[j],g[i])="" then g[j]="";
	 end;
   end;
 end;
 run;
 proc print;run;

proc transpose data=jj5 out=jj6(where=(trtcomb^=""));
 by &byvars;
 var group:;
 run;
 proc print; run;

 proc sql;
  create table jj7 as 
  select a.*
  from jj3 as a right join jj6 as b
  on a.&byvars=b.&byvars and a.trtcomb=b.trtcomb
  order by &byvars, grouping;
  proc print; run;

 data jj8;
  set jj7(rename=(grouping=grouping_old));
  by &byvars;
  retain grouping;
  if first.&byvars then grouping=1;
  else grouping+1;
  proc print; run;


 ***************;
/******* To be deleted **********

 data jj3;
  set j2;
  by &byvars;
  retain temp1;
  if first.&byvars then temp1=trt1;
  else if trt1^=temp1 then temp1=trt1;  else delete=1;
proc print; run;

data j3(keep=&byvars  trt: letter grp grouping);
   set j2;
   by &byvars;
   retain grp;
   if first.&byvars then grp=1;
   else grp+1;
   letter=COLLATE(grp+96, grp+96);
  run;
 proc print; run;
***********/
data j3(keep=&byvars  trt: letter grouping);
   set jj8;
   by &byvars;
   letter=Byte(grouping+96);
  run;
proc print data=j3; run;

proc sort data=j3;  by &byvars letter;
proc transpose data=j3(drop=trtcomb) out=j4(rename=(Col1=&trtvar) where=(&trtvar^=""));
 by &byvars letter;
 var trt1-trt26;
 run;
proc sort data=j4(drop=_name_);
 by &byvars &trtvar;
 proc print data=j4; run;

proc transpose data=j4 out=j5 ;
 by &byvars &trtvar;
 var letter;
proc print data=j5; run;


***************;
 

proc sort data=lsmeans_diffs out=k1(keep=&byvars   lsmean &trtvar);
 by &byvars &trtvar;
run;
proc print; run;

proc sort data=j5;
 by  &byvars &trtvar;
run;


data k2;
 merge k1(in=a) j5;
 by &byvars &trtvar;
 if a;
 proc sort data=k2; by &byvars descending lsmean;
 proc print data=k2; run;

 data junk;
  length col1-col26 $8;

data k3(where=(&trtvar^=""));
 set k2 junk;
 run;
proc print; run;



 data k4;
  set k3(where=(&trtvar^=""));
    by &byvars descending lsmean;
	retain add1 ;

	if  col1="" and first.&byvars then add1=1;
	else if col1="" and ^first.&byvars then add1+1;
	else if col1^="" and first.&byvars then add1=0;
	junk=first.&byvars;
proc print; run;

data k5(drop=i);
 set k4;
    by &byvars descending lsmean;
	retain jjjunk;
   if col1="" and first.&byvars then jjunk=byte(rank('a')-1+add1);
   else if col1^="" then jjunk=byte(rank(col1)+add1);
   if jjunk^="" then jjjunk=jjunk;
   else jjjunk=byte(rank(jjjunk)+1);
   col1=jjjunk;
   array c {*} $ col2-col26;
	 do i=1 to 25;
	 if c[i]^="" then c[i]=byte(rank(c[i])+add1);
	 end;
   run;
proc print; run;

 ****************;

data d6(drop=col: add1 where=(&trtvar^=""));
 set k5;
 letter=compress(COL1||col2||col3||col4||col5||col6||col7||col8||col9||col10||COL11||col12||col13||col14||col15||col16||col17||col18||col19||col20||COL21||col22||col23||col24||col25||col26);
run;
proc sort data=d6;
by &byvars lsmean;
proc print; run;

****************************;

proc sql;
 create table d7(drop=count) as
 select a.*, b.letter
 from lsmeans_diffs as a left join d6 as b
 on a.&byvars=b.&byvars and a.&trtvar=b.&trtvar
order by a.&byvars, letter desc, lsmean desc, a.&trtvar 
 ;;
proc print; run;

data d8; set d7;
if substr(letter,1,1)^='a' then letter=(' '||letter);
if substr(letter,2,1)^='b' and length(letter)>=2 then letter=(' '||letter);
if substr(letter,3,1)^='c' and length(letter)>=3 then letter=(' '||letter);
if substr(letter,4,1)^='d' and length(letter)>=4 then letter=(' '||letter);
if substr(letter,5,1)^='e' and length(letter)>=5 then letter=(' '||letter);
proc print; run;
run;

proc sort data=d8;
by &byvars   lsmean &trtvar ;
run;
proc print data=d8; run;

data &outdata;
 set d8;
 run;
%mend;
run;
