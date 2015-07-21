
/**********
%let indata=one ;
%let byvar = subject visit site;
%let count=count;
%let width=bin;
%let outdatalong=long;
%let outdatawide=wide;
*************/
**********************************************************************************************************;
* Purpose:  Macro which take OFDA raw data and create OFDA diameter mean, Sd, percentiles, and totalFibers;
* Outputs: Two datasets: Outdatalong is in long format and outdatawide is wide format                     ;
*                                                                                                         ;
* Notes:  width >150um were not include in diameter mean, SD and percentile calculation                   ;
*         width >150um were included in calculating total fibers.  It is done so to match the totalfiber  ;
*         in raw input data                                                                               ;
*                                                                                                         ;
**********************************************************************************************************;
%put "*-----     Example:   How to use OFDADiameter macro     ------*";
%put "%OFDADiameterLE150(indata=OFDA, byvar=archiveID evalvisit side, count=Rep, width=Value, outdatalong=OFDA_long, outdatawide= OFDA_wide);";

%macro OFDADiameterLE150(indata=, byvar=, count=, width=, outdatalong=, outdatawide= );
proc sort data=&indata out=a1 ;
    by &byvar; 
run;

*--- Total Fibers ---*;
proc means data=a1 sum maxdec=1 fw=7 noprint;
var &count;
by &byvar;
output out=totalfibers sum=TotalFibers;
run;

*--- Mean, Stddev, Trimmed Mean, Percentiles ---*;
ods listing close;
proc univariate data=a1  trimmed=0.05 0.10 nobyplot  ;
 by &byvar;
 var &width ;
 freq &count;
 output out=a2 pctlpre=YMDmtr_P  pctlpts=5 to 95 by 10 mean=YMDmtr_Mean STDDEV=YMDmtr_SD; 
 ods output trimmedmeans=a3 ;
 where &width<=150;
 run;
 ods listing;
 %put &width;
data a4(drop=halfP);
 merge a2 a3(where=(round(halfP,1)=5)  rename=(Mean=YMDmtr_MeanTrm5)  Keep=&byvar Mean halfP)
          a3(where=(round(halfP,1)=10) rename=(Mean=YMDmtr_MeanTrm10) Keep=&byvar Mean halfP);
 by &byvar;
run;

data &outdatawide(keep=&byvar YMD: Total:);
 merge a4 TotalFibers;
 by &byvar;
 run;

*--- Reshare the data in long format ---*;
proc transpose data=&outdatawide out=&outdatalong(drop= _label_ rename=(_name_= Measure COL1=Value)) ;
 by &byvar;
 var YMD: TotalFibers;
run;
%mend;
