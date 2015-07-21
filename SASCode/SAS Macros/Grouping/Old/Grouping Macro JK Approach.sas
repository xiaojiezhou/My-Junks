
%let meansdata=lsmeans;
%let diffsdata=diffs;
%let sortvar=attrib;
%let alpha=0.05;
%let outdata=outdata;

%let trtvar=prd;

* %macro groupingJK(meansdata=,diffsdata=,sortvar=,outdata=meansgrouping,alpha=0.05);



*--- Assgn letter to each treatment group ---*;
proc sort data=&meansdata out=TrtCode nodupkey;
 by &trtvar;
 run;
data TrtCode(keep=&trtvar TrtCode);
 set TrtCode;
 rank=_n_+64;
 TrtCode=COLLATE(rank,rank);
 call symputx('trtcnt',_n_);
 run;

 %put *** &trtcnt ***;

*--- Replace treatment groups in lsmean and diffs datasets with TrtCode ---*;
proc sql;
 create table meansdata(drop=&trtvar rename=(TrtCode=&trtvar)) as
 select a.*, b.TrtCode 
 from &meansdata as a left join TrtCode as b
 on a.&trtvar=b.&trtvar;
 create table diffsdata as
 select a.*, b.TrtCode as TrtCode
 from &diffsdata as a  left join TrtCode as b
 on a.&trtvar=b.&trtvar;
 create table diffsdata(drop=&trtvar _&trtvar rename=(TrtCode=&trtvar _TrtCode=_&trtvar))  as
 select a.*, b.TrtCode as _TrtCode
 from diffsdata as a  left join TrtCode as b
 on a._&trtvar=b.&trtvar;
 run;
**********************;


***************Find # of trts;
proc sort data=&meansdata;
	by &sortvar;
run;

************TRT string;
proc transpose data=trtcode out=trtstring;
	var Trtcode;
run;
proc print ; run;
%macro m1;
data trtstring;
	set trtstring;
	string=catx(','
	%do i=1 %to &trtcnt;
	,col&i
	%end;
	);
	call symputx('trtstring',string,'g');
run;
%mend;
%m1;
%put ****** &trtstring *****;
***********************;

/*************Evalvisit string;
data eval;
	set &meansdata;
run;

proc sort data=eval nodupkey;
	by evalvisit;
run;

data _NULL_;
	set eval end=EOF;
	if EOF then do;
		call symputx('lastvis',_N_,'g');
		end;
run;

proc transpose data=eval out=evalstring;
	var evalvisit;
run;

data evalstring;
	set evalstring;
	%if &lastvis=1 %then %do;
		string=col1;
	%end;
	%else %do;
		string=catx(' '
		%do i=1 %to &lastvis;
		,col&i
		%end;
		);
	%end;
	call symputx('evalstring',string,'g');
run;
********************/***********;

data diffsopp;
	set diffsdata;
	temptrt=&TrtVar;
	temp_trt=_&TrtVar;
	drop &TrtVar _&TrtVar;
	rename temptrt=_&TrtVar temp_trt=&TrtVar;
run;
proc print ; run;
data all;
	set diffsdata diffsopp;
run;

data dummy;
	set meansdata;
	keep &TrtVar _&TrtVar probt &sortvar;
	probt=.;
	_&TrtVar=&TrtVar;
run;

data groupingall;
run;
proc print data =dummy; run;

****************%do visitcount=1 %to &lastvis;

*********** %let visit=%scan(&evalstring,&visitcount);

data estimatesort;
	set meansdata;
	keep &TrtVar estimate  &sortvar;
run;

proc sort data=estimatesort;
	by &sortvar estimate;
run;

data estimatesort;
	set estimatesort;
	n=_n_;
run;

proc transpose data=estimatesort out=sortstring;
	var &TrtVar;
	by &sortvar;
run;
proc print; run;

