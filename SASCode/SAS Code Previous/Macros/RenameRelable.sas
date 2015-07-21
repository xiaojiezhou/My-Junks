**********************************************************************************************************************;
**********************************************************************************************************************;
options mlogic symbolgen;
%macro VarsInSPSS_2(datain=, dataspec=, DataOut=);
* Rename & relabel the variables. flag variables with wrong 'recoded' values;
 data dataspec;
 length tempname $400 ;
 set &dataspec end=eof;
 if New_VarName = " " then New_VarName=VarName;
 if New_VarLabel=" " then New_VarLabel=VarLabel;
 recoded=upcase(recoded);

 if (recoded not in ('P','N')) & (recoded ^= ' ') then flag=1;
 else if (recoded ^= ' ') then flag=0;
 
 if flag^= . then tempname=compress(New_VarName||left(trim(recoded)));
 else tempname=New_VarName;
run;


proc sql noprint;
select count(tempname) into: nNewVars 
	from dataspec ;
select count(VarName) into: nOldVars 
	from dataspec ;
select VarName into: oldvars separated by ' '
	from dataspec ;
quit;

* Number of old variables and new variables should be the same in Excel file;
%if %eval(&nNewvars) ne %eval(&nOldvars) %then 
	%do;
      %put ERROR: Number of Old variables is different from Number of new variables in Excel file.;
	  %put ERROR: Exiting the program.;
      %goto exit;
	%end;

*Get the names of old variables and names & labels for new variables
   and remame and label old variables;
proc sql noprint ;
select VarName into :oldvar1-:oldvar%trim(%left(&nOldVars))
from dataspec;
select tempname into :newvar1-:newvar%trim(%left(&nNewVars))
from dataspec;
select New_VarLabel into :newvarL1-:newvarL%trim(%left(&nNewVars))
from dataspec;
quit;

data &DataOut;
set &Datain(keep=&oldvars);
run;

proc datasets lib=work nolist;
modify &DataOut;
rename
%do i=1 %to &nOldVars.;
	%if &&oldvar&i ^= &&newvar&i. %then
		%do; 
			&&oldvar&i=&&newvar&i.
		%end;
%end;
;
label
%do i=1 %to &nOldVars.;
	&&newvar&i="&&newvarL&i."
%end;
;
quit;


* Start Recoding variables;
proc sql noprint;
	select sum(flag) into: flagcode
		from dataspec;
quit;

*If there are recoding values other than P or N
  stop program and display these values with their variables;

%if &flagcode > 0 %then 
	%do;
      %put ERROR: The following values for column RECODED should only be P, N or left blank.;
	  data _null_;
	  	set dataspec;
		if flag >0 then put New_VarName= Recoded= ;
	  run;
	  %put ERROR: Exiting the program.;
      %goto exit;
	%end;

%else 
	%do;
	*Get the variables to be recoded and their recoding values;
		proc sql noprint;
			select tempname into: recodvars separated by ' '
				from dataspec
				where (substr(tempname, length(tempname))='P') | (substr(tempname, length(tempname))='N');

			select count(tempname) into: nrecode 
				from dataspec
				where (substr(tempname, length(tempname))='P') | (substr(tempname, length(tempname))='N') ;
		quit;
		
	* Recode if there are recoding values requested.
	  Remove the SPSS format.
	  If there are character variable with requested coding
	  stop the program and display them in the log.
	  Otherwise, reocde.
	 ;	
		%if &Nrecode^=0 %then 
			%do;
				data &DataOut;
				set &Dataout;
				format &recodvars;
				run;
				proc contents data=&DataOut out=recodconts (keep=name label varnum type) noprint;
				run;
				proc sql noprint;
					select count(name) into: nrecnonum 
						from recodconts
						where ((substr(name, length(name))='P')|(substr(name, length(name))='N')) & type^=1;
					select quote(compress(name)) into: recodnonum separated by ','
						from recodconts
						where ((substr(name, length(name))='P')|(substr(name, length(name))='N')) & type^=1;
				quit;
				%if &nrecnonum^=0 %then 
					%do;
				      %put ERROR: The following variables can not be recoded because they are not numeric.;
					  data _null_;
					  	set dataspec;
						if tempname in (&recodnonum);
						put New_varName=  Recoded= ;
					  run;
					  %put ERROR: Exiting the program.;
				      %goto exit;
					%end;

				%else
				%do i=1 %to &nrecode;
					%let recodvar&i = %scan(&recodvars,&i,%str( ));
					proc means data=&DataOut noprint;
					var &&recodvar&i;
					output out=summrecod&i(drop=_type_ _freq_) min=min max=max ;
					run;
					data summrecod&i;;
						set summrecod&i;
						if _n_=1 then 
							do;
								call symput('min', left(trim(min)));
								call symput('max', left(trim(max)));
							end;
					run;

					data &DataOut(drop=min max);
						merge &DataOut(in=a) summrecod&i;
						%let origvar =  %substr(&&recodvar&i,1,%length(&&recodvar&i)-1);
						%if %substr(&&recodvar&i,%length(&&recodvar&i))=P %then 
							%do;
								&&recodvar&i=100*((&&recodvar&i-&min)/(&max-&min));
							%end;
						%if %substr(&&recodvar&i,%length(&&recodvar&i))=N %then 
							%do;
								&&recodvar&i=100*((&max-&&recodvar&i)/(&max-&min));
							%end;
						rename &&recodvar&i = %substr(&&recodvar&i,1,%length(&&recodvar&i)-1);
					run;
					proc datasets lib=work nolist;
					delete summrecod&i;
					quit;
				%end;				*End loop for i;
			%end;					*End loop for Nrecode;
	%end;							*End loop for flagcode;

%exit: 
proc datasets lib=work nolist;
	delete dataspec recodconts;
quit;
%mend VarsInSPSS_2;
options nomlogic nosymbolgen;


