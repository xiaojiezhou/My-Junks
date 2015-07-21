%macro graphfullscalpbypanel
	(vargraph=,changefrombaseline=,xlabel1=, ylabel1=);

data grouping_dsn;
	set &vargraph;
	if studyday = 1 then delete; *deleting out baseline data;

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
    layout gridded / border=false;
		layout	datapanel classvars=(&SortVar) / columns=&vstct
				columnaxisopts=(label="&xlabel1")
				rowaxisopts=(label="&ylabel1");
        layout	prototype / walldisplay=(fill);
          barchart	x=trta y=estimate / group=&classvar name='a' barlabel=true  
				outlineattrs=(color=black);
          scatterplot x=trta y=estimate / yerrorlower=lowstderr  yerrorupper=highstderr
					markerattrs=(size=0) errorbarattrs=(thickness=1) datatransparency=0.6;
		  scatterplot x=trta y=group / markercharacter=grouping markercharacterattrs=(size=11pt); *font size of grouping letters;
        endlayout;
      	endlayout;
      entry ' ';
      discretelegend 'a' /title='Treatments' ;
    endlayout;
  endgraph;
end;
run;

proc sgrender data=grouping_dsn template=barchart1;
	format estimate 5.2;
	format &classvar $trtnum.;
run;

%mend graphfullscalpbypanel;