%macro m1;
data sortstring;
	set sortstring;
	string=catx(' '
	/*%do i=&trtcnt %to 1 %by -1;*/
	%do i=1 %to &trtcnt %by 1;
	,col&i
	%end;
	);
	call symputx('sortstring',string,'g');
	string=catx(','
	%do i=1 %to &trtcnt;
	,col&i
	%end;
	);
	call symputx('sortstringc',string,'g');
run;
%mend;
%m1;
%put ***&sortstring **********&sortstringc*********;

proc sort data=estimatesort;
	by &sortvar &TrtVar;
run;
proc print; run;

data visit;
	set all dummy;
	
	if probt LT &alpha then switch=1;
		else switch=0;
	if Effect='' then do;
		_&TrtVar=&TrtVar;
		switch=0;
		end;
run;

proc sort data=visit;
	by &sortvar &TrtVar _&TrtVar;
run;

proc transpose data=visit out=wide;
	by &sortvar &TrtVar;
	var switch;
	id _&TrtVar;
run;

data widesort;
	merge wide estimatesort;
	by &sortvar &TrtVar;
run;
proc sort data=widesort;
	by n;
run;
proc print; run;
data widesort;
	set widesort;
	string=cats(&sortstringc);
	if sum(&trtstring)=0 and _n_ NE 1 then delete;
	*drop trt _name_;
run;
%put ******&sortstringc*********&trtstring; 
proc sort data=widesort nodupkey;
	by &sortvar string;
run;

data lastrow;
	set widesortfinal end=EOF;
	if EOF then do;
		call symputx('lastrow',_N_,'g');
		end;
run;

proc sort data=wide&visit.sort;
	by n;
run;

%if &lastrow GT 2 %then %do;

data wide&visit.sort;
	set wide&visit.sort;
	lagstring=lag(string);
	lagn=lag(n);
	part1=substr(string,1,lagn);
	part2=substr(lagstring,lagn+1,&trtcnt-lagn);
	finalstring=cats(part1,part2);
	drop &sortstring &TrtVar n lagn lagstring string part1 part2 _name_ estimate;
run;

data wide&visit.sort;
	set wide&visit.sort;
	if _n_=1 then delete;
run;

%end;

%else %do;

data wide&visit.sort;
	set wide&visit.sort;
	finalstring=string;
	drop &sortstring &TrtVar n string _name_ estimate;
run;

******************* %end;

proc sort data=wide&visit.sort nodupkey;
	by finalstring;
run;


data wide&visit.sortfinal;
	set wide&visit.sort;
	%do q=1 %to &trtcnt;
	%scan(&sortstring,&q)=substr(finalstring,&q,1);
	%end;
	drop finalstring;
run;

data lastrow;
	set wide&visit.sortfinal end=EOF;
	if EOF then do;
		call symputx('lastrow',_N_,'g');
		end;
run;

proc transpose data=wide&visit.sortfinal out=long&visit;
	var &sortstring;
run;

data long&visit;
	set long&visit;
	rename _name_=&TrtVar;
run;

data long&visit;
	set long&visit;
	length grouping $50.;
	%do j=1 %to &lastrow;
	letter=byte(96+&j);
	if col&j=0 then c&j=letter;
	else c&j='  ';
	%end;
	%if &lastrow=1 %then %do;
		grouping=c1;
		%end;
	%else %do;
		grouping=cat(c1
		%do k=2 %to &lastrow;
			,c&k
			%end;
		);
		%end;
	evalvisit=&visit;
run;

data grouping&visit;
	length grouping $50.;
	set long&visit;
	keep &TrtVar grouping evalvisit;
run;

data groupingall;
	set groupingall grouping&visit;
	if &TrtVar='' then delete;
	run;


%end;

proc sort data=groupingall;
	by evalvisit &TrtVar;
run;

proc sort data=meansdata;
	by evalvisit &TrtVar;
run;

data &outdata;
	merge meansdata groupingall;
	by evalvisit &TrtVar;
run;


%mend;





%groupingJK(meansdata=lsmeans,diffsdata=diffs,sortvar=attrib,outdata=meansgrouping,alpha=0.05);
