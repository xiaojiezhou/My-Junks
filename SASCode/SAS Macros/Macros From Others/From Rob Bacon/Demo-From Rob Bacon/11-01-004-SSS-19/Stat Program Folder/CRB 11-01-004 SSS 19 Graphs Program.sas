%Let StudyNo	=1101004;
%Let GraphDS	=CRB1101004_2b;
%Let DSDir		=C:\Documents and Settings\ti4224\My Documents\My Work\Crb\11-01-004-SSS-19\Stat Data Folder\;
%Let OutputFileName = CRB 11-01-004 Graphs.doc;

libname save "&DSDir";
options nodate nonumber;

*reorder the freq tables within the graphs and it should be done;
*Add in titles;
*add in a macro variable for the number of trt pairs and use that in the rows statment; 
*is it necessary to save the individual png files;

proc format;
   value $trt 
   		'A' = '[A] 0.03% ZPT'	
		'B' = '[B] 0.10% ZPT'
		'C' = '[C] 0.03% ZPT' 
		'D' = '[D] 0.03% ZPT + 0.06% ZC'
 		'E' = '[E]'
			;
  run;			 

proc template;
    define style temp;
        parent=styles.default; 
        style GraphBackground / 
            backgroundcolor=white;
        replace GraphFonts from GraphFonts /
            'GraphDataFont' = ("Arial",12pt)
            'GraphValueFont' = ("Arial",12pt)
            'GraphLabelFont' = ("Arial",12pt)
            'GraphFootnoteFont' = ("Arial",12pt)
            'GraphTitleFont' = ("Arial/bold",12pt);
    end;
run;

ods listing gpath="&DSDir" image_dpi=200 style=temp;

ods rtf file ="&DSDir&OutputFileName";
ods graphics off;

ods noproctitle;

/*
proc freq data=save.&GraphDS;
 	where visit=0;
	tables ASFS / nocum;
run;

proc freq data=save.&GraphDS;
	where visit=30240;
	tables ASFS*trt / nocum norow nocol nopercent;
	format trt $trt.;
run;

proc freq data=save.&GraphDS;
	where visit=30240;
	tables DiffASFS*trt / nocum norow nocol nopercent;
	format trt $trt.;
run;
*/
*ods graphics on / reset=all border=off imagefmt=PNG noscale
                  width=6in height=4in imagename="Histogram";
/*
proc sgplot data=save.&GraphDS;
	where visit=0;
	vbar ASFS / stat=freq;
	xaxis label='Baseline ASFS';
run;
*/

				  /*
proc sgpanel data=save.&GraphDS;
	where visit=0;
	format trt $trt.;
	panelby trt / columns=2 rows=3;;
	vbar ASFS / stat=freq;
	colaxis label='Baseline ASFS';
run;
				  */
/*
proc sgplot data=save.&GraphDS;
	where visit=0;
	histogram ASFS / showbins scale=count;
	density ASFS;
	xaxis label='Baseline ASFS';
run;
*/
*ods graphics off;
/*
proc sgpanel data=save.&GraphDS;
	where visit=30240;
	format trt $trt.;
	panelby trt / columns=2 rows=3;;
	vbar ASFS / stat=freq;
	colaxis label='Week 3 ASFS';
run;

proc sgpanel data=save.&GraphDS;
	where visit=30240;
	format trt $trt.;
	panelby trt  / columns=2 rows=3;
	vbar DiffASFS / stat=freq;
	colaxis label='Change from Baseline';
run;
*/
/*
proc sgpanel data=save.&GraphDS;
	where visit=30240;
	format trt $trt.;
	panelby trt  / columns=2 rows=3;
	histogram DiffASFS / scale=count;
	density DiffASFS;
	colaxis label='Change from Baseline';
run;
*/

/*
proc sgpanel data=save.&GraphDS;
	where visit=30240;
	format trt $trt.;
	panelby trt;
	histogram ASFS / scale=count;
	density ASFS;
run;
*/
ods graphics on / reset=all border=off imagefmt=PNG noscale
                  width=7in height=9in imagename="TrellisPlotBySubject";
ods listing gpath="&DSDir" image_dpi=200 style=temp;

proc sgpanel data=save.&GraphDS;
  title height=12pt 'CRB 11-01-004 SSS 19';
  *format trt $trt.;
  panelby RandNo / columns=4 rows=5;*  novarname;
  vline visitlabel / response=AsfsSideTotal group=trtlabel;* datalabel=trt;
  rowaxis label='ASFS';
  colaxis label='Visit';
run;

ods rtf close;
