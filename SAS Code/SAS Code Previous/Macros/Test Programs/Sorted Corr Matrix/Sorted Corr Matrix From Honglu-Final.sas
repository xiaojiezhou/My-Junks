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
  var &varlist;
 run;

proc sql noprint;
	create table outcorr as
		select a.*,case when label='' then a._name_ else label end as variable from 
		outcor as a, ContentOut as b where a._name_=b.name order by &key desc;
	select _name_ into :lst2 separated by ' ' from outcorr;
	select count(*) into :n from outcorr;
quit;

 proc print data=outcorr label;
  var _name_ &lst2;
  format &lst2 4.2;
 quit;

***** print out result ******;
%macro out();
ods tagsets.excelxp file="&path\CorrOut.xml" style=journal ;
	title "Correlation Matrix";
	proc report nowd data=outcorr ;
			columns variable &lst2;
			define variable /display width=50;
			%do k=1 %to &n;
				define %scan(&lst2,&k) / display f=4.2;
				compute %scan(&lst2,&k);
					if %scan(&lst2,&k)=1 then call define(_col_,'style',"style=[background=black]");
						else if 0.7<=%scan(&lst2,&k) then call define(_col_,'style',"style=[background=red]");
						else if 0.5<=%scan(&lst2,&k) then call define(_col_,'style',"style=[background=orange]");
						else if 0.4<=%scan(&lst2,&k) then call define(_col_,'style',"style=[background=lilac]");
				endcomp;
			%end;
	run;
ods tagsets.excelxp close;
%mend;

%out;
	
