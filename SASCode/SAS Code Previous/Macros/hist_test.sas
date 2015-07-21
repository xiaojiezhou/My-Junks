
%macro hist(indata=, var=, class=, vmin=, vmax=, vby=, vref=, mlower=, mupper=, mby=, nrow=, loc=);
  *** use for display to screen in PC ***;
    goptions device=win display ftext=zapf rotate=landscape;

  *** use for display to screen uin UNIX ***;
*   goptions reset=all gunit=pct rotate=landscape ftext=swissb device=xcolor htitle=3 htext=3;

  *** use for png output ***;
*   goptions reset=all targetdevice=png device=png gsfname=graph gsfmode=append
      ftext=swissb htitle=3 htext=2 xmax=6in ymax=4in xpixels=1800 ypixels=1200;
 *  filename graph "graphs/hist&var..png";

   proc univariate data=&indata noprint;
      var &var;
      where &var ne .;
      class &class;
      histogram &var /cfill=blue cbarline=red caxis=green
                        cvref=red cframetop=rose  
                      vscale=count height=2.0 nrow=&nrow;
      inset n median (6.2) min (6.3) max (6.2) /header='STATISTICS' height=1.4 pos=&loc
                                    ctext=black cframe=black cshadow=black cfill=blank;
      label &var="&var";
   run;
/************
   proc univariate data=&indata noprint;
      var &var;
      where &var ne .;
      class &class;
      histogram &var /cfill=blue vaxis=(&vmin to &vmax by &vaxisby) cbarline=red caxis=green
                        vref=&vref cvref=red cframetop=rose  midpoints=(&mlower to &mupper by &mby)
                      vscale=count height=2.0 nrow=&nrow;
      inset n mean (6.2) std (6.3) median (6.2) /header='STATISTICS' height=1.4 pos=&loc
                                    ctext=black cframe=black cshadow=black cfill=blank;
      label &var="&var";
   run;
   *************/
%mend;
*  %include "C:\Documents and Settings\tx3950\Desktop\SAS Code";
* %hist(indata=periotron2, var=diff, class=team,  vmin=0, vmax=14, vby=2, vref=2 4 6 8 10 12 14, mlower=0, mupper=1, mby=0.1,
 nrow=3, loc=ne);

