%let indata=BL;
%let RESP=bl;
%let byvar=cGroup Measure;
%let TrtVar=Trt_Cntrl;
%let CovVar=BL Side Trt_Cntrl*BL;
%let ClassVar= ArchiveID Trt_Cntrl Side;
%let Tests3Out=Tests3Out_bl;
%let TableOut=GrpCmprOut_bl;
%let SolutionFOut=SolutionFOut_bl;
%let ResidOut=ResidOut_bl;
%let UnivarOut=UnivarOut_bl;
*%let optinal_repeat_Statement= repeat /group=Group;
%let optinal_random_Statement= random archiveID;

%macro m1;
%let CovVar=%qcmpres(%upcase(&CovVar));
%let ncovs=%eval(%sysfunc(countc(&CovVar,' '))+1);
%let ClassVar=%qcmpres(%upcase(&ClassVar));
%let nclass=%eval(%sysfunc(countc(&ClassVar,' '))+1);
%let TrtVar=%qcmpres(%upcase(&TrtVar));
%let ntrts=%eval(%sysfunc(countc(&TrtVar,' '))+1);


* Get Continuous Covariates and store them in a macro variable;
* Get Categorical Covariates and store them in a macro variable;
%let contcov=;
%let classcov=;
%do cov=1 %to &ncovs;
	%let covar&cov=%scan(&CovVar,&cov,%str( ));
	%if %index(&ClassVar,&&covar&cov)=0 & (%index(&&covar&cov,%str(*))=0) %then %let contcov=&contcov &&covar&cov;
	%if (%index(&ClassVar,&&covar&cov)>0) & (%index(&&covar&cov,%str(*))=0 ) %then %let classcov=&classcov &&covar&cov;
%end;
* Create a list of trtvar and covariates to be included in the solutionf ouptut data from proc mixed;
%let trtcov=%qcmpres(&Trtvar %upcase(&classcov));
%let ntrtcov=%eval(%sysfunc(countc(&trtcov,' '))+1);

data extravars;
length extravar $100;
classvar=symget('classvar');
covvar=symget('covvar');
trtvar=symget('trtvar');
array class[&nclass] $100;
array flagtr[&nclass];
array flagcv[&nclass];
do i=1 to &nclass;
	class[i]=scan(classvar,i,' ');
	flagtr[i]=(index(upcase(trtvar),upcase(class[i]))=0);
	flagcv[i]=(index(upcase(covvar),upcase(class[i]))=0);
	if flagtr[i]=1 & flagcv[i]=1 then do;
		extravar=class[i];
		output;
	end;
end;
keep extravar;
run;
proc sql noprint;
select distinct extravar, count(distinct extravar)
into :extravars separated by ' ', :nextra
from extravars;
quit;

data solutionf_test;
length EffectLev $200;
set SolutionF;
numvars=countc(effect,'*')+1;
%do l=1 %to &ntrtcov;
%let trtcov&l=%scan(&trtcov,&l,%str( ));
if numvars<2 then do;
	if upcase(effect)="&&trtcov&l" then EffectLev=&&trtcov&l;
end;
else do;
	do v=1 to numvars;
	if upcase(scan(effect,v,'*'))="&&trtcov&l" then EffectLev=&&trtcov&l;
	end;
end;
%end;
label 
	All_Estimate='Estimate All Data' R_Estimate='Estimate Excluding Extremes'
	Prob_t_ALL='Prob>|t| All Data' Prob_t_R='Prob>|t| Excluding Extremes';
keep &byvar Effect EffectLev All_Estimate Prob_t_ALL R_Estimate Prob_t_R;
run;


%put *** Treatment Variable= &trtvar ***;
%put *** All Covariates= &CovVar ***;
%put *** Continuous Covariates= &contcov ***;
%put *** Categorical Covariates= &classcov ***;
%put *** Treatment + Categorical Covariates= &trtcov ***;

%mend m1;
%m1;

data x;
classvar=symget('classvar');
/*classvar2=classvar||' '||scan(classvar,3,' ');*/
covvar=symget('covvar');
trtvar=symget('trtvar');
do i=1 to &nclass
extra=scan(classvar,3,' ');
chck=indexc(classvar,extra);
comp=count(classvar,extra,'it');
run;


data x;
set extravars;
c=(index(upcase(covvar),'SIDE')=0);
run;


%let _trtvar=_%left(&trtvar);
%put &_trtvar;
proc sort data=diffs;
by &byvar &trtVar &_trtvar;
run;


