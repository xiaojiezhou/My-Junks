  *** use for display to screen in PC ***;
    goptions device=win display ftext=swissb   rotate=landscape;

  *** use for display to screen uin UNIX ***;
*   goptions reset=all gunit=pct rotate=landscape ftext=swissb device=xcolor htitle=3 htext=3;

  *** use for png output ***;
*   goptions reset=all targetdevice=png device=png gsfname=graph gsfmode=append
      ftext=swissb htitle=3 htext=2 xmax=6in ymax=4in xpixels=1800 ypixels=1200;
 *  filename graph "graphs/hist&var..png";
