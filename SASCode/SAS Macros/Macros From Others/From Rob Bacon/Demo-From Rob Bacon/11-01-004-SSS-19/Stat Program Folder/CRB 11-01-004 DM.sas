dm 'out;clear;log;clear;';

options symbolgen mlogic mprint source source2;

proc datasets library=work kill;
quit;

%let Path	=C:\Documents and Settings\ti4224\My Documents\My Work\Crb\11-01-004-SSS-19\Stat Data Folder;
%let MacroPath		=C:\Documents and Settings\ti4224\My Documents\My Work\Crb\11-01-004-SSS-19\Stat Program Folder;
%let InputDsName	=crb1101004DmEfficacyLongF;
%let OutputDsName	=CRB1101004_; *Prefix of the output data sets contains CRB number;

Libname Save "&Path";

data TempInputDsName;
	set Save.&InputDsName;
	siteuniquesubjectid=.;
run;


Proc Freq Data=TempInputDsName;
	tables Age BodyLoc EvalVisit Evaluable Gender InfoTag InsId Measure MeasureGroup Notes OperGrade Pno Race 
	       Rep Settings Side Site StudyDay StudySite TimePoint Trt TrtLabel Unit VisitLabel;
Run;

/*
data all;
	set TempInputDsName;  

	position=index(Notes,'Population=');
	if Position then Pop=substr(Notes,Position+11,1);
	
	if pop='N' then Population=         'Non Dandruff';
	  else if pop='D' then Population=  'Dandruff    ';
		else if pop='U' then Population='Unassigned  '; 
	      else Population=              'MissingError';

	drop position pop;

	position2=index(Notes,'TrtPair=');
	if Position2 then TrtPair=substr(Notes,Position2+8,2);
		
	drop position2;

	PositionNotes=index(InfoTag,'Depth');
	if PositionNotes then Depth=substr(InfoTag,PositionNotes+5,2);
		else Depth='NA';

run;

data temp;
	set all (obs=10);
run;

proc print data=temp;
run;
*/


%include "&MacroPath.\SSM1 V1.4.sas";
%ssm_1a_1b (TempInputDsName, Save.&OutputDsName.1a, Save.&OutputDsName.1b);

*Only one depth in SSS19;
*If there are more than one level of depth for a biomarker then do not run flip2a and flip2b;
%include "&MacroPath.\SSM2 V1.sas";
%flip2a (Save.&OutputDsName.1a, Save.&OutputDsName.2a);

%flip2b (Save.&OutputDsName.1b, Save.&OutputDsName.2b);





