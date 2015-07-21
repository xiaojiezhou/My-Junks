%put "***************************************************************************************";
%put "** Purpose:  This macro rename and relabel the a dataset";
%put "** parameters:";
%put "		- DataIn: SAS data to be renamed and relabeled.   ";
%put "		- DataSpec: SAS data which has at least 4 variables:  OldVarName, NewVarName, OldLabel, NewLabel";
%put " 	    - DataOut: The output SAS file with newVarName and NewLabel. ";
%put "To call macro:   include 'Q:\beauty_care\clinical\Biometrics\XiaojieZhou\Macros\RenameRelabel.sas';  ";
%put "                 rename_relabel(DataIn=datain, DataSpec=dataspec, DataOut=dataout);  "; 
%put "***************************************************************************************";

*************************************************************************************************;;
;

options mlogic symbolgen;

%macro rename_relabel(DataIn=, DataSpec=, DataOut=);


data &Dataout;
 set &DataIn;
 run;

 
proc contents data=&DataOut varnum;
  ods output position=var_list(keep=variable label format);
run;

proc sql;
 create table DataSpec as
 select a.*, b.label
 from &DataSpec as a left join var_list as b
 on a.OldVarName=b.Variable;

data dataspec;
 set DataSpec;
 length NewLabel $200.;
 if NewVarName = " " then NewVarName=OldVarName;
 if NewLabel="" then NewLabel=OldLabel;
 if NewLabel="" then Newlabel=Label;
run;

proc sql noprint;
select count(NewVarName) into: nNewVars 
	from dataspec ;
select count(OldVarName) into: nOldVars 
	from dataspec ;
select OldVarName into: oldvars separated by ' '
	from dataspec ;
quit;
%put &oldvars**&nnewvars**&noldvars;


*Get the names of old variables and names & labels for new variables
   and remame and label old variables;
proc sql noprint ;
select OldVarName into :oldvar1-:oldvar%trim(%left(&nOldVars))
from dataspec;
select OldLabel into :oldvarL1-:oldvarL%trim(%left(&nOldVars))
from dataspec;
select NewVarName into :newvar1-:newvar%trim(%left(&nNewVars))
from dataspec;
select NewLabel into :newvarL1-:newvarL%trim(%left(&nNewVars))
from dataspec;
quit;

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
	&&newvar&i. ="&&newvarL&i"
%end;
;
quit;

%mend rename_relabel;
options mlogic symbolgen;


