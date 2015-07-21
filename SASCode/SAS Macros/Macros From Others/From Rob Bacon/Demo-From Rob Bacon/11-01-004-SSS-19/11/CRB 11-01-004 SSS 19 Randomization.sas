******************************************************************************************
   	FILE	: Randomization for Split Scalp Studies.sas
   	CREATED	: 12/14/01
   	UPDATED	: 1/10/11
	VERSION	: 1.3
******************************************************************************************

   The following program creates a randomization for the split scalp studies.
   This program works for 1-4 treatment pairs.  If more treatment pairs are necessary make 
	adjustments where marked within the program.
   It will create three randomization files (SAS Data Set, Txt File, and Word Document).
   In order to make the Word Document fit in landscape, change Page Setup to landscape
    within SAS.

******************************************************************************************
       ONLY MAKE CHANGES BETWEEN THE TWO LINES OF STARS THAT FOLLOW   
******************************************************************************************;

%LET STUDY=CRB 11-01-004 SSS-19;	*Name of study CRB XX-XX-XXX;
%Let DIR=C:\Documents and Settings\ti4224\My Documents\My Work\Crb\11-01-004-SSS-19\11\; *Directory that all files created are saved to;
%LET RAND=RAND1101004;      	*Filename of randomization SAS Data Set;
%Let TXTBA=CRB1101004BA.Txt; *Filename of .Txt file;
%LET SEED=5478;	        	*4 digit random number - make different for each study;
%LET NUM=_N_+100;               *Defines lowest subject number - _N_=1 - For 101 use _N_+100;  
%LET BLOCKSIZE=4;    		*Number of different treatment Sequences being used; 
  	
