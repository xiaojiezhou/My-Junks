%macro flip2a (InputDs1a, OutputDs2a);

data all2_primgrad;
	set &InputDs1a;
	where evaluable = 'Y';
	if settings = 'Secondary' then delete;
	if measure = 'AsfsTotal' then delete;
	if measure = 'AsfsOctA' then measure = 'AsfsOctAF';
	if measure = 'AsfsOctF' then measure = 'AsfsOctAF';
	if measure = 'AsfsOctB' then measure = 'AsfsOctBE';
	if measure = 'AsfsOctE' then measure = 'AsfsOctBE';
	if measure = 'AsfsOctC' then measure = 'AsfsOctCG';
	if measure = 'AsfsOctG' then measure = 'AsfsOctCG';
	if measure = 'AsfsOctD' then measure = 'AsfsOctDH';
	if measure = 'AsfsOctH' then measure = 'AsfsOctDH';
	wildcard = substr(measure,1,4);
	if wildcard = 'Asfs' then Site = '  ';
run;

proc sort data=all2_primgrad;
	by Pno StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit 
	   VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
run;

data primgrad_V;
	set all2_primgrad;
	repnum = 'Rep'||put(rep,1.);
	newmeasure = trim(measure)||repnum;
	drop measure;
	rename newmeasure = measure;
run;

proc transpose data=primgrad_V out=tr_primgrad_V;
	by Pno StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit 
	   VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
	var	value;
	id	measure;
run;

proc datasets library=work;
	delete primgrad_V;
run;

data primgrad_BV;
	set all2_primgrad;
	repnum = 'Rep'||put(rep,1.);
	newmeasure = trim(measure)||repnum;
	newmeasure2 = "Base"||newmeasure;
run;

proc transpose data=primgrad_BV out=tr_primgrad_BV;
	by Pno StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit 
	   VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
	var	basevalue;
	id	newmeasure2;
run;

proc datasets library=work;
	delete primgrad_BV;
run;

data primgrad_DP;
	set all2_primgrad;
	repnum = 'Rep'||put(rep,1.);
	newmeasure = trim(measure)||repnum;
	newmeasure2 = "DiffPer"||newmeasure;
run;

proc transpose data=primgrad_DP out=tr_primgrad_DP;
	by Pno StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit 
	   VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
	var	DiffPercentValue;
	id	newmeasure2;
run;

proc datasets library=work;
	delete primgrad_DP;
run;

data primgrad_DV;
	set all2_primgrad;
	repnum = 'Rep'||put(rep,1.);
	newmeasure = trim(measure)||repnum;
	newmeasure2 = "Diff"||newmeasure;
run;

proc datasets library=work;
	delete all2_primgrad;
run;

proc transpose data=primgrad_DV out=tr_primgrad_DV;
	by Pno StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit 
	   VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
	var	diffvalue;
	id	newmeasure2;
run;

proc datasets library=work;
	delete primgrad_DV;
run;

data tr_primgrad_V;
	set tr_primgrad_V; 
	drop _name_;
run;

proc sort data=tr_primgrad_V;
	by Pno StudySite Identity ArchiveId RandNo evalvisit Trt TrtLabel Evaluable  
	   BodyLoc Gender Race Dob Age Side;
run;

data tr_primgrad_BV;
	set tr_primgrad_BV; 
	drop _name_;
run;

proc sort data=tr_primgrad_BV;
	by Pno StudySite Identity ArchiveId RandNo evalvisit Trt TrtLabel Evaluable  
	   BodyLoc Gender Race Dob Age Side;
run;

data tr_primgrad_DP;
	set tr_primgrad_DP; 
	drop _name_;
run;

proc sort data=tr_primgrad_DP;
	by Pno StudySite Identity ArchiveId RandNo evalvisit Trt TrtLabel Evaluable  
	   BodyLoc Gender Race Dob Age Side;
run;

data tr_primgrad_DV;
	set tr_primgrad_DV; 
	drop _name_;
run;

proc sort data=tr_primgrad_DV;
	by Pno StudySite Identity ArchiveId RandNo evalvisit Trt TrtLabel Evaluable  
	   BodyLoc Gender Race Dob Age Side;
run;

data primgrad2a;
	merge tr_primgrad_V tr_primgrad_BV tr_primgrad_DV tr_primgrad_DP;
	by Pno StudySite Identity ArchiveId RandNo evalvisit Trt TrtLabel Evaluable  
	   BodyLoc Gender Race Dob Age Side;
	dummy='merge';
run;

proc datasets library=work;
	delete tr_primgrad_V tr_primgrad_BV tr_primgrad_DV tr_primgrad_DP;
run;

data primgrad2a;
	set primgrad2a;
	retain 	Pno SiteUniqueSubjectId RandNo Identity StudyDay VisitLabel StudySite Trt TrtLabel Evaluable
            Gender Race Age Side;
	drop dummy;
run;

proc sort data=primgrad2a; 
	by Pno RandNo Evalvisit;
run;

data &OutputDs2a;
	set primgrad2a;
run;

proc export data= primgrad2a
	outfile= "&path.\&OutputDsName.2a.csv"
	dbms=csv replace;
run;

proc datasets library=work;
	delete primgrad2a;
