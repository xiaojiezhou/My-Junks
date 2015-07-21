
%let cmmnt_var=fcun: ucun: ;
%let resp=upurint;
%let product=ulegs;
%let uniq_id=uniq_id;

**********Import file************;
%let path=C:\Documents and Settings\tx3950\Desktop\CMK\2009\NA08K052\VComments\Data;
%let infile=NA08K052_VComments.sav;
PROC IMPORT OUT= WORK.one (keep= &resp &cmmnt_var perform relprice 
uliking uvalue udistin relcat ugroup ulegs uquotas uniq_id
)
            DATAFILE= "&path\&infile" 
            DBMS=SAV REPLACE;
RUN;
proc format;
value &product
1='Tide'
2='Gain'
3='All'
4='Sun'
5='Xtra'
6='TideAP'
7='Krklnd'
8='KrklndEnv'
9='GainDnc'
10='MembersM'
;

data one; set one; format &product &product..; run;

*********Transpose data*********;
proc sort data=one; by uniq_id;
proc transpose data=one out=two(rename=(_Name_=Name _label_=Label)) prefix=Resp;
var &cmmnt_var;
by &uniq_id &product &resp  ;
run;

*************Calculate % response with V Comments*********;
ods output crossTabFreqs=pct_all;
ods listing close;
proc freq data=two ;
table name*label*resp1/nopercent nocol;
run;
ods output crossTabFreqs=pct_bylegs;
proc freq data=two ;
table &product*name*resp1/nopercent nocol;
run;
proc sort data=two; by name;
ods output SolutionF=SolutionF;
proc mixed data=two noinfo noitprint noprofile noclprint;
model &resp =resp1/s;
by name;
run;
ods listing;

proc sort data=pct_bylegs;
by name &product;
where (_type_='111' and resp1=1 and rowpercent^=.);
run;
proc transpose data=pct_bylegs out=temp1 prefix=P_;
var rowpercent ;
by name ;
id &product;
run;

data pct;
 merge pct_all(where=(_type_='111' and resp1=1 and rowpercent^=.)  )
	   solutionF(where=(Effect='Resp1') )       
       temp1
;
by name;
rename frequency=N rowpercent=Pct estimate=Effect;
 drop table resp1 _type_ _table_ missing _name_ _label_ effect stderr df tvalue;
label=TRANWRD(label,'Undup ', '');
label=TRANWRD(label,'Undup. ', '');
label=TRANWRD(label,'Comments ', '');
run;


data pct1(drop=P_:);
 set pct;
 array p{10} P_Tide	P_Gain	P_All	P_Sun	P_Xtra	P_TideAP	P_Krklnd	P_KrklndEnv	P_GainDnc	P_MembersM;
 array Index{10} I_Tide	I_Gain	I_All	I_Sun	I_Xtra	I_TideAP	I_Krklnd	I_KrklndEnv	I_GainDnc	I_MembersM;
do i=1 to 10;
 if p[3]>0 then index[i]=100*p[i]/p[3];
 end;
 run;

 proc print data=pct1;
run;


/********************
PROC EXPORT DATA= WORK.pct1
            OUTFILE= "C:\Documents and Settings\tx3950\Desktop\CMK\2009\NA08K052\VComments\Results\UndupImpact.xls" 
            DBMS=EXCEL REPLACE;
			Sheet="&cmmnt_var._&resp"; 
RUN;
***************/
