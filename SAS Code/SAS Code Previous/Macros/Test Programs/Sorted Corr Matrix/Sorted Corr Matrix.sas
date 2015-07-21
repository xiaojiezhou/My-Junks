options ls=135 ps=54;

%let path=C:\Documents and Settings\tx3950\Desktop\ITC\HomeCare\SurfaceCare Misc\2011\Nemoauce\From China\Data for BBN Zhou Xiaojie;
%let infile=cleaned.sav;
PROC IMPORT OUT= WORK.one
            DATAFILE= "&path\&infile" 
            DBMS=SAV REPLACE;
RUN;
proc contents data=one  out=ContentOut varnum; run;
proc print data=one(obs=10);
run;

%let indata=one;
%let key=ratprod;
%let varlist= cpi liking believe value distinc uvalue agrswise agrwpay rat:;

 proc corr data=&indata noprint out=outcor(where=(_type_='CORR'));
  var &key &varlist;
 run;
 proc sort data=outcor out=outcorr;
  by descending &key;
 run;

 proc sql noprint;
  select _name_ into :lst2 separated by ' '
from outcorr;
 quit;
 ods csv;
 proc print data=outcorr label;
  var _name_ &lst2;
  format &lst2 4.2;
 quit;
ods csv close;

***** print out result ******;
ods tagsets.excelxp file="&path\CorrOut.xml" style=journal ;
	title "Correlation Matrix";
	ods tagsets.excelxp options(sheet_name="&j) &&grp&j" absolute_column_width="9");

		proc sql;
			create table temp as
			select a.*,case when label='' then a._name_ else label end as variable from 
				(select * from outr where _type_='CORR' and gcode=&j) as a, lst as b 
				where a._name_=b._name_ order by id;
		quit;

		proc report nowd data=temp;
			columns variable &resp;
			define variable /display width=50;
			%do k=1 %to &ny;
				define %scan(&resp,&k) / display;
				compute %scan(&resp,&k);
					if %scan(&resp,&k)=1 then call define(_col_,'style',"style=[background=black]");
					%do p=1 %to %sysfunc(countw(&cut,' '));
						else if %scan(&cut,&p,' ')<=%scan(&resp,&k) 
						then call define(_col_,'style',"style=[background=%scan(&color,&p)]");
					%end;
				endcomp;
				label %scan(&resp,&k)="%scan(&resp,&k)";
			%end;
		run;
	
