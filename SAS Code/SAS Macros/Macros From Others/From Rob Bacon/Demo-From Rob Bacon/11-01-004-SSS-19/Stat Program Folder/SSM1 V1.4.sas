*
Assumptions:
		Baseline is represented by EvalVisit=1
		An individual unique data point can be reached with the variables ArchiveId EvalVisit Measure
			OperGrade BodyLoc Side Site Rep Depth
		The data associated for rep 1 is the same as the data for the other reps except for the variables
			rep, value, basevalue, diffvalue, diffpercentvalue, and depth

Version 1.1
	Added in option to compress the datasets 1a and 1b
	Added in code to pull depth out of InfoTag and enter it into a variable called Depth
	Added in code to use MeasureGroup variable to determine which variable are log transformed

Version 1.2
	Added a separate variable that holds the value of BQL and AQL
    For the non Log measures flagged values as BQL Yes/No/NA and AQL Yes/No/NA

Version 1.3
	Added in an Err option for the BQL and AQL flages for values that should not be possible

Version 1.4
	In the creation of dataset 1a the basetest dataset was over writing post treatment data under a situation
    where the data was not sorted.  Fixed this issue by keeping only the variable in the by portion of the merge
	procedure and the basevalue variable. 
;

%macro SSM_1A_1B(InputDs,OutputDs1a,OutputDs1b);

data all;
	set &InputDs;  


	posstudy=index(Notes,'StudyType=');
	if posstudy then StdyType=substr(Notes,posstudy+10,2);
	
	if StdyType='SS' then StudyType=        'Split Scalp ';
	  else if StdyType='FS' then StudyType= 'Full Scalp  ';
		else StudyType=              		'MissingError';

	drop posstudy StdyType;

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

	drop positionNotes;

	BQLPos=index(settings,'BQL');
	AQLPos=index(settings,'AQL');

	If BQLPos then 
		do;
			BQLTemp=Substr(settings,BQLPos+4);
			BQLTemp2=Scan(BQLTemp,1,'');
			BQLValue=BQLTemp2*1;
		end;
	If AQLPos then 
		do;
			AQLTemp=Substr(settings,AQLPos+4);
			AQLTemp2=Scan(AQLTemp,1,'');
			AQLValue=AQLTemp2*1;
		end;

	If BQLValue=. then BQL='NA ';
    If AQLValue=. then AQL='NA '; 

	If BQLValue ne . then 
		do;
		  if value=(BQLValue/2) then BQL='Yes';
		  if value>=(BQLValue) then BQL='No ';
		  if value<(BQLValue) and value>(BQLVAlue/2) then BQL='Err'; *Setting BQL to error because it is not possible to fall in this range;
		  if value<(BQLValue/2) then BQL='Err';
		end;

	If AQLValue ne . then 
		do;
		  if value=(AQLValue) then AQL='Yes';
		  if value<(AQLValue) then AQL='No ';
		  if value>(AQLValue) then AQL='Err';
		end;

	drop BQLPos BQLTemp BQLTemp2 AQLPos AQLTemp AQLTemp2;

run;

*For extra measures that should be log transformed add them to the 'if MeasureGroup in' statement below.  Also 
 update in() code for percent change in data all2 dataset;
data Transform;
	set All;
	if MeasureGroup in('Biomarker','Imac');
run;

data LogTransform;
	set Transform;
	Measure="Log"||Measure;
	Value = Log10(Value);

*At this time setting the BQL and AQL as NA for Log Biomarker data ;
	BQLValue=.;
	AQLValue=.;
	BQL='NA ';
	AQL='NA ';
run;

data all;
	set all LogTransform;
run;

proc datasets library=work;
	delete transform logtransform;
run;

*Sorting data to the individual data point so it can be merged with the baseline data;
proc sort data=all;
	 by	ArchiveId Measure OperGrade BodyLoc Side Site Rep Depth;
run;

*Creating a dataset with only baseline values;
data basetest;
	set all;
	where Evalvisit = 1;
	BaseValue = Value;

	keep ArchiveId Measure OperGrade BodyLoc Side Site Rep Depth BaseValue;
run;

*Making sure that the baseline dataset is sorted in the correct order for the upcoming merge;
proc sort data=basetest;
	by ArchiveId Measure OperGrade BodyLoc Side Site Rep Depth;
