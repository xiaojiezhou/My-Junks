*********************************************************************;
*  Filename: freq1way.sas                                            ;
*********************************************************************;
/******* Examples **********;

data junk;
      input x1 x2 $ x3 $ x4 $ x5;
      cards;
1     yes   female      A     1
1     yes   male  B     2
0     no    male  C     3
1     no    male  B     2
0     no    female      B     3
1     no    female      C     2
0     no    male  A     1
1     no    male  A     2
0     yes   male  A     2
1     yes   female      B     1
0     no    female      C     3
1     yes   male  B     3
1     yes   male  B     1
1     yes   male  C     2
1     yes   female      A     3
0     yes   male  A     3
1     yes   male  C     2
0     no    female      C     1
1     no    female      C     1
1     yes   male  A     2
0     yes   male  B     3
1     no    male  A     2
;
run;

%include "C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\freq1way.sas";
%freq1way(indata=junk,varlist=x1 x2 x3 x4 x5,levelrmlst=0 no, outdata=junkout);
********End of Example********/


%macro freq1way(indata=, varlist=, levelrmlst=, outdata=);
data &outdata; set _null_; run;

      proc contents data=&indata(keep=&varlist) out=ContentOut(keep=name label) varnum; run;

      proc sql noprint;
            select count(distinct name) into :n from ContentOut ;
		    select name into :lst separated by ' ' from ContentOut ;
			%put ****** &lst ******;
			run;

%do j=1 %to &n;
      proc freq data=&indata noprint;
            table %scan(&lst,&j)/out=out;
      run;

      data out(drop=%scan(&lst,&j));
            set out;
            length VALUE VARIABLE $20;
            variable="%scan(&lst,&j)";
            value=compress(%scan(&lst,&j));
            if value not in (%do i=1 %to %sysfunc(countw(&levelrmlst)); "%scan(&levelrmlst,&i)" %end;) ; 
      run;

      data &outdata;
        set &outdata out;
      run;
%end;
proc print data=&outdata;
      id variable;
      by variable;
      var value count percent;
      format percent 6.2;
run;

%mend;



