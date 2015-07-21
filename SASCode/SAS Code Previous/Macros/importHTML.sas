**************************************************************;
*  htmlread.sas                                              *;
*  make sure you read all comments in the program fully !!!! *;
*  purpose to be able to read html files into the sas system *;
*  it can also create an xls file as a bonus                 *;
*  html is limited to 65,000 observations that excel can do  *;
*  Access to PC file formats is required to make this run    *;
*                                                            *;
* filen is the name of the html file you wish to read        *;
* into the sas system                                        *;
* filedir is the name of the directory of the html file      *;
* filedir2 is the name of the directory you wish to save     *;
* the xls file.   By default the xls file is the same        *;
* name as the html file is                                   *;
* row1 is a counter saying whether you have variable names   *;
* in the first row of the html table you are trying to read  *;
* sasname is the name of the sas dataset you are creating    *;
**************************************************************;

%macro htmlread(filen,filedir,filedir2,row1,sasname);
options mprint macrogen symbolgen;
options noxwait noxsync;
data setup;
%let fullname=&filedir&filen..html;
%let savefile=&filedir2&filen..xls;
%let del1=call system(%unquote(%str(%'del "&savefile"%')));

run; quit;

data setup2;
&del1;
run; quit;

**************************************************************;
* change this path to match where your excel is located      *;
**************************************************************;

x "'C:\Program Files\Microsoft Office\Office11\excel.exe'";

%put &fullname;
%let opener=%str(%'[open("&fullname")]%');
%let saveas=%str(%'[save.as("&savefile",1)]%');

* this datastep gives excel 2 seconds to start *;
options xmin noxwait noxsync missing=0 mprint symbolgen;

data _null_;
x=sleep(5);
run;
quit;

filename cmds dde 'excel|system';
data _null_;
file cmds;
put %unquote(&opener);
* Delete the top three rows as they are blank rows and the title   *;
* You will need to modify this as needed to remove extraneous info *;
* in your html file                                                *;
* see the macrofun.exe help file for more information on these     *;
* commands                                                         *;
* you can get a copy of the macrofun.exe from www.microsoft.com    *;
********************************************************************;

put '[select("r1:r5")]';
put '[edit.delete(3)]';
* Now save the file as an excel file *;
put %unquote(&saveas);
put '[quit()]';
run;

* now import the file as a sas dataset from excel *;

proc import datafile="&savefile"
out=&sasname replace;
sheet="&filen";
getnames=&row1;
run; quit;

*****************************************************;
* uncomment these lines if you want the excel file  *;
* to disappear after the program is finished        *;
*****************************************************;

*data setup2;
*&del1;
*run;
*quit;

%mend htmlread;
%htmlread(filen=TotalEffectsonTarget,
  filedir=%str(C:\Documents and Settings\TX2524\My Documents\mvic\Xiaojie\ImportHTML\),
  filedir2=%str(C:\Documents and Settings\TX2524\My Documents\mvic\Xiaojie\ImportHTML\),
  row1=no,sasname=work.test1);

