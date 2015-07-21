%macro Report_EndptOut(xlsheetname=,printdata=,byVar=,TrtVar=,row_height=40,comptable=trtcomps);
options mlogic symbolgen;
%let byVar=%qcmpres(%upcase(&byVar));
%let nbyVars=%eval(%sysfunc(countc(&byVar,' '))+1);


proc sort data=&comptable;
by trt_trt;
run;

data _null_;
set &comptable end=eof;
call symput('comp'||left(trim(_n_)),left(trim(trt_trt)));
if eof then call symput('ncomps',left(trim(_n_)));
run;

proc format;
  value FlagFmt  0='White'
  				 1	='Yellow'
				 2	='Rose'
	;
run;
quit;

data &printdata.2; 
set &printdata; 
  flg_probt=0; 
  if 0 < abs(prob_t)<= 0.05 then flg_probt=2;
  else if 0.05 < abs(prob_t)<= 0.10 then flg_probt=1;
  else flg_probt=0;
  flg_probtr=0; 
  if 0 < abs(prob_t_r)<= 0.05 then flg_probtr=2;
  else if 0.05 < abs(prob_t_r)<= 0.10 then flg_probtr=1;
  else flg_probtr=0;
  flg_probsr=0; 
  if 0 < abs(Prob_signrank)<= 0.05 then flg_probsr=2;
  else if 0.05 < abs(Prob_signrank)<= 0.10 then flg_probsr=1;
  else flg_probsr=0;

%do i=1 %to &ncomps;
  flg_prob&i=0; 
  if 0 < abs(prob_&i)<= 0.05 then flg_prob&i=2;
  else if 0.05 < abs(prob_&i)<= 0.10 then flg_prob&i=1;
  else flg_prob&i=0;
  flg_probr&i=0; 
  if 0 < abs(prob_r_&i)<= 0.05 then flg_probr&i=2;
  else if 0.05 < abs(prob_r_&i)<= 0.10 then flg_probr&i=1;
  else flg_probr&i=0;
  flg_wilcx&i=0;
  if 0 < abs(wilcox_&i)<= 0.05 then flg_wilcx&i=2;
  else if 0.05 < abs(wilcox_&i)<= 0.10 then flg_wilcx&i=1;
  else flg_wilcx&i=0;
%end;
run;

ods listing close;

ods tagsets.excelxp options(sheet_name="&xlsheetname"
row_heights="&row_height"
/*default_column_width='25,8,25,8' */
frozen_headers='yes' frozen_RowHeaders='4' Zoom='70') ;
proc report data=&&printdata.2 nowd  split='*' spacing=1 headline missing;
column &byVar &TrtVar RespVar
		 ("Group Level Summary of &TrtVar"  n mean Stddev Stderr Median Min Max P25 P75
						lsmean lsmeanr se ser prob_t prob_t_r Prob_signrank)
         ("Pairwise Group Comparison of &TrtVar" 
		%do i=1 %to &ncomps; 
			%if &i<&ncomps %then ("&&comp&i" est_&i estr_&i se_&i ser_&i  prob_&i prob_r_&i wilcox_&i);
			%if &i=&ncomps %then ("&&comp&i" est_&i estr_&i se_&i ser_&i  prob_&i prob_r_&i wilcox_&i));
		%end;
