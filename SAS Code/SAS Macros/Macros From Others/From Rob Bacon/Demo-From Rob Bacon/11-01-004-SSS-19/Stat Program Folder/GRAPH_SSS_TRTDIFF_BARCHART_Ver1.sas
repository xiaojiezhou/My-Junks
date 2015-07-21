/****************************************************************************************************************************
	Name:		GRAPH_SSS_TRTDIFF_BARCHART						  			   									                   
	Dated:		4-29-10 Version 1	
	
 Macro-REPORT_SSS_TRTDIFF creates a report for difference in the Treatment levels.  

 	Inputs: 
			GraphDS			:Input dataset for generating graph
			
 	Outputs:	
  		    The Macro creates the report.             
*****************************************************************************************************************************/
	
*options mlogic mprint source symbolgen source2 ;

%macro GRAPH_SSS_TRTDIFF_BARCHART(graphds=);

data Diffs_Diffvar;
	set &graphds;
	call symput("Classtype",vtype(&CLASSVAR));
run;

%let classformat=&classvar;

*This datastep merges treatments to form trt diff variable;
data diffs_diffvar;
	set diffs_diffvar;
	trtnew = trt||"-"||_trt;
	treatment2= cats(put(&classvar, &classformat..),'-',put(_&classvar, &classformat..));
	treatment = trtnew||' = '||treatment2;
	ucl = estimate + stderr;
	lcl = estimate - stderr;
run;

*This counts the number of records in diffs_diffvar;
%let dsid=%sysfunc(open(diffs_diffvar,i));
%let numobs=%sysfunc(attrn(&dsid,nlobs)); 
%let rc=%sysfunc(close(&dsid));

%put &numobs;

%macro trtmaccode;
data _null_;
	set diffs_diffvar;
	%do i = 1 %to &numobs; 
	*the count from diffs_diffvar is used for creating the x-axis labels;
		if _N_ = &i then do;
			call symput ("treatment&i", trim(treatment));
			*This creates the name that will be used in the x-axis;
		end;
	%end;
	;
run;

*creating the graph template.  defines overlay and x&y axes;
proc template;
  define statgraph barchart;
    begingraph;
	entrytitle "&title.";
    entrytitle 'Difference in Change from Baseline';
	entrytitle 'Positive Differences Favors 2nd Treatment';
	%do i = 1 %to &numobs;
		entryfootnote textattrs=(size=8pt) halign=left "&&treatment&i"; *x-axis names;
	%end;
    layout gridded / border=false;
      layout datalattice columnvar=group / headerlabeldisplay=value /*cellwidthmin=10*/
             columnheaders=bottom border=false columndatarange=union
             columnaxisopts=(display=(line tickvalues))
             rowaxisopts=(
				label='Mean ± Standard Error'
				griddisplay=on);
        layout prototype / walldisplay=(fill);
          barchart x=trtnew y=estimate / group=group name='a' barlabel=true /*skin=*/ 
						outlineattrs=(color=black);
          scatterplot x=trtnew y=estimate / yerrorlower=lcl yerrorupper=ucl markerattrs=(size=0)
                        errorbarattrs=(thickness=1) datatransparency=0.3;
        endlayout;
      endlayout;
      entry ' ';
      discretelegend 'a' / title='Treatment Difference (Trt1 - Trt2)'  border=true ;
    endlayout;
  endgraph;
end;
run;

*ods statement with page settings and output;
ods listing close;
ods html /*style=styles.blue*/ image_dpi=100 file='barchart.html' path="&foutput\.";*path="&ddata\.";
ods graphics / reset noborder width=600px height=600px
               imagename='barchart' imagefmt=png noscale;

*this code below produces the graph;
proc sgrender data=diffs_diffvar template=barchart;
   format estimate 5.2;
run;

ods graphics off;
ods html close;
ods listing;

%mend;
%trtmaccode

%mend GRAPH_SSS_TRTDIFF_BARCHART;

