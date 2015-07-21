%let CUSTOMCOLOR=Y;
%let style          = style.ColorStyleNewYes;    *  style.FontStyleArialNo style.ColorStyleNewYes style.ColorStyleNewNo;
%let CUSTOMCOLORLIST = cxBABC5C cxDE7E6F  /*cx7C95CA cxDE7E6F*/ cx66A5A0 CXA9865B cxB689CD cx94BDE1 cxCD7BA1 cxCF974B cx87C873 cxB7AEF1 cxDDD17E ;
* %let CUSTOMCOLORLIST   =cx99BF1A cx803009 cx808080 cx778CE1 CXA05000 CXCC0099 cx66A5A0 cxDE7E6F CXFFCC00; * customized colors for treatments, example %str(red blue green);
      *cx778CE1 light blue ; * cx99BF1A pale yellow  cxDE7E6F orange; *cx803009 strong reddish orange cx66A5A0 green; * cx808080 gray cxBABC5C yellowish-green;  *CXA05000 brown;* cxA9865B brown; *  CXFFCC00 yellow; *cxB090D0 purple  CXCC0099 pink;
* %let CUSTOMCOLORLIST = cx6B7DB5	cxD05B5B cx66A5A0 cxA9865B cxB689CD cxBDBE63 cx94BEE7 cxCE79A5 cxCF974B	cx87C873 cxB7AEF1 cxDDD17E ;
%let   CUSTOMCOLORLIST=   yellow blue orange  green;                 
****************************************************************************************;
****************************************************************************************;
** Example calls to the macro;
/*%let indata=plots_bl_4;*/
/*%let labelvar=measuresig;*/
/*%let valuevar=cfb;*/
/*%let grpvar=group;*/
/*%let minaxis=-1.5;*/
/*%let maxaxis=0.35;*/
/*%let step=0.31;*/
/*%let title= title "(BC_1-Pant_D) Treatment Effect on CFB";*/
/*%let footnote=footnote " * means pvalue<=0.05 , ** means 0.05< pvalue<=0.10";*/
**********************;
%macro SpiderPlots(indata=,labelvar=,valuevar=,grpvar=,minaxis=,maxaxis=,step=,title=,footnote=);
data indata;
 set &indata; run;
proc sort data=indata;
by &labelvar &grpvar;
run;

proc sql noprint;
select distinct (&labelvar), count(distinct &labelvar)
into: vars separated by ' ', :nvars
from indata;
select distinct (&grpvar), count(distinct &grpvar)
into: grps separated by ' ', :ngrps
from indata;
quit;

data axisparms;
x0=&minaxis;
xn=&maxaxis;
step=&step;
nmid=round(((xn-x0)/step)-1,1);
call symput('nmids',left(trim(nmid)));
run;
data axisparms;
set axisparms;
array x [&nmids] ;
do i=1 to &nmids;
	x[i]=x0+i*(step);
 end;
 keep x:;
run;

proc transpose data=axisparms out=axisparms;
run;
proc sort data=axisparms;
by col1;
run;

data axisparms;
length xc $10;
set axisparms;
by col1;
xc=cat('"',compress(col1),'"');
col2=(col1-&minaxis)/(&maxaxis-&minaxis);
if _n_=1 then xc='" "';
run;

proc sql noprint;
select xc
into: axis1tcks separated by " "
from axisparms;
select col2 into: starcircles separated by " "
from axisparms 
where xc^='" "';
quit;
%put &axis1tcks**&starcircles;

%if %length(&CUSTOMCOLORLIST)^=0 %then %do;
%let CUSTOMCOLORLIST=%qcmpres(&CUSTOMCOLORLIST);
%let mycolors=;
%do i=1 %to &ngrps;
%let mycolors=&mycolors %scan(&CUSTOMCOLORLIST,&i,&%str( ));
%end;
%put &mycolors;
%end;

data chartparms;
length wstars $200;
nvars=&nvars;
nvars_1=nvars-1;
ngrps=&ngrps;
wstars=repeat('2 ',nvars);
lstars=repeat('1 ',nvars);
staraxis=repeat('axis2 ',nvars_1);
call symput('wstars',left(trim(wstars)));
call symput('lstars',left(trim(lstars)));
call symput('staraxis',left(trim(staraxis)));
run;

proc sort data=indata;
by &labelvar &grpvar;
run;

goptions  noborder ftext="Albany  AMT/bolds" ctext=black ;
axis1 order=(&minaxis to &maxaxis by &step) WIDTH=1  MAJOR=NONE 
      value=(height=2.pct c=blue &axis1tcks) 
      label=(height=2.5pct) ;
axis2 order=(&minaxis to &maxaxis by &step) WIDTH=1  MAJOR=NONE 
      value=none split="|" 
      label=(height=2.5pct) ;

%let title=%str(&title);
&title;
&footnote;
proc gradar data=indata;
    chart &labelvar. /  
		sumvar=&valuevar.  
	    overlayvar=&grpvar.
	    wstars=&wstars.
	    lstars=&lstars.
		CSTARS=(&mycolors.)
	    starcircles=(&starcircles.)
		staraxis=(axis1 &staraxis)
	    starinradius=0
		staroutradius=100
		SPKLABEL=CATEGORY 
		noframe
 		/*STARLEGEND= NUMBER*/
	    cstarcircles=ltgray;
 run;
quit;
%mend SpiderPlots;
goptions reset=all;
title;
footnote;
