%macro Report_Ftest_Sol_Univar(xlsheetname=,printdata=,byVar=,row_height=30);
%let byVar=%qcmpres(%upcase(&byVar));
%let nbyVars=%eval(%sysfunc(countc(&byVar,' '))+1);
proc contents data=&printdata out=conts(keep=name varnum) varnum noprint;
run;
proc sort data=conts;
by varnum;
run;
data conts;
set conts;
byvar=symget('byvar');
if index(byvar,left(trim(upcase(name))))=0 then notbyvar=1;
run;
proc sql noprint;
select name ,count(name)into: notbvar separated by ' ', :nnotbvar
from conts
where notbyvar=1;
quit;
%put &notbvar;
ods listing close;
ods tagsets.excelxp options(sheet_name="&xlsheetname"
row_heights="&row_height"
/*default_column_width='25,8,25,8' */
frozen_headers='yes' frozen_RowHeaders='2' Zoom='80') ;
proc report data=&printdata nowd  split='*' spacing=1 headline missing;
column &byVar &notbvar;
%if %length(&byvar)>0 %then
  %do i=1 %to &nbyVars;
  %let byvar&i=%scan(&byVar,&i,%str( ));
   define &&byvar&i / order=data  left flow style(column)=[width=150];
%end;
%if %length(&notbvar)>0 %then
  %do i=1 %to &nnotbvar;
  %let notbvar&i=%scan(&notbvar,&i,%str( ));
   define &&notbvar&i / order=data  center flow style(column)=[width=150];
%end;
run;
quit;
ods listing;
%mend Report_Ftest_Sol_Univar;