run;

data all2;
	merge all basetest;
	by ArchiveId Measure OperGrade BodyLoc Side Site Rep Depth;
	DiffValue = Value - BaseValue;

	wildcard = substr(measure,1,3);
	if wildcard = 'Log' then Log='Y';
		else Log='N';

	if MeasureGroup in('Biomarker','Imac') and Log='Y'
		then DiffPercentValue = ((10**DiffValue)-1)*100;
	else if BaseValue=0 then DiffPercentValue=.; else DiffPercentValue = (DiffValue/BaseValue)*100;

	drop wildcard Log;
run;

proc datasets library=work;
	delete basetest all;
run;

*Sorting data for export;
proc sort data=all2;
	by Pno RandNo EvalVisit Measure BodyLoc Side Site Rep OperGrade Depth;
run;

*Reordering variables for export;
data all2;	
	retain 	Pno RandNo Identity StudyDay VisitLabel StudySite Side Site Rep Depth OperGrade Settings Measure
			Value BaseValue DiffValue DiffPercentValue Trt TrtLabel Evaluable Gender Race Age;
	set all2;
run;

*CSV dataset that contains the data from the original dataset plus a variable for BaseValue DiffValue 
 and DiffPercentValue - DataSet 1a;
proc export data= all2 
	outfile= "&path.\&OutputDsName.1a.csv"
	dbms=csv replace;
run;


*Permanent dataset that contains the data from the original dataset plus a variable for BaseValue 
 DiffValue and DiffPercentValue - DataSet 1a;
data &OutputDs1a (compress=char);
	set all2;
run;

 
**************************************************************************************************
End of Dataset 1a creation and the begining of the creation of dataset 1b;

*Sorting data so the average across rep can be calculated;
proc sort data=all2;
	by ArchiveID EvalVisit Measure OperGrade BodyLoc Side Site Depth;
run;

*Averaging across rep and assigning the average to the variable Value, BaseValue and DiffValue.
 If there is only one rep then the values for rep 1 and average are the same;
proc means data=all2 noprint;
	by ArchiveID EvalVisit Measure OperGrade BodyLoc Side Site Depth;
	var Value BaseValue DiffValue DiffPercentValue;
	output out=all2means;
run;

*Selecting only the mean statistic;
data all2means;
	set all2means;
	where _stat_ = 'MEAN';
run;

data all2means;
	set all2means;
	drop _freq_ _type_ _stat_;
run;

*Making the assumption that the data associated for rep 1 is the same as the data for the other reps except
 for the variables Rep, Value, BaseValue, DiffValue, and DiffPercentValue.;
data tempall2;
	set all2;
	if Rep=1;  *Getting rid of other reps for the merge below; 
	drop Rep Value BaseValue DiffValue DiffPercentValue; 
run;

proc datasets library=work;
	delete all2;
run;

*Merging mean data set with overall data to capture demographics etc.;
data finalall2means;
	merge all2means tempall2; 
	by ArchiveId EvalVisit Measure OperGrade BodyLoc Side Site Depth;
run;

proc datasets library=work;
	delete all2means tempall2;
run;

*Reordering variables;
data finalall2means;
	retain 	Pno RandNo Identity StudyDay VisitLabel StudySite Side Site Depth OperGrade Settings Measure
			Value BaseValue DiffValue DiffPercentValue Trt TrtLabel Evaluable Gender Race Age;
	set finalall2means;
run;

proc sort data=finalall2means;
	by Pno RandNo EvalVisit Measure BodyLoc Side Site OperGrade Depth;
run;

*CSV dataset that contains the data averaged across rep from the original dataset plus a variable for 
 BaseValue, DiffValue, and DiffPercentValue - DataSet 1b;
proc export data= finalall2means 
	outfile= "&path.\&OutputDsName.1b.csv"
	dbms=csv replace;
run;

*Permanent dataset that contains the data averaged across rep from the original dataset plus a variable for
 BaseValue, DiffValue, and DiffPercentValue - DataSet 1b;
data &OutputDs1b (compress=char);
	set finalall2means;
run;

proc datasets library=work;
	delete finalall2means;
run;

%mend SSM_1A_1B;
