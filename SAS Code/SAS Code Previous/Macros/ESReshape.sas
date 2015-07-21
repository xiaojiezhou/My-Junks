***********************************************************************;
* Author: John Dunavent                                                ;
* Purpose: Reshape Equity Scan Data                                    ;
***********************************************************************;


options nodate nonumber nospool missing=" " nofmterr;

%macro ESReshape(
	var=%str(),
	sasdatain=,
	sasdataout=,
	maxVarLength=6,
	removeLabels=%str();
);

%local string temp i k p mp m nVars currentVar currentFmt nObs arrayLength;
%let var=%upcase(&var);
%let i=1;
%let temp=%qscan(&var,&i,%str( ));
%let string=%str();
%do %until(&temp=%str());
	%if &temp=%str(<K>) %then %do;
		%let k=&k &string;
		%let string=%str();
	%end;
	%else %if &temp=%str(<P>) %then %do;
		%let p=&p &string;
		%let string=%str();
	%end;
	%else %if &temp=%str(<MP>) %then %do;
		%let mp=&mp &string;
		%let string=%str();
	%end;
	%else %if &temp=%str(<M>) %then %do;
		%let m=&m &string;
		%let string=%str();
	%end;
	%else %let string=&string &temp;
	%let i=%eval(&i+1);
	%let temp=%qscan(&var,&i,%str( ));
%end;

%let var=%sysfunc(tranwrd(&var,<K>,%str()));
%let var=%sysfunc(tranwrd(&var,<P>,%str()));
%let var=%sysfunc(tranwrd(&var,<M>,%str()));
%let var=%sysfunc(tranwrd(&var,<MP>,%str()));

%let i=1;
%let nVars=&i;
%do %until(%qscan(&var,&i,%str( ))=%str());
	%let i=%eval(&i+1);
%end;
%let nVars=%eval(&i-1);

%put;
%put NOTE: (MACRO) nVars=&nvars; %put;
%put NOTE: (MACRO) VAR=&var; %put;
%put NOTE: (MACRO) K=&k; %put;
%put NOTE: (MACRO) P=&p; %put;
%put NOTE: (MACRO) M=&m; %put;
%put NOTE: (MACRO) MP=&mp; %put;

proc datasets library=work nolist;
	delete new temp final;
quit;

data new;
 set &sasdatain;
 run;

proc contents data=new;
	ods listing close;
	ods output variables=vars (keep=num variable label format);
	run; ods listing;
proc sort data=vars;
	by num;
data new;
	set new end=islast;
	order=_N_;
	if islast then call symput("nObs",_N_);
data final;
	length order 8. trt $64.;
	do order = 1 to &nObs;
		output;
	end;
run;

