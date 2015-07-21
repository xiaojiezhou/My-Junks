/**************************************************************/
/*  Purpose:  Shorten the variable label by Removing aeious   */
/*            from the dataset label                          */
/**************************************************************/

%macro ShortenLabel(
/*--------------------------------------------------------------------------------------*/
		InData=,
		OutData=
);
/*--------------------------------------------------------------------------------------*/
ods listing close;

proc contents data=&InData varnum;
	ods select position;
	ods output position=var_list(keep=variable label format);
run;

data var_list;
	set var_list;
	label1=tranwrd(trim(left(label)),'After Use', 'AU');
	label1=tranwrd(trim(left(label1)),'After use', 'AU');
	label1=tranwrd(trim(left(label1)),'after use', 'AU');
	label1=tranwrd(trim(left(label1)),'after Use', 'AU');
	label1=tranwrd(trim(left(label1)),'a ', '');
	label1=tranwrd(trim(left(label1)),'A ', '');
	label1=tranwrd(trim(left(label1)),'The ', '');
 	label1=tranwrd(trim(left(label1)),'the ', '');
	label1=tranwrd(trim(left(label1)),'Being ', '');
 	label1=tranwrd(trim(left(label1)),'being ', '');
	label1=tranwrd(trim(left(label1)),' To', ' 2');
 	label1=tranwrd(trim(left(label1)),' to', ' 2');
	k=1;
	tmp=scan(label,k);
	label2=label1;
	do while( tmp ne '');
		if substr(tmp,3) ne ''
			then
				tmp2=substr(tmp,1,1)||compress(substr(tmp,2),'aeiouAEIOU');
			else
				tmp2=tmp;
		label2=tranwrd(label2,trim(left(tmp)),trim(left(tmp2)));
		k=k+1;
		tmp=scan(label,k);
	end;
    label2=COMPBL(label2);
	drop k tmp tmp2 label1;
run;

proc sql;
	select count(*) into :num_var from var_list;
	select variable into :var1-:var%trim(%left(&num_var)) from var_list;
	select label2 into :l1-:l%trim(%left(&num_var)) from var_list;
quit;

data &OutData;
	set &InData;
	%do i = 1 %to &num_var;
		label &&var&i ="&&l&i";
	%end;
run;
ods listing;
%mend;

/****************

%let SPSSDatain=Y:\FC_CMK\2008\Web Enable DQ Impact\Data\AU GM Impact.sav;

proc import datafile="&SPSSDataIn" out=one dbms=sav replace;
run;


%ShortenLabel(
                SASDataIn=one,
                SASDataOut=tmp);

proc contents data=_tmp varnum;
	ods select position;
	ods output position=var_list(keep=variable label format);
run;
*****************/
