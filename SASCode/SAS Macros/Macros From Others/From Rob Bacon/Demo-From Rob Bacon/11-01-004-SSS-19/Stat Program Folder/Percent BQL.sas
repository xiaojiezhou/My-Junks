libname save 'C:\Documents and Settings\ti4224\My Documents\My Work\Crb\11-01-004-SSS-19\Stat Data Folder\';

data temp;
	set save.crb1101004_1a;
	if population notin ('Dandruff') then delete;
	if Evaluable ne 'Y' then delete;
	If BQL='NA' then delete;

run;

proc sort data=temp;
by TrtPair visitlabel;
run;

proc freq data=temp;
by TrtPair visitlabel;
tables TrtLabel*BQL*measure;
run;
