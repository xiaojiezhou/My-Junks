***************************************************************************************;
*  Purpose:  Create a dataset that contains 1way mean value of various class variables ;
*  Created by: Xiaojie Zhou                                                            ;
***************************************************************************************;

/******  Example  *************;
%include "C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\Mean1way.sas"    ;

data one(drop=i);
 do i=1 to 20;
  c1=int(uniform(1231)*2);
  c2=int(uniform(124)*2);
   f1=normal(12);
   f2=normal(12);
   f3=normal(12);
   output;
 end;
proc print data=one;run;
proc means data=one mean; var f:; class c:; ways 1; run;

%mean1way(indata=one, varlist=f:, classlist=c:, levelrmlst=0, outdata=two) ;

*********/

%macro mean1way(indata=, varlist=, classlist=, levelrmlst=, outdata=) ;
  proc contents data=&indata(keep=&Classlist) out=ContentClasslist(keep=name label) varnum noprint; run;
  proc contents data=&indata(keep=&varlist) out=ContentVarlist(keep=name label) varnum noprint; run;

  proc sql noprint;
    select count(distinct name) into :n from ContentClasslist ;
    select name into :clst separated by ' ' from ContentClasslist ;
	%put ****** &lst ******;
	select name into :varlist separated by ' ' from ContentVarlist;
	%put ******* &varlist *******;
	run;


  data &outdata; set _null_; run;
  %do j=1 %to &n;
    proc means data=&indata nway mean noprint;
      var &varlist;
      class %scan(&clst,&j);
      output out=out mean=&varlist;
    run;

    data out(drop=%scan(&clst,&j));
        set out;
        length VALUE VARIABLE $20;
        variable="%scan(&clst,&j)";
        value=compress(%scan(&clst,&j));
        if value not in (%do i=1 %to %sysfunc(countw(&levelrmlst)); "%scan(&levelrmlst,&i)" %end;) ; 
    run;

  data &outdata;
    set &outdata out; run;
  %end;
  Proc print data=&outdata; run;
%mend;
run;
