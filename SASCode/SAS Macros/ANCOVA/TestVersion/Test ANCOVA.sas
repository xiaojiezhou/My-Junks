************* Date:  June7, 2013 -- This program analyze both pre- & post- washed hair diameters************;
 
options ls=135 ps=54;
ods html  close;
ods listing;
 
%let XJMacro=\\QSFILES.PG.COM\beauty_care\clinical\Biometrics\XiaojieZhou\SAS_R Code\SAS Macros\ANCOVA\TestVersion;
%let study=\\QSFILES.PG.COM\beauty_care\clinical\Biometrics\Lin Fei\2012\CRB 12-04-054 - Surf and Turf;
%let results=\\QSFILES.PG.COM\beauty_care\clinical\Biometrics\XiaojieZhou\SAS_R Code\SAS Macros\ANCOVA\TestVersion;


libname cdmdata "&study\data\CDM Data";
libname analdata "&study\data";
libname XJdata   "&study\Xiaojie\Data";
 
****************************************************************************************;

 
data d1;
set XJData.YMDiameter_both;
      if trt in ("A" "D" "E") then Trt_Cntrl="Trt  ";
else if trt in ("B" "C" "F") then Trt_Cntrl="Cntrl";
if index(Measure, "YMD_Mean")>0 or index(Measure, "YMD_S")>0;
run;
 
proc freq data=d1;
table Trt*TrtLabel Measure StudyDay*VisitLabel*Measure /list ;
run;
 
proc print data=d1(obs=100);  where ArchiveID="12040542013"; run;


************Begin:  Final Wk8 & BL Models ******************;
************June 10th, Checked results with previous report and it matched except for small difference in  K&P cGroup due to 2 subjcts were dropped due not non-evaluability flag. ***********;
 
Run;
%macro Finalmodel;
proc sort data=d1(where=(visitLabel="Baseline")) out=BL;
by cGroup measure  TrtLabel6;
run;
 
ods output solutionF=BLSolutionF lsmeans=BLlsmeans diffs=BLdiffs;
proc mixed data=bl noinfo noitprint noprofile noclprint plot=none;
  class trtlabel6 side archiveID;
  model bl = Side  trtlabel6/ s  ddfm=kr ;
  random ArchiveID;
  lsmeans  side /pdiff;
  by cGroup Measure ;
run;
 
 
proc sort data=d1(where=(visitLabel="Week 8")) out=wk8;
by cGroup measure ;
run;
 
ods output solutionF=wk8SolutionF Tests3=Wk8tests3 lsmeans=wk8lsmeans diffs=wk8diffs;
proc mixed data=wk8 noinfo noitprint noprofile noclprint plot=none;
  class trtlabel6 side archiveID;
  model cfb = Side  BL*trtlabel6 TrtLabel6/ s  ddfm=kr ;
  random ArchiveID;
  lsmeans TrtLabel6/pdiff;
  by cGroup Measure ;
  where index(Measure, "YMD_Mean")>0 or index(Measure, "YMD_S")>0;
run;
 
 
 
Title "BL: model BL=side Trtlabel6/ s  ddfm=kr ;  random archiveID;";
proc sort data=BLSolutionF; by cGroup Effect Measure ;  proc print data=BLSolutionF ; where effect ^="Intercept"; run;
proc print data=BLlsmeans; run;
proc print data=BLdiffs; run;
 
Title "Wk8: cfb = Side  BL*trtlabel6 TrtLabel6/ s  ddfm=kr ;  random ArchiveID;";
proc sort data=Wk8SolutionF; by cGroup Effect Measure ;
proc print data=Wk8SolutionF (drop=stderr df tvalue) ;
where effect ^="Intercept"; run;
proc sort data=wk8tests3; by cGroup Effect Measure ;
proc print data=wk8tests3;run;
proc print data=Wk8lsmeans(drop=effect stderr df tvalue); run;
proc print data=Wk8diffs(drop=effect stderr df tvalue); run;
 
Title "";
%mend Finalmodel;
%Finalmodel;
 
************End:  Final Wk8 & BL Models ******************;
 
**************************  Analysis of Covariance ********************************;
%include "&XJMacro.\ANCOVA_10Jun2013.sas";
%include "&XJMacro.\Report Ftest_Sol_Univar Ftests_SolutionF_Univar 28JAN2013.sas";
%include "&XJMacro.\Report Group Summary and Comparison 28Jan2013.sas";

*****************Begin:  Week 8 treatment Comparisons****************;
proc sort data=d1(where=(visitLabel="Week 8")) out=wk8;
 by cGroup measure TrtLabel6;
run;
proc print data=d1; where ArchiveID="12040542013"; run;
 
 
*----- CFB ----*;
%ANCOVA(Indata=wk8, Resp=CFB, byVar=cGroup Measure, TrtVar=Trt_Cntrl, CovVar= BL Side Trt_Cntrl*BL , ClassVar= ArchiveID Trt_Cntrl Side, optinal_random_Statement=random ArchiveID,     
       Tests3Out=wk8_Tests3Out, TableOut=wk8_GrpCmprOut, SolutionFOut=wk8_SolutionFOut, ResidOut=wk8_ResidOut, UnivarOut=wk8_UnivarOut);
proc print data=  wk8_GrpCmprOut(drop=est: se:); run;
proc print data=wk8_SolutionFOut; run;
proc print data=Wk8_tests3out; run;
run;
 
ods listing close;
ods tagsets.ExcelXP  path="&Results" file="(test) YMD_Pre-Post-Diameter Wk8 CFB Adj4Bl Side Trt_BL Results - TrtCmpr.xml" style=Listing Uniform;
%Report_Ftest_Sol_Univar(xlsheetname=wk8_Tests3Out,    printdata=wk8_Tests3Out, byVar=Effect cGroup Measure,   row_height=30);
%Report_Ftest_Sol_Univar(xlsheetname=wk8_SolutionFOut,printdata=wk8_SolutionFOut, byVar=Effect cGroup Measure,row_height=30);
%Report_Ftest_Sol_Univar(xlsheetname=wk8_UnivarOut,   printdata=wk8_UnivarOut, byVar=Set cGroup Measure,   row_height=30);
%Report_EndptOut(xlsheetname=wk8_GrpCmprOut,             printdata=wk8_GrpCmprOut,  byVar=cGroup Measure,TrtVar=Trt_Cntrl,row_height=40,comptable=trtcomps);
ods tagsets.ExcelXP close;