%do i = 1 %to &nVars;
	%let currentVar=%qscan(&var,&i,%str( ));
	%let currentFmt=%str();
	/* Keep Variable */
	%if %index(&k,&currentVar)^=0 %then %do;
		data _null_;
			set vars;
			if upcase(variable)="&currentVar" then do;
				if format^="" then call symput("currentFmt",strip(format));
			end;
		data final;
			merge final new (keep=order &currentVar);
			by order;
			format &currentVar;
			%if &currentFmt^=%str() %then %do;
				%unquote(&currentVar)_WL=put(&currentVar,&currentFmt);
				call symput("temp",vlabel(&currentVar));
			%end;
		run;
		%if &currentFmt^=%str() %then %do;
			data final;
				set final;
				label %unquote(&currentVar)_WL="&temp";
			run;
			%if %index(%upcase(&removeLabels),%upcase(&currentVar))^=0 %then %do;
				data final;
					set final (drop=%unquote(&currentVar)_wl);
				run;
			%end; %else %do;
				data final;
					set final (drop=%unquote(&currentVar) rename=(%unquote(&currentVar)_wl=%unquote(&currentVar)));
				run;
			%end;
		%end;

	%end;
	/* Merge columns without products */
	%else %if %index(&m,&currentVar)^=0 %then %do;
		data temp;
			set vars;
			if upcase(substr(variable,1,length("&currentVar")))=upcase("&currentVar");
		data _null_;
			length temp $512.;
			retain temp "";
			set temp end=islast;
			temp=strip(temp)||" "||strip(lag(variable));
			if islast then do;
				temp=strip(temp)||" "||strip(variable);
				call symput("temp",strip(temp));
				call symput("arrayLength",strip(_N_));
			end;
		data temp (keep=order &currentVar %unquote(&currentVar)_wl);
			set new (keep=order &temp);
			length &currentVar 8. %unquote(&currentVar)_WL $256.;
			array _array_ &temp;
			do i = 1 to &arrayLength;
				if _array_[i]=1 then do;
					&currentVar=i;
					%unquote(&currentVar)_WL=vlabel(_array_[i]);
				end;
			end;
		run;
		%if %index(%upcase(&removeLabels),%upcase(&currentVar))^=0 %then %do;
			data temp;
				set temp (drop=%unquote(&currentVar)_wl);
			run;
		%end; %else %do;
			data temp;
				set temp (drop=%unquote(&currentVar) rename=(%unquote(&currentVar)_wl=%unquote(&currentVar)));
			run;
		%end;
		data final;
			merge final temp;
			by order;
		run;
	%end;
	/* Remove product names from columns (no merge though) */
	%else %if %index(&p,&currentVar)^=0 %then %do;
		data temp (drop=temp);
			length trt $64.;
			set vars;
			if upcase(substr(variable,1,length("&currentVar")))=upcase("&currentVar");
			if substr("&currentVar",length("&currentVar"))="_" then
				trt=strip(substr(variable,length("&currentVar")+1));
			else trt=strip(substr(variable,length("&currentVar")+2));
			temp=strip(reverse(scan(reverse(upcase(trt)),1,"_")));
			if substr(temp,1,6)="COLUMN" or substr(temp,1,5)="COLUM" or substr(temp,1,4)="COLU" or
				substr(temp,1,3)="COL" or substr(temp,1,2)="CO" or substr(temp,1,1)="C" then
				trt=substr(trt,1,min(length(trt)-length(temp)-1,32-(&maxVarLength+1+3)));
			else trt=substr(trt,1,32-(&maxVarLength+1+3));
		proc sort data=temp;
			by trt;
		data temp (keep=trt newvar variable format label);
			length newVar $64.;
			set temp;
			by trt;
			retain temp;
			temp=temp+1;
			if first.trt then temp=1;
			newVar="&currentVar._col"||strip(temp);
		proc transpose data=new out=temp2 (drop=_label_ rename=(_name_=variable));
			by order;
			var &currentVar.:;
		proc sort data=temp;
			by variable;
		proc sort data=temp2;
			by variable;
		data temp;
			merge temp temp2;
			by variable;
		proc sort data=temp;
			by order trt variable;
		proc transpose data=temp out=temp (drop=_name_);
			by order trt;
			id newvar;
			idlabel label;
			var col1;
		data final;
			merge final temp;
			by order;
		run;
	%end;
	/* Remove product names from columns and merge columns */
	%else %if %index(&mp,&currentVar)^=0 %then %do;
		data temp (drop=temp);
			length trt $64.;
			set vars;
			if upcase(substr(variable,1,length("&currentVar")))=upcase("&currentVar");
			if substr("&currentVar",length("&currentVar"))="_" then
				trt=strip(substr(variable,length("&currentVar")+1));
			else trt=strip(substr(variable,length("&currentVar")+2));
			temp=strip(reverse(scan(reverse(upcase(trt)),1,"_")));
			if substr(temp,1,6)="COLUMN" or substr(temp,1,5)="COLUM" or substr(temp,1,4)="COLU" or
				substr(temp,1,3)="COL" or substr(temp,1,2)="CO" or substr(temp,1,1)="C" then
				trt=substr(trt,1,min(length(trt)-length(temp)-1,32-(&maxVarLength+1+3)));
			else trt=substr(trt,1,32-(&maxVarLength+1+3));
		proc sort data=temp;
			by trt;
		data temp (keep=trt newvar variable format label);
			length newVar $64.;
			set temp end=islast;
			by trt;
			retain temp;
			temp=temp+1;
			if first.trt then temp=1;
			newVar="&currentVar._col"||strip(temp);
			if islast then call symput("arrayLength",strip(temp));
		proc transpose data=new out=temp2 (drop=_label_ rename=(_name_=variable));
			by order;
			var &currentVar.:;
		proc sort data=temp;
			by variable;
		proc sort data=temp2;
			by variable;
		data temp;
			merge temp temp2;
			by variable;
		proc sort data=temp;
			by order trt variable;
		proc transpose data=temp out=temp (drop=_name_);
			by order trt;
			id newvar;
			idlabel label;
			var col1;
		data temp (keep=order trt &currentVar %unquote(&currentVar)_wl);
			set temp (keep=order trt %unquote(&currentVar)_col1-%unquote(&currentVar)_col&arrayLength);
			length &currentVar 8. %unquote(&currentVar)_WL $256.;
			array _array_ %unquote(&currentVar)_col1-%unquote(&currentVar)_col&arrayLength;
			do i = 1 to &arrayLength;
				if _array_[i]=1 then do;
					&currentVar=i;
					%unquote(&currentVar)_WL=vlabel(_array_[i]);
				end;
			end;
		run;
		%if %index(%upcase(&removeLabels),%upcase(&currentVar))^=0 %then %do;
			data temp;
				set temp (drop=%unquote(&currentVar)_wl);
				if %unquote(&currentVar)=6 then %unquote(&currentVar)=.;
				else %unquote(&currentVar)=25*(5-%unquote(&currentVar));
			run;
		%end; %else %do;
			data temp;
				set temp (drop=%unquote(&currentVar) rename=(%unquote(&currentVar)_wl=%unquote(&currentVar)));
			run;
		%end;
		data final;
			merge final temp;
			by order;
		run;
	%end;
