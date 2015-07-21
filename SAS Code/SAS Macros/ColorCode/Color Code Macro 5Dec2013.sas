/********************************************************************/
/*** Program:           Color Code Macro.sas	                  ***/
/*** Date:              12/05/2013                                ***/
/*** Purpose:           Summarize results from ANCOVA Analysis,and color-code
                        the pvalues for effect estimates:
                        (dark green=sig positive, 
                        light green=directional positive, 
                        dark red= sig negative,
                        yellow= directional negative.
                        Program used output datasets from ANCOVA macro      ***/
/*** Author:            Yasser Elbissaty                          ***/
/********************************************************************/
*************************************************************************************************;
******************************;
**Print summaries to Excel file 
  with color coded estimates
  based on p-values less than alpha1 , alpha2
  taking the direction of point estimates
  into account;
******************************;

%macro ColorCode(indata=,x=,p=,alphas=0.05 0.10, outfile=);
options mprint macrogen nodate noxwait noquotelenmax varlenchk=nowarn nofmterr ; 
%let x=%upcase(%qcmpres(&x));
%let k=%eval(%sysfunc(countc(&x," "))+1);
%let p=%upcase(%qcmpres(&p));
%let np=%eval(%sysfunc(countc(&p," "))+1);

** Check number of columns in x should be equal to number of columns in p;
%if &k ^= &np %then 
	%do;
      	%put ERROR: NUMBER OF COLUMNS IN X AND P MUST BE EQUAL ;
      	%goto exit;
      %end;

** Check number of alpha values should be equal to 2;
%let alphas=%qcmpres(&alphas);
%let numalphas=%eval(%sysfunc(countc(&alphas," "))+1);
%if &numalphas ^= 2 %then 
	%do;
      	%put ERROR: NUMBER OF ALPHA VALUES MUST BE 2 ;
      	%goto exit;
      %end;

** Check first alpha should be less than second alpha;
%let alpha1=%scan(&alphas,1,%str( ));
%let alpha2=%scan(&alphas,2,%str( ));

%if &alpha1 >= &alpha2 %then 
	%do;
      	%put ERROR: FIRST ALPHA VALUE MUST BE LESS THAN SECOND VALUE ;
      	%goto exit;
      %end;

data colorcode;
set &indata;
run;

proc contents data=colorcode out=cc_conts(keep=name label varnum) varnum noprint;
run;
proc sort data=cc_conts;
by varnum;
run;

*get names of  x variables in dataset and store in var1....vark macro variables;
* store the labels of x variables to assign to var1...vark in proc report;
data x;
set cc_conts;
length newname $200;
%do i=1 %to &k;
i=&i;
%let x&i=%scan(&x,&i,%str( ));
	if (upcase(name)="%upcase(&&x&i)") then do;
	newname="var&i";
	output;
	end;
%end;
run;

proc sort data=x;
by varnum;
run;

data x;
set x;
if label="" then label=name;
call symput("label"||left(trim(i)),left(trim(label)));
run;
%put &label1 &label2 &label3 &label4;

*get names of other variables than x variables in dataset and store in notx macro variable;
data notx;
set cc_conts;
%do i=1 %to &k;
%let x&i=%scan(&x,&i,%str( ));
%let p&i=%scan(&p,&i,%str( ));
	if (upcase(name)="%upcase(&&x&i)") | (upcase(name)="%upcase(&&p&i)") then delete;
%end;
run;


proc sql noprint;
select name ,count(name)into: notx separated by ' ', :nnotx
from notx;
quit;
%put &notx;


* create new var1...vark variables from x vars in original data
  and convert to numeric if necessary;
* do same for pvalues columns;
data colorcode;
set colorcode;
%do i=1 %to &k;
%let x&i=%scan(&x,&i,%str( ));
%let p&i=%scan(&p,&i,%str( ));
var&i = input(&&x&i,bestd32.);
pval&i = input(&&p&i,bestd32.);
drop &&x&i &&p&i;
%end;
run;

* create the color coding formats by assinging flag values based on pvalues 
  and sign of var1...vark variables; 
proc format;
  value FlagFmt  0-1='White'
  				 2	='DAG'
				 3	='VLIG'
  				 4 	='DAG'  
				 5  ='VLIG'
	;
run;
quit;

data colorcode;
set colorcode;
%do i=1 %to &k;
flag&i=0; 
if  (var&i. > 0) & (0 < pval&i. <= &alpha1.) then flag&i=2;
else if  (var&i. > 0) & (&alpha1. < pval&i. < &alpha2.) then flag&i=3;
else if  (var&i. < 0) & (0 < pval&i. <= &alpha1.) then flag&i=4;
else if  (var&i. < 0) & (&alpha1. < pval&i. < &alpha2.) then flag&i=5;
else flag&i=1;	
%end;
run;

data _null_;
outfile=reverse(strip(symget('outfile')));
len=length(outfile);
sheetname=reverse(substr(outfile,4,index(outfile,'\')-4));
call symput('sheetname',left(trim(sheetname)));
run;
%put &sheetname;


* Print results to xml file in proc report;
ods listing close;
ods tagsets.ExcelXP 
file="&outfile." style=Listing; 

ods tagsets.excelxp options(sheet_name="SUMMARY(ALPHA=&alpha1. &alpha2.)"
row_heights='50' frozen_headers='yes' frozen_RowHeaders='1' Zoom='80');

proc report data=colorcode nowindows split='*' spacing=1 headline missing;
column &notx %do i=1 %to &k; var&i %end; ;
column %do i=1 %to &k; flag&i. %end;;
column dummy;

%do i=1 %to &nnotx;
%let notx&i=%scan(&notx,&i,%str( ));
	define &&notx&i /  order=data width=25  left flow style(column)=[width=200];
%end;

%do i=1 %to &k;
	 define var&i. / display "&&label&i." center format=bestd32. width=8 center style(column)=[width=100];
%end;

/*define flag(s) but keep hidden*/
%do i=1 %to &k;
	define flag&i. / display noprint;
%end;

/*define a dummy variable to use for the compute statement*/
define dummy / computed noprint;
compute dummy;
%do i=1 %to &k;
if flag&i. gt 0 then do;
call define("var&i.",'style','style=[background=' ||put(flag&i.,FlagFmt.) || ']');
end;
%end;

endcomp;
run;
quit;

ods tagsets.ExcelXP close; 
ods listing;

/*proc datasets lib=work nolist;*/
/*delete colorcode cc_conts notx x;*/
/*run;*/
/*quit;*/

%exit:

%mend ColorCode;
*************************************************************************************************;
*************************************************************************************************;
