/*****************************************************************************************************************/
/*  Name:                Canfield Count Width Macro.sas                                                                */
/*  Inputs:              indata= Input dataset;
                         byvar=  archiveID   evalvisit   side     ;
						 VellusVar=Settings;
                         WidthVar=Value;
						 outdatalong=CF_Long;
                         outdatawide=CF_Wide;
/*****************************************************************************************************************/
/*
Example run
-----------
%let indata=Canfield;
%let byvar=  archiveID   evalvisit   side     ;
%let VellusVar=Settings;
%let WidthVar=Value;
%let outdatalong=CF_Long;
%let outdatawide=CF_Wide;
*/

%put 'Example Run:';
%put '%CanfieldWdtCt(indata=Canfield,indata2=diameter, byvar=archiveID evalvisit side, VellusVar=Settings, WidthVar=Value, outdatalong=CF_Long, outdatawide=CF_Wide);';

%macro CanfieldWdtCt(indata=, byvar= , VellusVar=, WidthVar=, outdatalong=, outdatawide=);

data _null_;
 CALL SYMPUT('sqlbyvar', TRANWRD(COMPBL("&byvar")," ",","));
run;

data indata;
 set &indata &indata(in=b);
 if b then &VellusVar="AllHair";
 run;

%put ****** &sqlbyvar ******;

proc sql;
 create table t1 as 
 select distinct &sqlbyvar, &VellusVar, count(&WidthVar) as Ct, mean(&WidthVar) as Wdth, sum(constant('PI')*(&widthvar**2)/4) as Amnt
 from indata(where=(&WidthVar^=.))
 group by &sqlbyvar, &VellusVar
 order by &sqlbyvar, &VellusVar;
 run;

 data &outdatalong;
  set t1(in =a rename=(ct=&WidthVar) drop=wdth amnt)  t1(in=b rename=(wdth=&WidthVar) drop=ct amnt) t1(in=c rename=(amnt=&WidthVar) drop=ct wdth);
  if a then Measure=compress('CF_HrCt_'||&VellusVar);
  if b then Measure=compress('CF_HrWdth_'||&VellusVar);
  if c then Measure=compress('CF_HrAmnt_'||&VellusVar);
run; 

proc sort data=&outdatalong;
by &byvar Measure;
run;

proc transpose data=&outdatalong out=&outdatawide(drop=_name_);
 var &WidthVar;
 by &byvar;
 ID Measure;
 run;


data &outdatawide; set &outdatawide;
 Log_HrCt_V_NV=log10(CF_HrCt_Vellus/CF_HrCt_Non_Vellus);
 run;

proc transpose data=&outdatawide out=&outdatalong(rename=(CF_1=value) where=(value^=.)) prefix=CF_ name=measure;
var CF_: Log_HrCt_V_NV;
by &byvar;
run;

 
%mend CanfieldWdtCt;