%end;

data &sasdataout;
 set final;
 run;

%mend;

****************************************************
<k>	The variable is simply kept with value labels

<m>	All variables in the .sav file that start with the same characters as the output variable are merged.  
The output value is the label of the corresponding selected column (the column with a 1 and not a 0).  
For instance: columns NUMCHLD1-NUMCHLD8 will be merged as numchld and labels will be retained.  
I imagine that this tag will apply to demographic-type questions where it is only possible to select 1 response.  
Also, these variables do not include product names in them.

<p>	These variables will not be merged.  All that is done to variables with the <p> tag is to remove the product 
names from them.  Output variables are just 1s or 0s.  I imagine these to be “Select all that apply” type 
questions that have DIFFERENT RESPONSES FOR EACH PRODUCT.

<mp> These variables will be merged and have the product names removed.  Output values will by default 
be the column label that had a non-zero entry in the .sav file.

Only these 4 tags can be used, uppercase and lowercase will work the same.  Labels can be removed from 
the <k>, <m> and <mp> variables using the last input parameter: REMOVELABELS.  

Any of the output variables in this list will have the value labels removed.  
<mp> variables in this list will be recoded as col1->100, col2->75, col3->50, 
col4->25, col5->0 and col6->empty cell.
****************************************************;

/******Example
%include "C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\Reshape.sas";
libname sasout "C:\Documents and Settings\tx3950\Desktop\CMK\CMK HomeCare\2010\Dish\EquityScan BBN\Data";
%ESReshape(
    var=%str(segment<k> value att <p>),
    removeLabels=%str(),
    sasdatain=one,
    sasdataout=ESReshaped
);

data temp; set ESreshaped;  format _all_ ; run;
**********/