run;

%mend flip2a;

****************************************************************;
*					Code for 2b									;
****************************************************************;

%macro flip2b (InputDs1b, OutputDs2b);

data all2_primgrad;
	set &InputDs1b;
	where evaluable = 'Y';
	if settings = 'Secondary' then delete;
	if measure = 'AsfsTotal' then delete;
	if measure = 'AsfsOctA' then measure = 'AsfsOctAF';
	if measure = 'AsfsOctF' then measure = 'AsfsOctAF';
	if measure = 'AsfsOctB' then measure = 'AsfsOctBE';
	if measure = 'AsfsOctE' then measure = 'AsfsOctBE';
	if measure = 'AsfsOctC' then measure = 'AsfsOctCG';
	if measure = 'AsfsOctG' then measure = 'AsfsOctCG';
	if measure = 'AsfsOctD' then measure = 'AsfsOctDH';
	if measure = 'AsfsOctH' then measure = 'AsfsOctDH';
	wildcard = substr(measure,1,4);
	if wildcard = 'Asfs' then Site = '  ';
run;

proc sort data=all2_primgrad;
	by Pno	StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit VisitLabel
	StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
run;

proc sql;
create table vstct2b as
select	unique(evalvisit) as visitct
from	all2_primgrad;
quit;

*This counts the number of visits;
%let ds=%sysfunc(open(vstct2b,i));
%let numvst=%sysfunc(attrn(&ds,nlobs)); 
%let rc=%sysfunc(close(&ds));

data _null_;
	%do i = 1 %to &numvst;
		data primgrad_V_&i;
			set all2_primgrad;
		run;
		proc transpose data=primgrad_V_&i out=tr_primgrad_V_&i;
			by Pno	StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit 
			VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
			var	value;
			id	measure;
		run;
		data primgrad_BV_&i;
			set all2_primgrad;
			newmeasure2 = "Base"||measure;
		run;
		proc transpose data=primgrad_BV_&i out=tr_primgrad_BV_&i;
			by Pno	StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit 
			VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
			var	basevalue;
			id	newmeasure2;
		run;

		data primgrad_DP_&i;
			set all2_primgrad;
			newmeasure2 = "DiffPer"||measure;
		run;
		proc transpose data=primgrad_DP_&i out=tr_primgrad_DP_&i;
			by Pno	StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit 
			VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
			var	DiffPercentValue;
			id	newmeasure2;
		run;

		data primgrad_DV_&i;
			set all2_primgrad;
			newmeasure2 = "Diff"||measure;
		run;
		proc transpose data=primgrad_DV_&i out=tr_primgrad_DV_&i;
			by Pno	StudySite Identity ArchiveId RandNo Trt TrtLabel Evaluable EvalVisit 
			VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair SiteUniqueSubjectId Side;
			var	diffvalue;
			id	newmeasure2;
		run;

		data tr_primgrad_V_&i;
			set tr_primgrad_V_&i; 
			drop _name_;
		data tr_primgrad_BV_&i;
			set tr_primgrad_BV_&i; 
			drop _name_;
		data tr_primgrad_DP_&i;
			set tr_primgrad_DP_&i; 
			drop _name_;
		data tr_primgrad_DV_&i;
			set tr_primgrad_DV_&i; 
			drop _name_;
		run;

		proc sort data=tr_primgrad_V_&i;
			by Pno	StudySite Identity ArchiveId RandNo EvalVisit Trt TrtLabel Evaluable 
			VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair Side;
		run;
		proc sort data=tr_primgrad_BV_&i;
			by Pno	StudySite Identity ArchiveId RandNo EvalVisit Trt TrtLabel Evaluable 
			VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair Side;
		run;
		proc sort data=tr_primgrad_DP_&i;
			by Pno	StudySite Identity ArchiveId RandNo EvalVisit Trt TrtLabel Evaluable 
			VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair Side;
		proc sort data=tr_primgrad_DV_&i;
			by Pno	StudySite Identity ArchiveId RandNo EvalVisit Trt TrtLabel Evaluable 
			VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair Side;

		data primgrad_&i._final;
			merge tr_primgrad_V_&i tr_primgrad_BV_&i tr_primgrad_DV_&i tr_primgrad_DP_&i;
			by Pno	StudySite Identity ArchiveId RandNo EvalVisit Trt TrtLabel Evaluable 
			VisitLabel StudyDay Timepoint BodyLoc Gender Race Dob Age Population TrtPair Side;
			dummy='merge';
		run;

		data primgrad2b;
			set primgrad_1_final;
			dummy='merge';
			keep dummy;
		run;

		data primgrad2b;
			merge primgrad_&i._final primgrad2b;
			by dummy;
		run;

	%end;
data primgrad2b;
	set primgrad2b;
	retain 	RandNo Identity StudyDay VisitLabel StudySite Trt TrtLabel Evaluable Gender Race Age Side;
	drop dummy;
run;

proc sort data=primgrad2b; by Pno RandNo Evalvisit; run;

data &OutputDs2b;
	set primgrad2b;
run;

proc export data= primgrad2b
	outfile= "&path.\&OutputDsName.2b.csv"
	dbms=csv replace;
run;

%mend flip2b;
 