;
column flg_probt flg_probtr flg_probsr %do i=1 %to &ncomps; flg_prob&i flg_probr&i flg_wilcx&i %end;;
column dummy;
%if %length(&byvar)>0 %then
  %do i=1 %to &nbyVars;
  %let byvar&i=%scan(&byVar,&i,%str( ));
   define &&byvar&i / group  order=data  id left flow style(column)=[width=150];
   %end;
   define &TrtVar / group  order=data   id left flow style(column)=[width=200];
   define RespVar / group  ' Response*Variable' order=data   id left flow style(column)=[width=100];

 /** ALL DATA **/
   define n     / display  order=data   center format=8.0 style(column)=[width=50];
   define mean     / display  order=data   center format=8.3 style(column)=[width=100];
   define stddev     / display  order=data   center format=8.3 style(column)=[width=100];
   define Stderr     / display  order=data   center format=8.3 style(column)=[width=100];
   define Median     / display  order=data   center format=8.3 style(column)=[width=100];
   define Min     / display  order=data   center format=8.3 style(column)=[width=100];
   define Max     / display  order=data   center format=8.3 style(column)=[width=100];
   define P25     / display  order=data   center format=8.3 style(column)=[width=100];
   define P75     / display  order=data   center format=8.3 style(column)=[width=100];
   define lsmean	/ display "LSMean*ALL DATA" order=data center format=8.3 style(column)=[width=150];
   define se 	/ display "STDERR*ALL DATA" order=data center format=8.3 style(column)=[width=150];
   define prob_t / display "Pvalue*ALL DATA" order=data center format=pvalue6.4  style(column)=[width=150];
   define Prob_signrank / display "Pvalue*Signed Rank" order=data center format=pvalue6.4  style(column)=[width=150];
%do i=1 %to &ncomps;
   define est_&i  	/ display "LSMean*Diff*ALL DATA" order=data center format=8.3 style(column)=[width=150];
   define se_&i  	/ display "Stderr*Diff*ALL DATA" order=data center format=8.3 style(column)=[width=150];
   define prob_&i 	/ display "Pvalue*Diff*ALL DATA" order=data center format=pvalue6.4  style(column)=[width=150];
   define wilcox_&i 	/ display "Pvalue*Diff*(NonParam)" order=data center format=pvalue6.4  style(column)=[width=150];
%end;

/** EXTREME VALUES REMOVED **/
   define lsmeanr	/ display "LSMean*Xclud Extrm" order=data center format=8.3 style(column)=[width=150];
   define ser  	/ display "STDERR*Xclud Extrm" order=data center format=8.3 style(column)=[width=150];
   define prob_t_r  / display "Pvalue*Xclud Extrm" order=data center format=pvalue6.4  style(column)=[width=150];
%do i=1 %to &ncomps;
   define estr_&i  	/ display "LSMean*Diff*Xclud Extrm" order=data center format=8.3 style(column)=[width=150];
   define ser_&i  	/ display "Stderr*Diff*Xclud Extrm" order=data center format=8.3 style(column)=[width=100];
   define prob_r_&i 	/ display "Pvalue*Diff*Xclud Extrm" order=data center format=pvalue6.4  style(column)=[width=150];
%end;

   /*define flag(s) but keep hidden*/
    define flg_probt / display noprint;
	define flg_probtr / display noprint;
	define flg_probsr / display noprint;
	%do i=1 %to &ncomps;
    define flg_prob&i / display noprint;
	define flg_probr&i / display noprint;
    define flg_wilcx&i / display noprint;
	%end;
  /*define a dummy variable to use for the compute statement*/
   define dummy / computed noprint;
	compute dummy;
	   if flg_probt gt 0 then do;
        call define("prob_t",'style','style=[background=' ||put(flg_probt,FlagFmt.) || ']');
	   end;
	   if flg_probtr gt 0 then do;
        call define("prob_t_r",'style','style=[background=' ||put(flg_probtr,FlagFmt.) || ']');
	   end;
	   if flg_probsr gt 0 then do;
        call define("Prob_signrank",'style','style=[background=' ||put(flg_probsr,FlagFmt.) || ']');
	   end;
	%do i=1 %to &ncomps;
	   if flg_prob&i gt 0 then do;
        call define("prob_&i",'style','style=[background=' ||put(flg_prob&i,FlagFmt.) || ']');
	   end;
	   if flg_probr&i gt 0 then do;
        call define("prob_r_&i",'style','style=[background=' ||put(flg_probr&i,FlagFmt.) || ']');
	   end;
	   if flg_wilcx&i gt 0 then do;
        call define("wilcox_&i",'style','style=[background=' ||put(flg_wilcx&i,FlagFmt.) || ']');
	   end;
	%end;
     endcomp;
run;
quit;
ods listing;
options nomlogic nosymbolgen;
%mend Report_EndptOut;
