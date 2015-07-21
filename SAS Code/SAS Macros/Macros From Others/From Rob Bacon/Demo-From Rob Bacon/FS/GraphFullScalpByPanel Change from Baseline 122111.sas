ods trace on;
options mprint mlogic symbolgen notes;

%macro graphfullscalpbypanel
	(vargraph=,changefrombaseline=,xlabel1=, ylabel1=);

data grouping_dsn;
	set &vargraph;
	if studyday = 1 then delete; *deleting out baseline data;
	trt2= put(trta, trts.);

	lowstderr = estimate - stderr;
	highstderr = estimate + stderr;
run;

proc summary data=grouping_dsn;
	by effect;
	var lowstderr;
	output out=LSEstat min=Minimum;
run;

data grouping_dsn;
	merge grouping_dsn LSEstat;
	by effect;
	group = minimum + (.10*minimum);
run;

proc sql;
	create table trtct as
	select	unique(trta)
	from	grouping_dsn;
quit;

%let dsid=%sysfunc(open(trtct,i));
%let trtct=%sysfunc(attrn(&dsid,nlobs)); 
%let rc=%sysfunc(close(&dsid));

data _null_;
	set grouping_dsn;
	%do i = 1 %to &trtct; 
		if _N_ = &i then do;
			call symput ("trt2&i", trim(trt2));
		end;
	%end;
	;
run;

proc sort data=grouping_dsn;
	by trt;
run;

proc sql;
	create table vstct as
	select	unique(studyday)
	from	grouping_dsn;
quit;

%let dsid=%sysfunc(open(vstct,i));
%let vstct=%sysfunc(attrn(&dsid,nlobs)); 
%let rc=%sysfunc(close(&dsid));

proc template;
  define statgraph barchart1;
    begingraph;
	entrytitle "&title";
    entrytitle "&changefrombaseline";
	%do i = 1 %to &trtct;
		entryfootnote textattrs=(size=11pt) halign=left "&&trt2&i"; *x-axis names and font size of legend;
	%end;
    layout gridded / border=false;
		layout	datapanel classvars=(&SortVar) / columns=&vstct
				columnaxisopts=(label="&xlabel1")
				rowaxisopts=(label="&ylabel1");
        layout	prototype / walldisplay=(fill);
          barchart	x=trta y=estimate / group=&classvar name='a' barlabel=true  
				outlineattrs=(color=black);
			*	 barchart	x=trta y=estimate / group=&classvar name='a' barlabel=true skin=satin 
				outlineattrs=(color=black);
          scatterplot x=trta y=estimate / yerrorlower=lowstderr  yerrorupper=highstderr
					markerattrs=(size=0) errorbarattrs=(thickness=1) datatransparency=0.1;
		  scatterplot x=trta y=group / markercharacter=grouping markercharacterattrs=(size=11pt); *font size of grouping letters;
        endlayout;
      	endlayout;
      entry ' ';
     * discretelegend 'a' /title='treatments' ;
    endlayout;
  endgraph;
end;
run;

proc sgrender data=grouping_dsn template=barchart1;
	format estimate 5.2;
run;

%mend graphfullscalpbypanel;
