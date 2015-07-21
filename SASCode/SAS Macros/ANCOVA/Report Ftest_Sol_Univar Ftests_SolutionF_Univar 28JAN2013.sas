
/*
%let xlsheetname=wk16_GrpCmprOut;
%let printdata=wk16_GrpCmprOut;
%let byVar=Transform MeasureGroup measure;
%let TrtVar=TrtLabel6;
%let row_height=40;
%let comptable=trtcomps;
*/

%macro Report_Ftest_Sol_Univar(xlsheetname=,printdata=,byVar=,row_height=30);

options mlogic symbolgen;
%let byVar=%qcmpres(%upcase(&byVar));
%let nbyVars=%eval(%sysfunc(countc(&byVar,' '))+1);
proc sort data=&printdata;
 by &byVar;
 run;
proc contents data=&printdata out=conts(keep=name label varnum) varnum noprint;
run;
proc sort data=conts;
by varnum;
run;
data conts;
set conts;
byvar=symget('byvar');
if index(byvar,left(trim(upcase(name))))=0 then notbyvar=1;
run;

*get names of variables that are not byvars and do not have probabilities;
proc sql noprint;
select name ,count(name)into: notbvar separated by ' ', :nnotbvar
from conts
where notbyvar=1 & scan(upcase(name),1,'_')^='PROB';
quit;

*get names of variables that have probabilities so they can be highlighted;
proc sql noprint;
select name ,label,count(name)into: probvars separated by ' ', :problabs separated by '*', :nprobvars
from conts
where scan(upcase(name),1,'_')='PROB';
quit;

%put &notbvar;
%put &probvars;

proc format;
  value FlagFmt  0='White'
  				 1	='Yellow'
				 2	='Rose'
	;
run;
quit;
data &printdata.2; 
set &printdata; 
%do i=1 %to &nprobvars;
flg_prob&i=0;
%let probvar&i=%scan(&probvars,&i,%str( ));
%let problab&i=%scan(&problabs,&i,%str(*));
probv&i=&&probvar&i;
  if 0 < abs(&&probvar&i.) <= 0.05 then flg_prob&i=2;
  else if 0.05 < abs(&&probvar&i.) <= 0.10 then flg_prob&i=1;
  else flg_prob&i=0;
label probv&i="&&problab&i";
%end;
run;

ods listing close;
ods tagsets.excelxp options(sheet_name="&xlsheetname"
row_heights="&row_height"
/*default_column_width='25,8,25,8' */
frozen_headers='yes' frozen_RowHeaders='2' Zoom='80') ;
proc report data=&printdata.2 nowd  split='*' spacing=1 headline missing;
column &byVar &notbvar %do i=1 %to &nprobvars; probv&i %end;;
column  %do i=1 %to &nprobvars; flg_prob&i %end;;
column dummy;
%if %length(&byvar)>0 %then
  %do i=1 %to &nbyVars;
  %let byvar&i=%scan(&byVar,&i,%str( ));
   define &&byvar&i / order=data left flow style(column)=[width=150];
%end;
%if %length(&notbvar)>0 %then
  %do i=1 %to &nnotbvar;
  %let notbvar&i=%scan(&notbvar,&i,%str( ));
   define &&notbvar&i / order=data  center flow style(column)=[width=150];
%end;

%do i=1 %to &nprobvars;
define probv&i / display order=data center format=pvalue6.4  style(column)=[width=150];
%end;

/*define flag(s) but keep hidden*/
%do i=1 %to &nprobvars;
define flg_prob&i / display noprint;
%end;

/*define a dummy variable to use for the compute statement*/
define dummy / computed noprint;
compute dummy;
%do i=1 %to &nprobvars;
   if flg_prob&i gt 0 then do;
    call define("probv&i",'style','style=[background=' ||put(flg_prob&i,FlagFmt.) || ']');
   end;
%end;
 endcomp;
run;
quit;
ods listing;
options nomlogic nosymbolgen;
%mend Report_Ftest_Sol_Univar;
