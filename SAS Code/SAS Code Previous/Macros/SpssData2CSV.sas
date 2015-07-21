%macro SpssData2CSV(path=, dataInFile=, resultDirectory=, CSVFileName=);
*------------------------------------------------------------*;
* this macro read a SPSS file &dataInFile from &path;
*
*		to create a CSV file from the SPSS  dataset;
*------------------------------------------------------------*;
* last modified:	12 Jan 2009
*------------------------------------------------------------*;

*--- read the SPSS .sav file ---*;
proc import datafile="&path.\&dataInFile"
				  out=tmp1
				  dbms=sav
				  replace;
run;

data tmp1;
	set tmp1;
	format _all_;
run;

proc export data=tmp1
	outfile = "&resultDirectory.\&CSVFileName"
	dbms=csv replace;
run;

proc datasets lib=work nolist;
	delete tmp1;
run; quit;

%mend;
