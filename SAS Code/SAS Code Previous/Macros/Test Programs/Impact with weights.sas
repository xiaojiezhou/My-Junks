
options ps=54 ls=135;
**********Import file************;
%macro importdata(path=,infile=);
PROC IMPORT OUT= WORK.temp 
            DATAFILE= "&path\&infile" 
            DBMS=SAV REPLACE;
RUN;
%mend;
%importdata(path=C:\Documents and Settings\tx3950\Desktop\CMK\CMK HomeCare\2010\Dish\UnitDose\Data,
            infile=US101684_cleaned.sav);


proc format; 
  value Sample
    1='ActionPcs-Grp5'
    2='Powerball-Grp6'
    3='Complete-Grp7'
    4='Quantum-Grp8'
    ;
run;

data Vimpact(keep=groups upurint ratprod fv: uf: uniq_id wt ); 
set temp(where=(upurint^=.) drop=fvun: ufun:); 
length uniq_id $12.;
uniq_id=substr(serial,1,12);
wt=1;
format groups Sample.;
run;

proc contents data=VImpact   varnum; 
run;

%include "C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\Vimpact.sas";

%Vimpact(indata=VImpact, resp=upurint, cmmnt_var=fv: uf:, product=groups, uniq_id=uniq_id, weight=wt,
         exppath=C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\Test Programs\Junk);

* proc print data=pct; run;
proc print data=pct; where index(label,"Undup")>=1; run;
