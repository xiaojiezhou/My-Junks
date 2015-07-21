%macro inputOptions(str);
  /* This macro might need to be rewritten.  As it functions now, options not in the */
  /* below list are completely ignored. */

  %local tempStr;

  %macro nameParse(text);
    %local strLength;
    %let text=%qupcase(&text);
    %let strLength=%length(&text);
    %let tempStr=%str();
    %if %index(%qupcase(&str),%str(&text=))>0 %then %do;
      %if %qsubstr(&str,%eval(%index(%qupcase(&str),%str(&text=))+1+&strLength),1)=%str(%") %then
      %let tempStr=%qtrim(%qsysfunc(dequote(
        %qscan(%qsubstr(&str,%eval(%index(%qupcase(&str),%str(&text=))+2+&strLength)),1,%str(%")) )));
      %else %if %qsubstr(&str,%eval(%index(%qupcase(&str),%str(&text=))+1+&strLength),1)=%str(%') %then
      %let tempStr=%qtrim(%qsysfunc(dequote(
        %qscan(%qsubstr(&str,%eval(%index(%qupcase(&str),%str(&text=))+2+&strLength)),1,%str(%')) )));
      %else %let tempStr=
        %qscan(%qsubstr(&str,%eval(%index(%qupcase(&str),%str(&text=))+1+&strLength)),1,%str( )) ;
    %end;
  %mend nameParse;
  %macro numericNameParse(text);
    %nameParse(&text);
    %if &tempStr^=%str() %then %do;
      %if %sysfunc(verify("&tempStr","1234567890."))=0 %then %let &text=&tempStr;
      %else %put ERROR: (LousyPrint) &text=&tempStr is not valid.  The previous value (&&&text) will be used.;
    %end;
  %mend numericNameParse;

  %nameParse(splitchar);
    %if &tempStr^=%str() %then %let splitchar=%qsubstr(&tempStr,1,1);
  %nameParse(escapechar);
    %if &tempStr^=%str() %then %let escapechar=%qsubstr(&tempStr,1,1);
  %nameParse(font);
    %if &tempStr^=%str() %then %let font=&tempStr;
  %nameParse(orientation);
    %if %qupcase(&tempStr)=LANDSCAPE or %qupcase(&tempStr)=PORTRAIT %then %let orientation=&tempStr;
    %else %if &tempStr^=%str() %then %put ERROR: (LousyPrint) orientation=&tempStr is not valid.  The previous value (&orientation) will be used.;
  %nameParse(idJustify);
    %if %qupcase(&tempStr)=RIGHT or %qupcase(&tempStr)=LEFT or %qupcase(&tempStr)=CENTER %then %let idJustify=&tempStr;
    %else %if &tempStr^=%str() %then %put ERROR: (LousyPrint) idJustify=&tempStr is not valid.  The previous value (&idJustify) will be used.;
  %nameParse(preTitleJustify);
    %if %qupcase(&tempStr)=RIGHT or %qupcase(&tempStr)=LEFT or %qupcase(&tempStr)=CENTER %then %let preTitleJustify=&tempStr;
    %else %if &tempStr^=%str() %then %put ERROR: (LousyPrint) preTitleJustify=&tempStr is not valid.  The previous value (&preTitleJustify) will be used.;
  %nameParse(titleJustify);
    %if %qupcase(&tempStr)=RIGHT or %qupcase(&tempStr)=LEFT or %qupcase(&tempStr)=CENTER %then %let titleJustify=&tempStr;
    %else %if &tempStr^=%str() %then %put ERROR: (LousyPrint) titleJustify=&tempStr is not valid.  The previous value (&titleJustify) will be used.;
  %nameParse(footnoteJustify);
    %if %qupcase(&tempStr)=RIGHT or %qupcase(&tempStr)=LEFT or %qupcase(&tempStr)=CENTER %then %let footnoteJustify=&tempStr;
    %else %if &tempStr^=%str() %then %put ERROR: (LousyPrint) footnoteJustify=&tempStr is not valid.  The previous value (&footnoteJustify) will be used.;
  %nameParse(footnoteChars);
    %if &tempStr^=%str() %then %let footnoteChars=&tempStr;
  %nameParse(order);
    %if %qupcase(&tempStr)=INTERNAL or %qupcase(&tempStr)=DATA or %qupcase(&tempStr)=FORMATTED or
      %qupcase(&tempStr)=FREQ %then %let order=&tempStr;
    %else %if &tempStr^=%str() %then %put ERROR: (LousyPrint) ORDER=&tempStr is not valid.  The previous value (&order) will be used.;
  %nameParse(headerColor);
    %if &tempStr^=%str() %then %let headerColor=&tempStr;
  %nameParse(headerText);
    %if %str(&tempStr)^=%str() %then %let headerText=%quote(&tempStr);
  %nameParse(footerText);
    %if %str(&tempStr)^=%str() %then %let footerText=%quote(&tempStr);
  %nameParse(frame); /* Need to restrict this variable */
    %if &tempStr^=%str() %then %let frame=&tempStr;
  %nameParse(rules); /* Need to restrict this variable */
    %if &tempStr^=%str() %then %let rules=&tempStr;
  %nameParse(tocLink);
    %if &tempStr^=%str() %then %let tocLink=&tempStr;
  %numericNameParse(fontSize);
  %numericNameParse(footnoteFS);
  %numericNameParse(cellPadding);
  %numericNameParse(cellIndent);
  %numericNameParse(topmargin);
  %numericNameParse(bottommargin);
  %numericNameParse(leftmargin);
  %numericNameParse(rightmargin);
  %numericNameParse(headerSize);
  %numericNameParse(footerSize);
  %numericNameParse(tocBreak);
  %numericNameParse(borderWidth);
%mend inputOptions;

%macro replaceTags(str);
  %local i finished tag tempNum;
  %let i=1;
  %let finished=0;
  %let str=%str( )&str%str( );
  %do %until(&i>25 or &finished=1);
    %if %index(&str,%str(<))>0 and 
      %index(&str,%str(>))>0 and
      %index(&str,%str(>))-%index(&str,%str(<))>0 %then %do;

      %let tag=%qsubstr(&str,
        %eval(%index(&str,%str(<))+1),
        %eval(%index(&str,%str(>))-%index(&str,%str(<))-1) );

      %if %qupcase(%qsubstr(&tag,1,%sysfunc(min(5,%length(&tag)))))=BYVAL %then %do;
        %let tempNum=%substr(&tag,%length(&tag));
        %if %sysfunc(verify("&tempNum","123456789"))=0 %then
          %let str=%qsubstr(&str,1,%eval(%index(&str,%str(<))-1))%str(%")||%quote(strip(put(&&byVar&tempNum,&&byFmt&tempNum)))||%str(%")%qsubstr(&str,%eval(%index(&str,%str(>))+1));
      %end;
      %else %if %qupcase(%qsubstr(&tag,1,%sysfunc(min(2,%length(&tag)))))=FN %then %do;
        %let tempNum=%substr(&tag,%length(&tag));
        %if %sysfunc(verify("&tempNum","123456789"))=0 %then
          %let str=%qsubstr(&str,1,%eval(%index(&str,%str(<))-1))&escapechar.{super %substr(&footnoteChars,&tempNum,1)}%qsubstr(&str,%eval(%index(&str,%str(>))+1));
      %end;
      %else %if %qupcase(%qsubstr(&tag,1,%sysfunc(min(2,%length(&tag)))))=%str(W=) %then %do;
        %let tempNum=%substr(&tag,3);
        %if %sysfunc(verify("&tempNum","1234567890."))=0 %then
          %let str=%qsubstr(&str,1,%eval(%index(&str,%str(<))-1))&escapechar.S={cellwidth=&tempNum.in}%qsubstr(&str,%eval(%index(&str,%str(>))+1));
      %end;
      %else %if %qupcase(&tag)=SEQTOCLINK %then %do;
        %let str=%qsubstr(&str,1,%eval(%index(&str,%str(<))-1))&escapeChar.R%str(%'){\field{\*\fldinst SEQ &tocLink}{\fldrslt xxx}}%str(%')%qsubstr(&str,%eval(%index(&str,%str(>))+1));
      %end;
    %end;
    %else %let finished=1;
    %let i=%eval(&i+1);
  %end;

  %qsysfunc(strip(&str))
%mend replaceTags;

 
%macro getPriorSettings();
%mend getPriorSettings;
 
%macro LousyPrint(data=_last_,
  optionStr=%str(),
  escapechar=%str(\), splitchar=%str(|),
  font=Calibri, fontSize=1, footnoteFS=9,
  cellindent=2, cellpadding=1, headercolor=greye0,
  orientation=portrait,
  topmargin=1, bottommargin=1, leftmargin=1, rightmargin=1, headerSize=0.5, footerSize=0.5,
  headertext=%str(), footertext=%str(),
  frame=box, rules=all, borderWidth=1,
  idJustify=left,
  titleJustify=center,
  preTitleJustify=left,
  footnoteJustify=left,
  footnoteChars=abcdefghij,
  pretitle=%str(),
  title1=%str(), title2=%str(), title3=%str(), title4=%str(), title5=%str(), 
  title6=%str(), title7=%str(), title8=%str(), title9=%str(), 
  footnote1=%str(), footnote2=%str(), footnote3=%str(), footnote4=%str(), footnote5=%str(),
  footnote6=%str(), footnote7=%str(), footnote8=%str(), footnote9=%str(),
  where=%str(), by=%str(), break=%str(), var=%str(), id=%str(), format=%str(), label=%str(),
  tocBreak=7, tocLink=EndofTextTable, order=internal
);

  %inputOptions(%str(&optionStr));

  /* Declare local variables */
  %local i j nByVars nVars nTitles nFootnotes tempStr tempStr2;
  %let nByVars=0;

  /* Exit macro if VAR is empty */
  %if %quote(&var)=%str() %then %do;
    %put ERROR: (LousyPrint) There is no VAR statement.  Procedure call was aborted.;
    %goto ERROR;
  %end;

  /* Apply options */
  proc template;
    define style lpRtfStyle;
      parent=Styles.RTF;
      replace fonts /
        'TitleFont' = ("&font",&fontsize.pt,Bold) 'TitleFont2' = ("&font",&fontsize.pt,Bold)
        'StrongFont' = ("&font",&fontsize.pt,Bold) 'EmphasisFont' = ("&font",&fontsize.pt,Italic)
        'HeadingEmphasisFont' = ("&font",&fontsize.pt,Bold Italic)
        'HeadingFont' = ("&font",&fontsize.pt,Bold) 'docFont' = ("&font",&fontsize.pt)
        'fixedFont' = ("&font",&fontsize.pt)
        'fixedStrongFont' = ("&font",&fontsize.pt) 'fixedEmphasisFont' = ("&font",&fontsize.pt)
        'batchFixedFont' = ("&font",&fontsize.pt);
      replace color_list /
        'link' = blue 'bgH' = white 'fg' = black 'bg' = white;
      replace Body from Document /
        bottommargin = &bottommargin.in topmargin = &topmargin.in leftmargin = &leftmargin.in
        rightmargin = &rightmargin.in;
      replace Table from Output /
        frame = &frame rules = &rules cellpadding = &cellpadding.pt cellspacing = 0
        borderstyle = solid borderwidth = &borderwidth.pt;
      style data from data /
        just=c vjust=c leftmargin=&cellindent.pt rightmargin=&cellindent.pt;
      style notecontent from notecontent /
        font=fonts("Titlefont") background=&headerColor leftmargin=&cellindent.pt
        rightmargin=&cellindent.pt;
      style SystemFooter from SystemFooter / font = ("arial",8pt);
      style SystemTitle from Systemfooter / font = ("arial",10pt);
    end;
  run;
  ods options orientation=&orientation topmargin=&topmargin.in bottommargin=&bottommargin.in 
    leftmargin=&leftmargin.in rightmargin=&rightmargin.in;
  ods rtf headery=%sysfunc(round(&headerSize*1440)) footery=%sysfunc(round(&footerSize*1440))
    style=lpRtfStyle;
  title; footnote;
  %if %str(&headertext)^=%str() %then %do;
    title "%unquote(&headertext)";
  %end;
  %if %str(&footertext)^=%str() %then %do;
    footnote "%unquote(&footertext)";
  %end;
  ods rtf exclude all;
  ods listing exclude all;
  ods escapechar="&escapechar";

  /* Process the BY string */
  %if &by^=%str() %then %do;
    %let i=1;
    %do %until(&i>9 or %qscan(&by,&i,%str( ))=%str());
      %local byVar&i byFmt&i;
      %let byVar&i=%qscan(&by,&i,%str( ));
      %let i=%eval(&i+1);
    %end;
    %let nByVars=%eval(&i-1);
  %end;

  /* Process the BREAK string */
  %if &break^=%str() %then %do;
    %local breakFmt;
  %end;

  /* Apply formats and labels */
  data lpDataset1;
    set &data;
    %if %quote(&label)^=%str() %then %do;
      label %unquote(&label);
    %end;
    %if %quote(&format)^=%str() %then %do;
      format %unquote(&format);
    %end;
  run;
  options nonotes;
  proc contents data=lpDataset1;
    ods output variables=lpDataset2;
  data _null_;
    length format $32.;
    set lpDataset2 end=islast;
    %if &break^=%str() %then %do;
      if upcase("&break")=upcase(variable) then do;
        if format="" and type="Num" then format="8.";
        else if format="" then format="$512.";
        call symput("breakFmt",strip(format));
      end;
    %end;
    %if &nByVars^=%str() %then %do i = 1 %to &nByVars;
      if upcase("&&byVar&i")=upcase(variable) then do;
        if format="" and type="Num" then format="8.";
        else if format="" then format="$512.";
        call symput("byFmt&i",strip(format));
      end;
    %end;
    if islast then call symput("nVars",strip(_N_));
  run;

  %do i = 1 %to &nVars;
    data _null_;
      set lpDataset2;
      if _N_=&i then do;
        call symput("tempStr",strip(label));
        call symput("tempStr2",strip(variable));
      end;
    run;
    %let tempStr=%replaceTags(str=%quote(&tempStr));
    data lpDataset1;
      set lpDataset1;
      %if %quote(&tempStr)^=%str() %then %do;
        label &tempStr2="&tempStr";
      %end;
    run;
  %end;

  /* Process the VAR string */
  %let tempStr2=0;
  %let tempStr=%str( )%quote(&var)%str( );
  %let i=1;
  %let j=0;
  %let nVars=0;
  %do %until(&i>50 or &tempStr2=1);
    %if %sysfunc(scanq(&tempstr,&i,%str(() )))^=%str() %then
      %if %qsubstr(%sysfunc(scanq(&tempstr,&i,%str(() ))),1,1)^=%str(%") and
        %qsubstr(%sysfunc(scanq(&tempstr,&i,%str(() ))),1,1)^=%str(%') %then %do;

      %let j=%eval(&j+1);
      %local var&j;
      %let var&j=%sysfunc(scanq(&tempstr,&i,%str(() )));
    %end;
    %let i=%eval(&i+1);
  %end;
  %let var=%replaceTags(str=%quote(&var));
  %let nVars=&j;

  /* Determine the number of titles and footnotes */
  %do i = 1 %to 9;
    %if %quote(&&title&i)^=%str() %then %let nTitles=&i;
    %if %quote(&&footnote&i)^=%str() %then %let nFootnotes=&i;
  %end;
  %if %str(&pretitle)^=%str() and &nTitles=%str() %then %let nTitles=1;

  ods rtf select all;
  option notes;
  proc report data=lpDataset1 split="%unquote(&splitChar)" center nowd box missing;
    by &by;
    where %unquote(&where);
    column &by &break &id %unquote(&var);
    %do i = 1 %to &nVars;
      define &&var&i / display order=data;
    %end;
    %if &break^=%str() %then %do;
      define &break / order noprint order=&order;
      break before &break / style=[just=left vjust=center]; compute before &break;
        line &break &breakfmt @1;
      endcomp;
    %end;
    %if &by^=%str() %then %do i = 1 %to &nByVars;
      define &&byVar&i / display noprint order=&order;
    %end;
    %if &id^=%str() %then %do;
      define &id / order order=&order style(column)=[just=&idJustify vjust=center];
    %end;
    %if &nTitles^=%str() %then %do;
      compute before _page_ / style()=[nobreakspace=false just=&titleJustify];
        %do i = 1 %to &nTitles;
          length text&i $512.;
          text&i="%replaceTags(str=%quote(&&title&i))";
          %if &i=1 and &preTitle^=%str() %then %do;
            text&i="&escapeChar.R%str(%')\q%substr(&preTitleJustify,1,1) \fs%eval(&footnoteFS*2) %replaceTags(str=%quote(&preTitle))\par\fs%eval(&fontSize*2)\q%substr(&titleJustify,1,1) %str(%')"||strip(text&i);
          %end;
          %if &i=&tocBreak and &nTitles>&tocBreak %then %do;
            text&i=strip(text&i)||"&escapeChar.R'\fs0\par'";
          %end;
          %if &i=%eval(&tocBreak+1) %then %do;
            text&i="&escapeChar.R'\fs%eval(2*&fontSize) '"||strip(text&i);
          %end;
          line %unquote(text&i) $512.;
        %end;
      endcomp;
    %end;
    %if &nFootnotes^=%str() %then %do;
      compute after _page_ / style()=[just=&footnoteJustify font=(&font,&footnoteFS.pt) background=white nobreakspace=false
                                     pretext="&escapeChar.R'\li288\fi-%eval(288-&cellIndent*20)'"];
        %do i = 1 %to &nFootnotes;
          length text&i $512.;
          text&i="&escapeChar.R'\fs0\par\fs%eval(2*&footnoteFS){\super %substr(&footnoteChars,&i,1)}\tab '%replaceTags(str=%quote(&&footnote&i))  &escapeChar.R'\fs0'";
          line %unquote(text&i) $512. @1;
        %end;
      endcomp;
    %end;
  run;
  ods rtf exclude all;

  %ERROR:
  ods listing select all;
%mend LousyPrint;

%macro rtfTable(str);
  /* Declare local variables and default options. */
  %local data escapechar splitchar font fontSize footnoteFS cellindent cellpadding headercolor
         orientation topmargin bottommargin leftmargin rightmargin headersize footersize frame
       rules borderwidth idJustify tocBreak pretitle title1 title2 title3 title4 title5 title6
       title7 title8 title9 footnote1 footnote2 footnote3 footnote4 footnote5 footnote6
       footnote7 footnote8 footnote9 where by break var id format label tocLink order
       optionStr nTitle nFootnote preTitleJustify titleJustify footnoteJustify headertext footertext;
  %let data=_last_;
  %let order=internal;
  %let escapechar=%str(\);
  %let splitchar=%str(|);
  %let font=Arial;
  %let fontSize=10;
  %let footnoteFS=9;
  %let cellindent=2;
  %let cellpadding=1;
  %let headercolor=greye0;
  %let orientation=portrait;
  %let topmargin=1; %let bottommargin=1; %let leftmargin=1; %let rightmargin=1;
  %let headerSize=0.5; %let footerSize=0.5;
  %let headertext=%str(); %let footertext=%str();
  %let frame=box; %let rules=all; %let borderWidth=1.5;
  %let idJustify=left;
  %let tocBreak=7; %let tocLink=EndofTextTable;
  %let nTitles=0;
  %let nFootnotes=0;
  %let preTitleJustify=left;
  %let titleJustify=center;
  %let footnoteJustify=left;
  %let footnoteChars=abcdefghij;

  options nobyline nodate nonumber missing=" ";

  %local i j statement statementID inProc;
  %let inProc=0;

  %let i=1;
  %do %until(%length(%qscan(&str,&i,%str(;)))=0 or &i>1000);
    %let statement=%qsysfunc(strip(%qscan(&str,&i,%str(;))));
    %if %length(&statement)=0 %then %goto LOOPEXIT;

    %let statementID=%qscan(&statement,1,%str( ));
    %if &statementID^=&statement %then %let statement=%qsubstr(&statement,%eval(%length(&statementID)+2));
    %else %let statement=%str();

    %if &statement^=%str() %then 
      %if (%qsubstr(&statement,1,1)=%str(%") and %qsubstr(&statement,%length(&statement),1)=%str(%")) or 
          (%qsubstr(&statement,1,1)=%str(%') and %qsubstr(&statement,%length(&statement),1)=%str(%')) %then
        %let statement=%qsubstr(&statement,2,%eval(%length(&statement)-2));
    %let statementID=%qupcase(&statementID);
    %if &statementID=TITLE %then %let statementID=TITLE1;
    %if &statementID=FOOTNOTE %then %let statementID=FOOTNOTE1;

    %if &statementID=WHERE or &statementID=BY or &statementID=BREAK or &statementID=VAR or
      &statementID=ID or &statementID=FORMAT or &statementID=LABEL %then %do;

      %if &inProc=0 %then %do;
        %put ERROR: (LousyPrint) The &statementID statement is not valid outside of a procedure call and will be ignored.;
        %goto LOOPEXIT;
      %end;
      %else %let &statementID=&statement;
    %end;
    %else %if &statementID=PRETITLE %then %let &statementID=&statement;
    %else %if (%qsubstr(&statementID,1,%sysfunc(min(5,%length(&statementID))))=TITLE or
      %qsubstr(&statementID,1,%sysfunc(min(8,%length(&statementID))))=FOOTNOTE) and
      %sysfunc(verify("%qsubstr(&statementID,%length(&statementID))","123456789"))=0 %then %do;

      %let &statementID=&statement;
      %let n%substr(&statementID,1,%eval(%length(&statementID)-1))=%qsubstr(&statementID,%length(&statementID));
      %let statementID=%substr(&statementID,1,%eval(%length(&statementID)-1));
      %do j = %sysfunc(min(9,%eval(&&n&statementID+1))) %to 9;
        %let &statementID&j=%str();
      %end;
    %end;
    %else %if &statementID=OPTION or &statementID=OPTIONS %then %do;
      %let statement=%sysfunc(tranwrd(&statement,%str( =),%str(=)));
      %let statement=%sysfunc(tranwrd(&statement,%str(= ),%str(=)));
      %inputOptions(%qsysfunc(strip(&statement)));
    %end;
    %else %if &statementID=PROC %then %do;
      %if &inProc=1 %then %do;
        %LousyPrint(data=&data,
          optionStr=%str(&optionStr),
          escapechar=%str(&escapeChar), splitchar=%str(&splitChar),
          font=&font, fontSize=&fontSize, footnoteFS=&footnoteFS,
          cellindent=&cellindent, cellpadding=&cellpadding, headercolor=&headercolor,
          orientation=&orientation,
          topmargin=&topmargin, bottommargin=&bottommargin, leftmargin=&leftmargin, rightmargin=&rightmargin,
          headerSize=&headerSize, footerSize=&footerSize,
          headertext=&headertext, footertext=&footertext,
          frame=&frame, rules=&rules, borderWidth=&borderWidth,
          idJustify=&idJustify,
          preTitleJustify=&preTitleJustify,
          titleJustify=&titleJustify,
          footnoteJustify=&footnoteJustify,
          footnoteChars=&footnoteChars,
          pretitle=%str(&pretitle),
          title1=%str(&title1), title2=%str(&title2), title3=%str(&title3),
          title4=%str(&title4), title5=%str(&title5), title6=%str(&title6),
          title7=%str(&title7), title8=%str(&title8), title9=%str(&title9),
          footnote1=%str(&footnote1), footnote2=%str(&footnote2), footnote3=%str(&footnote3),
          footnote4=%str(&footnote4), footnote5=%str(&footnote5), footnote6=%str(&footnote6),
          footnote7=%str(&footnote7), footnote8=%str(&footnote8), footnote9=%str(&footnote9),
          where=%quote(&where), by=%str(&by), break=%str(&break), var=%str(&var),
          id=%str(&id), format=%str(&format), label=%str(&label),
          tocBreak=&tocBreak, tocLink=&tocLink, order=&order);
      %end;
      %let statement=%sysfunc(tranwrd(&statement,%str( =),%str(=)));
      %let statement=%sysfunc(tranwrd(&statement,%str(= ),%str(=)));
      %if %index(%qupcase(&statement),%str(DATA=))>0 %then
        %let data=%qscan(%qsubstr(&statement,%eval(%index(%qupcase(&statement),%str(DATA=))+5)),1,%str( ));
      %let optionStr=%str(&statement);
      %let optionStr=%str(&statement);
      %let where=%str();
      %let by=%str();
      %let break=%str();
      %let var=%str();
      %let id=%str();
      %let format=%str();
      %let label=%str();
      %let inProc=1;
    %end;
    %else %if &statementID=RUN %then %do;
      %if &inProc=1 %then %do;
        %LousyPrint(data=&data,
          optionStr=%str(&optionStr),
          escapechar=%str(&escapeChar), splitchar=%str(&splitChar),
          font=&font, fontSize=&fontSize, footnoteFS=&footnoteFS,
          cellindent=&cellindent, cellpadding=&cellpadding, headercolor=&headercolor,
          orientation=&orientation,
          topmargin=&topmargin, bottommargin=&bottommargin, leftmargin=&leftmargin, rightmargin=&rightmargin,
          headerSize=&headerSize, footerSize=&footerSize,
          headertext=&headertext, footertext=&footertext,
          frame=&frame, rules=&rules, borderWidth=&borderWidth,
          idJustify=&idJustify,
          preTitleJustify=&preTitleJustify,
          titleJustify=&titleJustify,
          footnoteJustify=&footnoteJustify,
          footnoteChars=&footnoteChars,
          pretitle=%str(&pretitle),
          title1=%str(&title1), title2=%str(&title2), title3=%str(&title3),
          title4=%str(&title4), title5=%str(&title5), title6=%str(&title6),
          title7=%str(&title7), title8=%str(&title8), title9=%str(&title9),
          footnote1=%str(&footnote1), footnote2=%str(&footnote2), footnote3=%str(&footnote3),
          footnote4=%str(&footnote4), footnote5=%str(&footnote5), footnote6=%str(&footnote6),
          footnote7=%str(&footnote7), footnote8=%str(&footnote8), footnote9=%str(&footnote9),
          where=%quote(&where), by=%str(&by), break=%str(&break), var=%str(&var),
          id=%str(&id), format=%str(&format), label=%str(&label),
          tocBreak=&tocBreak, tocLink=&tocLink, order=&order);
      %end;
      %let inProc=0;
    %end;
    %else %do;
      %put ERROR: (LousyPrint) The statement beginning with &statementID is being ignored.;
    %end;

    %LOOPEXIT:
    %let i=%eval(&i+1);
  %end;

  options byline; 
%mend;
