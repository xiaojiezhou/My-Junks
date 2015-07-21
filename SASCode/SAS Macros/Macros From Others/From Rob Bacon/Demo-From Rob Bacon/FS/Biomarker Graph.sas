%macro graphBiomarkerbypanel
	(vargraph1=,vargraph2=,changefrombaseline=,xlabel1=, ylabel1=);

proc sort data=&vargraph1. out=tempA;
	by &Sortvar. &Classvar.a;
run;

proc sort data=&vargraph2. out=tempB; 
	by &Sortvar. &Classvar.;
run;
	    
data tempA;
    merge tempA (in=i) tempB (in=j rename=(&Classvar.=&Classvar.a)) ;
	by &Sortvar. &Classvar.a;
	if i=1;
	if Estimate=. then Estimate=0;
run;

proc sort data=tempA;
	by effect;
run;

data grouping_dsn;
	set tempA;
	if studyday = 1 then delete; *deleting out baseline data;

	lowstderr = estimate - stderr;
	highstderr = estimate + stderr;
run;

data grouping_dsn;
	set grouping_dsn;
		cfb1 	=	(10**(estimate) - 1)*100;
		cmsefb1	=	(10**(estimate-stderr)-1)*100;
		cpsefb1	=	(10**(estimate+stderr)-1)*100;

		grouploc=5;
run;



proc template;
  define statgraph EyeIrritation;
    begingraph;
	*entrytitle "&title";
    entrytitle "&changefrombaseline";
      layout gridded / border=false;
      layout datalattice columnvar=studyday / headerlabeldisplay=value cellwidthmin=50
             columnheaders=bottom border=false columndatarange=union
             columnaxisopts=(display=(line tickvalues))
             rowaxisopts=(offsetmin=0 linearopts=(viewmin=-100 viewmax=10 tickvaluepriority=true)
             label='% Reduction' griddisplay=on);
        layout prototype / walldisplay=(fill);
          barchart x=trta y=cfb1 / group=trt name='a' barlabel=true skin=modern
                                   outlineattrs=(color=black);
          scatterplot x=trta y=cfb1 / yerrorlower=cmsefb1 yerrorupper=cpsefb1 markerattrs=(size=0)
                                      errorbarattrs=(thickness=1) datatransparency=0.6;
		  scatterplot x=trta y=grouploc/markercharacter=grouping;
        endlayout;
      endlayout;
      entry ' ';
      discretelegend 'a' / title='Treatment Group: '  border=true ;
    endlayout;
  endgraph;
end;
run;


proc sgrender data=grouping_dsn template=EyeIrritation;
   format cfb1 5.1;
   format trt $trtnum.;
   format studyday studyday.;
   *Label LogHistamineNrmRep1 = 'Histamine';
run;

%mend graphBiomarkerbypanel;
