**********************************************************;
* Purpose:  This macro calculate the MSE of two variables ;
**********************************************************;
%put "*****  Syntax: mse(indata=one, y1=resp, y2=pred, by= by prodleg, outdata=temp) ***** ";

%macro mse(indata=, Y1=, Y2=, by=, outdata=);
ods listing;
data t1;
 set &indata;
 Diff2=(&y1-&Y2)*(&Y1-&Y2);
 Diff1=abs(&y1-&Y2);
 ;
 proc means data=t1 N Mean  noprint;
  &by;
 var Diff2;
 output out=out1 Mean=MSE ;
 run;

 proc means data=t1 N Median  noprint;
  &by;
 var Diff1;
 output out=out2 Median=Median_AE Mean=Mean_AE ;
 run;

 data &outdata;
  merge out1 out2;
  &by;
  RMSE=sqrt(MSE);
  run;
 ods listing close;
%mend;
