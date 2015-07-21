options ls=135;
/* This program create table which list the number of evaluable subject at each visit and in each treatment group */
*  Required variables:  ArchviveID MeasureGroup Measure ;

ods listing;

libname analdata "\\qsfiles.pg.com\beauty_care\clinical\Biometrics\HairBiology\Studies\2012\CRB 12-10-106 OSLO\Data";
%let indata=analdata.crb1210106_efflong;

%let visitVar=studyday;
%let grpvar=TrtLabel;

%let outdata=a5;

proc sort data=&indata out=a1 nodupkey;
 by ArchiveID MeasureGroup Measure &visitVar &GrpVar;
 run;

ods output  CrossTabFreqs=a2;
 proc freq data=a1;
 table Measure*&visitVar*&Grpvar/nopercent nocol norow missing;
 run;

data a2; set a2;
if &GrpVar="" then &GrpVar="Total";
IDVar=compress(&VisitVar||"_"||&GrpVar);
*  proc print data=a2(drop=table); 
if substr(_type_,1,2)="11";
if frequency=0 then delete;
run;

proc sort data=a2;
by measure  ;
run;

proc transpose data=a2 out=a3(drop=_name_ _label_);
var frequency;
ID idvar;
by measure;
run;
* proc print data=a3; run;


proc sort data=a1(keep=measuregroup measure) out=a4 nodupkey;
by measuregroup measure;
run;

proc sql;
 create table &outdata as
 select b.MeasureGroup, a.*
 from a3 as a left join a4 as b
 on a.measure=b.measure
 order by b.MeasureGroup, a.measure;

 proc print data=&outdata; run;
