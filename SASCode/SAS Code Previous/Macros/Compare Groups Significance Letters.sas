**************************************************************;

%let indata=diffs;
%let trtcols= TrtLabel6   _TrtLabel6;
%let byvars= measure;
%let alpha1=0.2,alpha2=0.50;
%let outdata=letter;
%macro sigletters(indata=,trtcols= , byvars=, alpha1=0.05,alpha2=0.10,outdata=);
* Get the 2 treatment columns;
%let trtcols=%qcmpres(&trtcols);
%let col1=%scan(&trtcols,1,%str( ));
%let col2=%scan(&trtcols,2,%str( ));

* Get the number of by variables and assign each one to a macro variable;
* then get the unique levels for each by variable;
%let byvars=%qcmpres(&byvars);
%let nbyvars=%eval(%sysfunc(countc(%qcmpres(&byvars),' '))+1);
proc sort data=&indata out=byvars(keep=&byvars) nodupkey;
by &byvars;
run;
data byvars;
set byvars nobs=nblvls;
id=_n_;
if  nblvls then call symput ("nblvls",left(trim(_n_)));
run;
%put *** Number of Treatments= &nblvls ***;

***************;
%do l=1 %to &nblvls;
	%let subset=if;
	%do b=1 %to &nbyvars;
		%let byvar&b=%scan(&byvars,&b,%str( ));
		data _null_;
		set byvars;
		tp_&&byvar&b=vtype(&&byvar&b);
		if tp_&&byvar&b='N' then do;
		if _n_=&l then call symput("subs&b",&&byvar&b);
		end;
		if tp_&&byvar&b='C' then do;
		if _n_=&l then call symput("subs&b",quote(&&byvar&b));
		end;
		run;
	    %put &&subs&b;
		%if &b=&nbyvars %then %let subset=&subset &&byvar&b.=&&subs&b %str(;);
		%else %let subset=&subset &&byvar&b.=&&subs&b %str(&) ;
	%end;
	data &indata.&l;
	set &indata;
	&subset;
	absdiff=abs(estimate);
	run;
	proc sort data=&indata.&l;
		by &byvars  descending absdiff ;
		run;
		data trts;
		set &indata.&l;
		grps=&col1 ;output;
		grps=&col2 ;output;
		keep grps;
		run;
		proc sort data=trts nodupkey;
		by grps;
		run;
		data _null_;
		set trts nobs=nltr;
		if  nltr then call symput ("nltr",left(trim(_n_)));
		run;
		%put *** Number of Treatments= &nltr ***;

		data trts;
		length ngrp $4;
		set trts nobs=nltr;
		if &nltr <=26 then ngrp=byte(_n_+64);
		else ngrp='A'||left(trim(_n_));
		run;
		data compare (drop=&col1 &col2);
		set &indata.&l;
		numcomp=_n_;
		grp1=&col1 ;
		grp2=&col2;
		run;
		** Merge compared info for group 1;
		proc sort data=trts;
		by grps; 
		run;
		proc sort data=compare;
		by grp1;
		run;
		data compare;
		length grp1 $60;
		merge compare(in=a) trts(rename=(grps=grp1 ngrp=first) keep=grps ngrp ) ;
		by grp1;
		if a;
		run;
		** Merge compared info for group 2;
		proc sort data=compare;
		by grp2;
		run;
		data compare;
		length grp2 $60;
		merge compare(in=a) trts(rename=(grps=grp2 ngrp=second) keep=grps ngrp ) ;
		by grp2;
		if a;
		drop absdiff;
		run;
		proc sort data=compare;
		by numcomp;
		run;
	
	
		data compare(keep= comin comshowb comshows);
		length comshowb comshows $9 comin $1 ;
			set compare;
			by numcomp;
			if (probt > &alpha1) & (probt <= %sysevalf(&alpha2)) then
				do;
					if (estimate > 0) then
						do;
							comshows=lowcase(second); 
							comin=first; 
						end;
					else if (estimate < 0) then
						do;
							comshows=lowcase(first); 
							comin=second; 
						end;
				end;
			 if (probt <= &alpha1) then
				do;
					if (estimate > 0) then
						do;
							comshowb=second; 
							comshows=lowcase(second); 
							comin=first; 
						end;
					else if (estimate < 0) then
						do;
							comshowb=first; 
							comshows=lowcase(first); 
							comin=second; 
						end;
				end;
			if comin=" " then delete; 
		run;
	
		*make letters go across**;
		proc sort data=compare; 
			by comin;
		run;
	
		*create letters for each case and merge;
		%macro lettercase(case);
		proc transpose data=compare out=compare&case(drop=_NAME_); 
			by  comin ;
			var comshow&case ;
		run;
	
		 **count number of columns with significance letters and create a macro variable for it;
		proc contents data=compare&case out=sigcontents noprint; 
		run;
		proc sql noprint;
		select count(name) into: colnum
			from sigcontents 
			where name ne 'comin';
		quit;
	
		 data compare&case(keep= comin  showletter&case);
		  length showletter&case $25;
			set compare&case; 
		    %if &colnum=0 %then %do; showletter&case=" "; %end;
			%if &colnum=1 %then %do; showletter&case=compress(col1||" "); %end;
			%if &colnum>1 %then %do;
		      showletter&case=compress(col1||%do k=2 %to %eval(&colnum-1);col&k||%end;col%trim(%left(&colnum))); 
		    %end;
		run;
		%mend lettercase;
		%lettercase(b);
		%lettercase(s);
	
		data compare;
		merge compareb compares;
		 by comin;
		 run;
	
		**merge original treatment labels and transpose dataset so comparisons go across**;
		 proc sort data=trts;
		by ngrp;
		run;
		proc sort data=compare; 
			by comin ; 
		run; 
		data trts;
		merge trts(in=a) compare(rename=(comin=ngrp)keep= comin Showletterb showletters);
		by ngrp;
		if a;
		label showletterb = "%sysevalf(&alpha1*100)% Significantly greater than"
			  showletters = "%sysevalf(&alpha2*100)% Significantly greater than";
		run;
		proc sql;
		create table trts as 
		select b.*,a.grps as trt "&col1",a.showletterb,a.showletters
		from trts a, byvars b
		where b.id=&l;
		quit;
		proc append base=allcomps data=trts force  ;
		run;
	%end;

	data &outdata; set allcomps; SignLevel1=&alpha1; SignLevel2=&alpha2; if id ^=.; run;


%mend sigletters;
**************************************************************;
/*
%sigletters(indata=diffs,trtcols= trt   _trt, byvars= evalvisit  measure, alpha1=0.05,alpha2=0.10,path=Q:\Xiaojie\Surf and Turf\SAS macro Signficance letters);
*/

