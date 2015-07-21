
dm 'log;clear;out;clear;';

libname in 'C:\Documents and Settings\ti4224\My Documents\My Work\Crb\11-01-004-SSS-19\11';

* creating a subset randomziation for the hair plucking;
options nodate;
data use;
	set in.rand1101004;
	if randno in (152,174,185,191,227,242,267,280) then delete;
	randnum = ranuni(2811);
run;

data use_AB;
	set use;
	where sequence=1 and side='Left';
run;

proc sort data=use_AB;
by randnum;
run;

data use_AB;
	set use_AB;
	NAB=_n_;
run;

data use_AB;
	set use_AB;
	if NAB>25 then delete;

data use_BA;
	set use;
	where sequence=2 and side='Left';
run;

proc sort data=use_BA;
by randnum;
run;

data use_BA;
	set use_BA;
	NBA=_N_;
run;

data use_BA;
	set use_BA;
	if nBA>25 then delete;
run;

proc print data=use_AB;
proc print data=use_BA;
run;


data use_CD;
	set use;
	where sequence=3 and side='Left';
run;

proc sort data=use_CD;
by randnum;
run;

data use_CD;
	set use_CD;
	NCD=_n_;
run;

data use_CD;
	set use_CD;
	if NCD>25 then delete;

data use_DC;
	set use;
	where sequence=4 and side='Left';
run;

proc sort data=use_DC;
by randnum;
run;

data use_DC;
	set use_DC;
	NDC=_N_;
run;

data use_DC;
	set use_DC;
	if nDC>25 then delete;
run;

proc print data=use_cd;
proc print data=use_dc;
run;


data all;
	set use_AB use_ba use_cd use_dc;
run;

proc sort data=all;
	by randno;
run;

ODS RTF FILE="C:\Documents and Settings\ti4224\My Documents\My Work\Crb\11-01-004-SSS-19\11\IMAC Subset Randomization.doc";

proc print data=all label;
title 'CRB 11-01-004 Imac Subset Randomization'; 
var randno;
label randno='Product Number';
run;

ODS RTF CLOSE;
RUN;

proc freq data=all;
	tables sequence;
run;