%LET BLOCKS=45;        *(# of subjects)/(BLOCKSIZE) rounded up to the next whole number;

*****************************************************************************************************
       ONLY MAKE CHANGES ABOVE THIS LINE, DO NOT MAKE CHANGES BELOW THIS LINE   
*****************************************************************************************************;

proc format;
* One Treatment Pair Design - BLOCKSIZE=2;
   value seqa 	 1=' A, B, 1'
   				 2=' B, A, 1'			 
		    	 ;
   value $spfa 
			'A'='A'	'B'='B';

* Two Treatment Pair Design - BLOCKSIZE=4;
   value seqb 	 1=' A, B, 1' 2=' B, A, 1'
			   	 3=' C, D, 2' 4=' D, C, 2'
				 	;
   value $spfb 
			'A'='A'	'B'='B' 'C'='C' 'D'='D';


* Three Treatment Pair Design - BLOCKSIZE=6;
   value seqc 	 1=' A, B, 1' 2=' B, A, 1'
			   	 3=' C, D, 2' 4=' D, C, 2'
				 5=' E, F, 3' 6=' F, E, 3'
		    	;
   value $spfc 
			'A'='A'	'B'='B' 'C'='C' 'D'='D' 'E'='E' 'F'='F';

* Four Treatment Pair Design - BLOCKSIZE=8;
	value seqd 	 1=' A, B, 1' 2=' B, A, 1'
			   	 3=' C, D, 2' 4=' D, C, 2'
				 5=' E, F, 3' 6=' F, E, 3'
				 7=' G, H, 4' 8=' H, G, 4'
		    	 ;
    value $spfd 
			'A'='A'	'B'='B'	'C'='C' 'D'='D' 'E'='E' 'F'='F' 'G'='G' 'H'='H';


	value $spfGroup
  		'1' = 1
		'2' = 2
		'3' = 3
		'4' = 4
		;
*If more than four treatment pairs are necessary add a value seqe & $spfe here.;

options nodate nonumber;
Libname SAVE "&DIR";
TITLE1 "&STUDY Randomization";
FILENAME F_txtba "&DIR.&TXTBA";
footnote1 ' ';

proc plan seed=&seed;
     output out=plan;
     factors blocks=&blocks  ordered Sequence=&BLOCKSIZE of &BLOCKSIZE / noprint;
run;

data test; 
   	set plan;
   	keep RandNo Sequence Site01 - Site02 Group;
   	RandNo=&NUM;

	if &BLOCKSIZE=2 then do;
   		Site01=put(scan(put(Sequence,seqa.),1),$spfa.);
   		Site02=put(scan(put(Sequence,seqa.),2),$spfa.);
   		Group=put(scan(put(Sequence,seqa.),3),spfGroup.);
	end;
	if &BLOCKSIZE=4 then do;
   		Site01=put(scan(put(Sequence,seqb.),1),$spfb.);
   		Site02=put(scan(put(Sequence,seqb.),2),$spfb.);
   		Group=put(scan(put(Sequence,seqb.),3),spfGroup.);
	end;
	if &BLOCKSIZE=6 then do;
   		Site01=put(scan(put(Sequence,seqc.),1),$spfc.);
   		Site02=put(scan(put(Sequence,seqc.),2),$spfc.);
   		Group=put(scan(put(Sequence,seqc.),3),spfGroup.);
	end;
	if &BLOCKSIZE=8 then do;
   		Site01=put(scan(put(Sequence,seqd.),1),$spfd.);
   		Site02=put(scan(put(Sequence,seqd.),2),$spfd.);
   		Group=put(scan(put(Sequence,seqd.),3),spfGroup.);
	end;

*If more than 4 treatment pairs are necessary, add an "if...then do" here, similar to above.;
run;

data clmba;
	set test;

	if Sequence=1 then ba_trt='A';
	if Sequence=2 then ba_trt='B';
	if Sequence=3 then ba_trt='C';
	if Sequence=4 then ba_trt='D';
	if Sequence=5 then ba_trt='E';
	if Sequence=6 then ba_trt='F';
	if Sequence=7 then ba_trt='G';
	if Sequence=8 then ba_trt='H';
	
	FILE F_TXTBA;
		  If   1<=RandNo<=9   then PUT #1 @3 RandNo @5 ba_trt;
 	
		  If  10<=RandNo<=99  then PUT #1 @2 RandNo @5 ba_trt;
	
          If 100<=RandNo<=999 then PUT #1 @1 RandNo @5 ba_trt;	
run;

options leftmargin=1 rightmargin=1 topmargin=.5 bottommargin=.5 ;
options orientation=portrait;

proc template;
   	define style newstyle;
      parent=styles.printer;
      replace headersAndFooters from cell /
         font = fonts('HeadingFont')
         foreground = colors('headerfg')
         background = white;
   	end;
run;
 
ODS RTF FILE="&DIR.&STUDY Randomization.doc"
style=newstyle;
           
proc report nowd data=test headline headskip split='*' spacing=5;
  	column RandNo Sequence Site01 Site02;
  	define RandNo / order   center width=7 format=3. 'Product * Number';
  	define Sequence /display center width=8 format=2. 'Sequence';
  	define Site01  / display center width=12 format=$1. 'Trt Left Side ' spacing=3;
  	define Site02  / display center width=12 format=$1. 'Trt Right Side' spacing=3;
  	break after RandNo / skip;
run;

ODS OUTPUT;
ODS LISTING;
ODS RTF CLOSE;
RUN;

data test;
	set test;
	Left=Site01;
	Right=Site02;

	drop Site01 Site02;
run;
 
PROC SORT DATA=test;
	BY RandNo Sequence Group;
RUN;

PROC TRANSPOSE DATA=test
	OUT=Save.&Rand
	NAME=Source
	LABEL=Label;
	BY RandNo Sequence Group;
	VAR Left Right;
RUN; 

data save.&rand;
	set save.&rand;
	Side=Source;
	Trt=Col1;
	drop Col1 Source;
run;

Proc export data=Save.&Rand
	outfile="&Dir/&Study. Rand.csv"
	dbms=csv
	replace;
Run;

/*
VERSION 1.1 - 7/22/03
	The filenames of the randomization files were changed so that they followed the 
	archiving principles for acceptable filenames.

	The macro variable COMB was replaced with BLOCKSIZE for ease of understanding

	The DM Log statement was added to autmatically save the log to a file called
	CRB xx-xx-xxx Randomization Program.log.  This file is saved in the directory 
	specified by the macro variable called DIR.

	The formating of this program  was changed so that it could be printed on a page
    with its margins set to 0.5.

VERSION 1.2 - 4/9/09
	The randomization program was customized to work with pair designs where a placebo is
	matched with an active treatment.  This template was customized for the split scalp
	studies.   

	The clm file for the B&A program was changed to deal with paired designs

	A Group variable was added to the randomization data set to identify the different
    treatment pairs

VERSION 1.3 - 1/10/11
	The randomization program was updated to match the data standards for randomization files.
*/

DM Log 'File "&dir&study Randomization Program.Log"';
