
*************************************************************************************************;
*   Author:  Xiaojie Zhou
*     Date:  Nov 2, 2010
*  Purpose:  This macro add a varaible Quadrant to the input dataset
*            Quadrant=1: Above average for XVar & YVar;
*            Quadrant=2: Below avg for XVar & above avg for YVar;
*            Quadrant=3: Below avg for both XVar & YVar;
*            Quadrant=4: Above avg for HVar, below avg for YVar;
*************************************************************************************************;
proc format;
value Quadrant
1="Abv Avg XVar, Abv Avg YVar"
2="Blw Avg XVar, Abv Avg YVar"
3="Blw Avg XVar, Blw Avg YVar"
4="Abv Avg XVar, Blw Avg YVar"
;

%Macro Quadrant(Indata=,XVar=, YVar=, Quadrant=);

proc sql;
 select mean(&XVar), mean(&YVar) into: Avg_XVar, :Avg_YVar
 from &Indata;
quit;

data &Indata;
 set &Indata;
      if &XVar GE &Avg_XVar and &YVar GE &Avg_YVar then &Quadrant=1;
 else if &XVar LT &Avg_XVar and &YVar GE &Avg_YVar then &Quadrant=2;
 else if &XVar LT &Avg_XVar and &YVar LT &Avg_YVar then &Quadrant=3;
 else if &XVar GE &Avg_XVar and &YVar LT &Avg_YVar then &Quadrant=4;
 format &Quadrant Quadrant.;
run;

%Mend;
