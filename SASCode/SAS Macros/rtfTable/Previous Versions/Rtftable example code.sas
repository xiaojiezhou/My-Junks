ods listing;
%let path=Q:\beauty_care\clinical\Biometrics\XiaojieZhou\SAS_R Code\SAS Macros\rtfTable;

%include "Q:\beauty_care\clinical\Biometrics\XiaojieZhou\SAS_R Code\SAS Macros\rtfTable\rtfTable92b.sas";
ods rtf file="&path.\SAS Table Output.rtf";

data summary1;
 input Trt_trt$ floor_type$ Odouls_General Pine_sol Zamboni_General mean_se$ ci$ probt;
 cards;
A Wood   2.11  3.1 2.32  5.1(2.4) (2.7,32) 0.02
B Wood   2.37  3.9 4.23  9.1(5.4) (3.1,32) 0.22
C Wood   3.21  3.1 6.31  3.1(8.4) (9.1,32) 0.32
A Ceramic   2.11  3.1 2.32  5.1(2.4) (2.7,32) 0.02
B Ceramic   2.37  3.9 4.23  9.1(5.4) (3.1,32) 0.22
C Ceramic   3.21  3.1 6.31  3.1(8.4) (9.1,32) 0.32
;run;
* proc print data=summary1; run;



%let studyNo=CRB-2013-09-034;
%let portraitOptions=orientation=portrait leftmargin=1in rightmargin=1in topmargin=1in bottommargin=1in; * headersize=.5in footersize=.5in;
* %let landscapeOptions=orientation=landscape topmargin=1 bottommargin=.5 leftmargin=1 rightmargin=1 headerSize=.75 footersize=.5;
options &portraitOptions; * order=data;

%rtfTable(%str(
pretitle "White Glove Test Result Summary ";
title1 "Table <SEQTOCLINK>";

proc print data=summary1 fontsize=8;
	var  floor_type Odouls_General Pine_sol Zamboni_General mean_se ci probt;
*	break  trt_trt  ;
	format ci $15. ;
	by trt_trt ;
	label floor_type='<w=1.2>Floor Type' mean_se='<w=1.0>Mean Diff (SE)' ci='<w=0.8>95% CI' probt='<w=0.8>Pr > t';
	Title1 "General Solution";
	title2 "Dirtiness (delta_Y of initial-final) - <byval1>";
run;


proc print data=summary1 fontsize=8;
	var  floor_type Odouls_Wood Pine_sol Zamboni_Wood mean_se ci probt;
*	break  trt_trt  ;
	format ci $15. ;
	by trt_trt ;
	label floor_type='<w=1.2>Floor Type' mean_se='<w=1.0>Mean Diff (SE)' ci='<w=0.8>95% CI' probt='<w=0.8>Pr > t';
	Title1 "Wood Solution";
	title2 "Dirtiness (delta_Y of initial-final) - <byval1>";
run;

));
ods rtf close;
