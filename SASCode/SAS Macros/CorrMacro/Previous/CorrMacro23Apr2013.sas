***************************************************************************************************************;**********************************************
***************************************************************************************************************;
** Macro computes Pairwise or partial Correlations between sets of variables 
   with a grouping structure, and color code the correlations based on given cutoff values.
*Arguments:-
  ----------
 - indata          : Dataset for analysis in wide format (columns indicating labels of variables and rows for numeric values).
 - VarGrpData          : Dataset with variable grouping structure containing 4 columns, GrpName GrpLabel VarName VarLabel
 - Method          : Pearson or Kendall or Spearman.
 - Optional_Partial: Partial Correlations statement if needed
 - corcutoff       : Cutoff of correlations, 2 values only (e.g, 0.50 0.80)
 - Outfile         : Path and name for output file including file extensions .xml
***************************************************************************************************************;
/*%let indata=baseline;*/
/*%let VarGrpData=Vargrps;*/
/*%let Method=Pearson;*/
/*%let Optional_Partial= partial D %str(;);*/
/*%let corcutoff= 0.7 0.8 ;*/
/*%let outfile=&pathYasser.Results\&CRBNUM QOL-Partial Pairwise Correlations(Adjusted for group at Baseline).xml;*/


options ls=135 ps=54 mlogic mprint symbolgen;
%macro CorrMacro(indata=,VarGrpData=,Method=,Optional_Partial=,corcutoff=,Outfile=);
%let method=%qcmpres(%lowcase(&method));
%let Optional_Partial=%qcmpres(%lowcase(&Optional_Partial));
%let corcutoff=%qcmpres(%lowcase(&corcutoff));

proc sql noprint;
  select VarName into :varnames separated by ' '
  from &VarGrpData;
quit;
%put **** &varnames  ;

ods listing close;


%if %length(&Optional_Partial)^=0 %then %do;
	%if &method=pearson %then %let odsout=PartialPearsonCorr;
	%else %if &method=kendall %then %let odsout=PartialKendallCorr;
	%else %if &method=spearman %then %let odsout=PartialSpearmanCorr;
	%let Partialst=&Optional_Partial;
%end;
%else %do;
	%if &method=pearson %then %let odsout=PearsonCorr;
	%else %if &method=kendall %then %let odsout=KendallCorr;
	%else %if &method=spearman %then %let odsout=SpearmanCorr;
	%let Partialst=&Optional_Partial;
	%let Partialst= ;
%end; 

%put odsout=&odsout;
%put Partialst=&Partialst;

ods output &odsout.=Corrs1(rename=(variable=VarName));
proc corr data=&indata nosimple noprob;
var &varnames;
&Partialst;
run;
quit;

proc sql;
create table Corrs1 as 
select VarLabel,GrpName,GrpLabel,a.*
from Corrs1 a, &VarGrpData b
where upcase(a.Varname)=upcase(b.Varname)
;
quit;
ods listing;

/*PROC REG data=&indata; */
/*Model ambi_confdntcln = nemo1  value / pcorr1 pcorr2;*/
/*Run;*/
/*quit;*/
***************************************************************************************************************;
***************************************************************************************************************;
******************************
**Print table to Excel file
******************************;

ods listing close;
ods tagsets.ExcelXP 
file="&outfile." style=Listing; 

data _null_;
set Corrs1 end=eof;
call symput('vname'||left(trim(_n_)),varname);
call symput('vlab'||left(trim(_n_)),varlabel);
if eof then call symput('nvars',left(trim(_n_)));
run;

proc format;
  value FlagFmt  0-1='White'
  				 2	='Yellow'
				 3	='Red'
  				 4 	='Black'  
	;
run;
quit;

%let corcut1=%scan(&corcutoff,1,%str( ));
%let corcut2=%scan(&corcutoff,2,%str( ));

data Corrs2; 
set Corrs1; 
%do i=1 %to &nvars;
  flag&i=0; 
  if 0 < abs(&&vname&i.)< &corcut1 then flag&i=1;
  else if &corcut1 <= abs(&&vname&i.) < &corcut2 then flag&i=2;
  else if &corcut2 <= abs(&&vname&i.) < 0.999 then flag&i=3;
  else if 0.999    <= abs(&&vname&i.) <= 1.00 then flag&i=4;
%end;
run;

%if %length(&Optional_Partial)^=0 %then %do;
	%let shtname=Partial Corrs(&corcut1 &corcut2);
%end;
%else %do;
	%let shtname=Corrs(&corcut1 &corcut2);
%end;


ods tagsets.excelxp options(sheet_name="&shtname."
/*row_heights='15'*/
row_heights='50'
/*default_column_width='25,8,25,8' */
frozen_headers='yes' frozen_RowHeaders='4' Zoom='80');

proc report data=Corrs2 nowindows split='*' spacing=1 headline missing spanrows ;
column GrpLabel GrpName VarLabel VarName  (%do i=1 %to &nvars; ("&&vlab&i." &&vname&i.) %end;);
column %do i=1 %to &nvars; flag&i. %end;;
column dummy;
   define GrpLabel / group  order=data width=200 left   style(column)=[width=50 height=5];
   define GrpName		/ group order=data width=100   left  style(column)=[width=50 height=5];
   define VarLabel		/ group order=data width=200 left  style(column)=[width=400 height=5];
   define VarName		/ group order=data width=100 left  style(column)=[width=50 height=5];
	 %do i=1 %to &nvars;
	 define &&vname&i.		/ display  center  format=8.2 width=8 center style(column)=[width=80];
	 %end;
   /*define flag(s) but keep hidden*/
	 %do i=1 %to &nvars;
    define flag&i. / display noprint;
	 %end;
  /*define a dummy variable to use for the compute statement*/
   define dummy / computed noprint;
	compute dummy;
	 %do i=1 %to &nvars;
	   if flag&i. gt 0 then do;
        call define("&&vname&i.",'style','style=[background=' ||put(flag&i.,FlagFmt.) || ']');
	   end;
	 %end;
     endcomp;
	compute after GrpName;
	line '_';
	endcomp;
run;
quit;

ods tagsets.ExcelXP close; 
ods listing;


%mend CorrMacro;

options nomlogic nomprint nosymbolgen;
***************************************************************************************************************;
***************************************************************************************************************;
