options ls=135 ps=54;
ods html  close;
ods listing;

libname XJData "Q:\beauty_care\clinical\Biometrics\XiaojieZhou\2013\Kemal\April2013\Xiaojie\data";

* %include "Q:\beauty_care\clinical\Biometrics\XiaojieZhou\SAS_R Code\SAS Code\SAS Macros\Grouping\Grouping Macro.sas";
****************************************************************************************;
proc format;
value trtfmt
	1='A: Control Shampoo Only'
	2='B: Fekkai Commercial Gloss'
	3='C: Fekkai Commercial Gloss+SFE839'
	4='D: Lab Made Gloss+SFE839'
	5='E: Lab Made Gloss Only'
	6='F: SFE839+MAKIMOUSSE';
value modefmt
	1='Commercial Gloss'
	0='Lab Made Gloss'
    -1='Control';
value elastfmt
	1='SFE839'
	0='None';
run;

data switchlong;
set XJData.Fekkai_switchlong;
* format treat elast mode;
length trt $30;
trt=put(treat,trtfmt.);
run;
 
proc contents data=switchlong; run;
 
proc sort data=switchlong;
by  attrib ID treat rep  panelist;
run;
 
ods output lsmeans=lsmeans diffs=diffs;
proc mixed data=switchlong (rename=(trt=prd));
by attrib;
class prd panelist ID rep;
model grade=prd  /  ddfm=kr s lcomponents;
random ID ;
repeated /group=panelist r rcorr;
lsmeans prd/diffs;
Title "Model 1: Random Effect Model ";
run;

proc glm data=switchlong;
by attrib;
class trt rep;
model grade=trt ;
means trt / T;
means trt / duncan ;
run;
