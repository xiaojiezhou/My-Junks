%macro SpssDataContent(path=, dataInFile=, resultDirectory=, txtFileName1=, txtFileName2=);
*------------------------------------------------------------*;
* this macro read a SPSS file &dataInFile from &path;
*
*		to create a TXT file containing all variable names and labels, with the format
*	
*		USERIAL	AU-Respondent Serial Number
*		BKUMAIN	AU Main Breakout
*		BKT4BPI	Top 4 Box PI Breakout
*		BKT3BPI	Top 3 Box PI Breakout
*
*		and to create a TXT file containing all the details for all variables using user-defined format like,
*		
*		TIDCMTO.1=Tide Comtd	
*		TIDCMTO.2=Tide N/Comtd
*		TIDCMTO.3=Tide Rejector
*------------------------------------------------------------*;
* last modified:	12 Jan 2009
*------------------------------------------------------------*;

*--- read the SPSS .sav file ---*;
proc import datafile="&path.\&dataInFile"
				  out=tmp1
				  dbms=sav
				  replace;
run;

*--- get a list of all variables in the dataset 	---*;
*--- stored in "list_all" 								---*;
proc contents data=work.tmp1 varnum;
	ods select position;
	ods output position=list_all;
run; quit;

data list_all_str;
	set list_all;
	str=trim(left(variable))||"="||trim(left(label));
	keep str;
run;

proc export data=list_all_str
	outfile = "&resultDirectory.\&txtFileName1"
	dbms=tab replace;
run;

*--- get all user-defined formats in WORK library ---*;
proc format library = work.formats 
				  cntlout = cntlout;
run;

proc sql;
*--- then select those belong to the dataset imported from .SAV ---*;
	create table list_userFormated as 
		select distinct a.num, a.Variable, a.Format, b.start, b.end, b.label
		from list_all as a, cntlout as b
		where trim(left(a.format)) eq trim(left(b.fmtname))||"."
		order by a.num
;
quit;

data list_userFormated_str;
	set list_userFormated;
	if trim(left(start)) eq trim(left(end))
		then fmt_str=trim(left(variable))||"."||trim(left(start))||"="||trim(left(label));
		else fmt_str=trim(left(variable))||"."||trim(left(start))||" to "||trim(left(end))||"="||trim(left(label));
	keep fmt_str;
run; 

proc export data=list_userFormated_str
	outfile = "&resultDirectory.\&txtFileName2"
	dbms=tab replace;
run;


proc datasets lib=work nolist;
	delete tmp1 List_userFormated List_userFormated_str cntlout List_all_str List_all;
run; quit;


%mend SpssDataContent;
