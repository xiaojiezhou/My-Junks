
options ls=135 ps=54 nofmterr;
ods html  close;
ods listing;

%let study=Q:\beauty_care\clinical\Biometrics\Lin Fei\2011\CRB 11-12-149 Oxidative Damage - Maaike Bose;
libname cdmdata "&study\data\CDM Data";
libname analdata "&study\data";
libname XJdata   "&study\Xiaojie\QOL\Data";

%let XJMacro=Q:\beauty_care\clinical\Biometrics\XiaojieZhou\SAS Code\Macros;
%let StudyMacros=&study\Xiaojie\Macros;

%let cdmdata=crb1112149_qol_wide;

/*****************************************
proc print data= cdmdata.&cdmdata(drop=Pno StudySite SiteUniqueSubjectID Identity Randno EvalVisit DOB);
where ArchiveID="12040542004"; run;

proc freq data=cdmdata.&cdmdata;
table Trt*TrtLabel MeasureGroup*StudyDay*VisitLabel MeasureGroup*Measure /list ;
run;
***************************************/
run;

************Read in variable Grouping from factspec.csv file ******************;
%let factspec=FactorSpec.csv;					 *Excel file for factor Specs;
data Vargrps;
infile "&study\Xiaojie\QOL\Data\&factspec." dlm=',' dsd missover firstobs=2;
input GrpName : $50. Varname : $50.;
GrpName=compress(GrpName);
Varname=compress(Varname);
run;

*--- Read in QOL dataset ---*;
proc sql;
create table Vargrps as
select a.measure as Varname 'VarName',a.question_text as VarLabel 'VarLabel', b.GrpName
from analdata.qol_anno a left join Vargrps b
on compress(upcase(a.measure))=compress(upcase(b.Varname))
order by b.GrpName, a.measure;
quit;

*--- Add labels for groups ---*;
data Vargrps;
set Vargrps;
length GrpLabel $200;
if GrpName=' ' then GrpName='No Factor';
GrpLabel=GrpName;
run;

proc sort data=Vargrps;
by GrpName Varname;
run;

proc format;
value missfmt 9999='MISSING'  7777='Non Applicable';
run;



***************************************************************************************************************;
***************************************************************************************************************;
** Baseline Data ;
proc sort data=analdata.crb1112149dmquestwidef(where=(visitLabel="Baseline")) out=baseline; 
 by group trt trtlabel archiveid evalvisit;
run;
proc sort data=analdata.crb1112149dmquestwidef(where=(visitLabel^="Baseline")) out=Wk16; 
 by group trt trtlabel archiveid evalvisit;
run;

*Summary of Response Levels;
/*%SmryPercent(indata=&analdata,*/
/*				ndqs=&nqols,*/
/*				dqvars=&qols,*/
/*				outpath=&path.Yasser\QOL\&CRBNUM QOL-Summary of Response Levels-Baseline.xml*/
/*				);*/

data baseline;
set baseline;
D=(group='D');
N=(group='N');
run;

%include "Q:\beauty_care\clinical\Biometrics\Lin Fei\2011\CRB 11-12-149 Oxidative Damage - Maaike Bose\Xiaojie\Macros\CorrMacro.sas";
%CorrMacro(indata=baseline,
          VarGrp=vargrps,
          Method=pearson,
          Optional_Partial= partial d;,
          corcutoff=0.7 0.80,
          Outfile=&study\Xiaojie\QOL\Results\QOL-Partial Corr(Adj4Grp at BL).xml
);


%CorrMacro(indata=baseline,
          VarGrp=vargrps,
          Method=pearson,
          corcutoff=0.7 0.80,
          Outfile=&study\Xiaojie\QOL\Results\QOL-Partial Corr(Adj4Grp at BL).xml,
		  sheet_name=PearsonCorr
);


%CorrMacro(indata=wk16,
          VarGrp=vargrps,
          Method=pearson,
          corcutoff=0.7 0.80,
          Outfile=&study\Xiaojie\QOL\Results\QOL-Corr Week 16.xml,
		  sheet_name=PearsonCorr
);

