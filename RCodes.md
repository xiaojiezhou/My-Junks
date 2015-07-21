# R codes


## Table of Contents
* [Useful R websites](#id-section1)
* [Read in data](#id-section2)
* [dplyr](#id-section6)
* [sqldf](#sqldf) 
* [Regular expression](#regre) 
* [Data manipulation](#id-section3)
* [Colours & symbols](#id-section4)
* [Plot related](#id-section5)
* [empty](#id-section7)
* [empty](#id-section8)
* [empty](#id-section9)
* [empty](#id-section10)
* [empty](#id-section11)
* [empty](#id-section12)

  
  

  
  



<div id='id-section1'/>
## Useful R websites
Transition to R (Gregory S. Gilbert website):
      http://people.ucsc.edu/~ggilbert/RTransition.html#Graphics   
Quick R:
      http://www.statmethods.net/  
Help within R
      library(help="igraph") or help("igraph") as a starting point.
[(back to top](#table-of-contents)

<div id='id-section2'/>
##  Read in data   
### -- Read in Excel file --
require(XLConnect)  
wb = loadWorkbook("C:\\Xiaojie\\Plots\\Summary - Plots.xlsx", create = TRUE)  
indata = readWorksheet(wb, sheet = "BL HDvsLDvsND",  startRow=2, endRow = 36, startCol = 1, endCol = 45, header=TRUE)  
head(indata)  
[(back to top)](#table-of-contents)

<div id='id-section6'/>
## dplyr 
    library(dplyr)
    # select: return a subset of the columns of a data frame
    # filter: extract a subset of rows from a data frame based on logical conditions
    # arrange: reorder rows of a data frame
    # rename: rename variables in a data frame
    # mutate: add new variables/columns or transform existing variables
    # summarise / summarize: generate summary statistics of different variables in the data frame, possibly within strata 
    # group_by - Generating summary statistics by stratum
    
    chicago <- readRDS("chicago.rds")
    head(select(chicago, -(city:dptp)))
    filter(chicago, pm25tmean2 > 30 & tmpd > 80)
    arrange(chicago, desc(date))
    rename(chicago, newname1 = oldname1, newname2 = oldname2)
    mutate(chicago,pm25detrend=pm25-mean(pm25, na.rm=TRUE))

    
    #---Row operation ---#
    filter(edges, Source=="coupon" & Target =="send")
    slice(edges, 1:10)
    edges = arrange(edges, Source, Target) #sort
    
    #---Column operations---#
    aa = select(edges, Source)
    aa = select(edges, -(Target))
    aa = rename(edges, temp=Target)
    
    aa = distinct(select(edges, Source)) # distinct value of Source
    aa = mutate(edges, Edge=paste(Source,'-',Target))  # newly created var can be referenced in mutate, but not transform
    aa = transform(edges, Edge=paste(Source,'-',Target))
    
    slice(aa, 1:10)
    
    #--summarise---#
    summarise(edges, 
              count=n(),
              distnt.Source=n_distinct(Source),
              distnt.Target=n_distinct(Target),
              na.rm=TRUE)
    
    #---group_by:  if a data frame is grouped by group_by, all operation are applied at group_by level---#
    distnct = group_by(edges, Source, Target)
    aa = summarise(distnct,
                   edge.wt = n())
    slice(aa)
    
    distnct = group_by(edges, Source)
    aa = summarise(distnct,
                   node.size = n())
    aa = arrange(aa, desc(node.size))
    aa
    
    n(), n_distinct, first(), last(), nth(x,n), sum(), mean(), min, max
    
    #--- subsample ---#
    sample_n(edges, 10)
    sample_frac(edges, 0.0001, replace=TRUE)
[(back to top)](#table-of-contents)


<div id='sqldf'/>    
##  sqldf ###
    
    library(sqldf)
    
    PrdTitle = sqldf("select PurID, Resp as PrdTitle from a3 where  Measure = 'title' ")
    PrdPrice = sqldf("select PurID, Resp as PrdPrice from a3 where  Measure = 'price' ")
    a1 = sqldf("select a.*, PrdPrice from PrdTitle as a left join  PrdPrice as b where  a.PurID=b. PurID")
[(back to top)](#table-of-contents)

<div id='regre'/>   
## Regular expression 
    '''
    "." matches everything except for the empty sting "".
    "+" the preceding item will be matched one or more times.
    "*" the preceding item will be matched zero or more times.
    "^" matches the empty string at the at the beginning of a line.
        When used in a character class, match any character but the following ones.
    "$" matches empty string at the end of a line.
    "|" infix operator: OR
    "(", ")" brackets for grouping.
    "[", "]" character class brackets (see next section).
    
    "[0-9]" - Digits
    "[a-z]" - Lower-case letters
    "[A-Z]" - Upper-case letters
    "[a-zA-Z]" - Alphabetic characters
    "[^a-zA-Z]" - Non-alphabetic characters
    "[a-zA-Z0-9]" - Alphanumeric characters
    "[ \t\n\r\f\v]" - Special characters
    "[]$*+.?[^{|(\\#%&~_/<=>✬!,:;❵\")}@-]" - Punctuation Characters'''
[(back to top)](#table-of-contents)

<div id='id-section3'/>
##  Data manipulation  
### -- Sort --
    BL=BL[with(BL, order(-MeasureGroup, NewMeasure, Population)),]
    #Above is same as following
    BL=BL[order(-BL$MeasureGroup, BL$NewMeasure, BL$Population),]

### -- Select columns --
    DvsND = DvsND[,c(4,27)]

### -- Select rows --
    indata<-indata[!is.na(indata[,3]),]

### --Different type of joins --
    Outer join: merge(x = df1, y = df2, by = "CustomerId", all = TRUE)
    Left outer: merge(x = df1, y = df2, by = "CustomerId", all.x=TRUE)
    Right outer: merge(x = df1, y = df2, by = "CustomerId", all.y=TRUE)
    Cross join: merge(x = df1, y = df2, by = NULL)
[(back to top)](#table-of-contents)
  
<div id='id-section4'/>
## Colours & Symbols
### -- via palette --
    par(mfrow=c(2,2))  # Divide window into rows and columns
    
    palette(rainbow(20))
    palette(gray(0:8 / 8))
    
    colors()
    colors()[grep("red", colors())]
    colors()[grep("blue", colors())]
    colors()[grep("purple", colors())]
     
    palette("default")
    palette()
     
    palette(c("cornflowerblue", "purple4", "blue4", "cadetblue1", "purple4"))
    
    palette(colors()[grep("purple", colors())])
    palette(colors()[grep("blue", colors())])
    
    barplot(rep(1,20),col=1:20, yaxt="n")

### -- Color by names --
    colorlist<-read.csv("http://people.ucsc.edu/~ggilbert/Rclass_docs/colorlist.csv")
    rect<-as.matrix(cbind(rep(1,580),rep(1,580)))
    y<-rep(seq(1,58,1),10); x<-sort(rep(seq(1,10,1),58))
    z<-as.character(colorlist$color);textcol<-colorlist$textcode
    symbols(y~x,rectangles=rect,xlab="",ylab="",bg=z,xlim=c(0.5,10.5),ylim=c(0,59),inches=FALSE); box()
    text(y~x,labels=z,col=textcol,cex=.5)


### -- Symbols --
    * To see all the first 25 available symbols, use this code.  Note that for 21-25 
    you can control the fill (bg) and the border (col) color of the symbols separately.  
    E.g., points(x,y,pch=21,bg="yellow",col="blue")   makes yellow circles with a blue borderx<-rep(seq(1,5),5)
    
    y<-sort(x,decreasing=TRUE)
    pch<-seq(1,25)
    plot(x,y,pch=pch,cex=2,xlim=c(1,5.4), axes=FALSE,xlab="R symbols",ylab="")
    text(x+0.25,y,pch)
    dev.off()

[(back to top)](#table-of-contents)    
<div id='id-section5'/>
## Plot Related
### -- Line and arrow codes --
    x1=rep(1,6); x2<-rep(3,6); y<-seq(6,1); linecode<-seq(1:6)
    plot(0,0,xlim=c(0,10),ylim=c(0,6.2),pch=1,col=0,axes=FALSE,xlab="",ylab="")
    for(i in 1:6){lines(c(x1[i],x2[i]),c(y[i],y[i]),lty=linecode[i])}
    text(x1-.8,y,linecode,pos=4); text(1.5,0.1,"lines\nlty",pos=4)
    
    for(i in 1:6){lines(c(x1[i]+3,x2[i]+3),c(y[i],y[i]),lty=linecode[i],lwd=linecode[i])}
    text(x1-.8+3,y,linecode,pos=4); text(4.5,0.1,"lines\nlwd",pos=4)
    
    for(i in 1:3){arrows(x1[i]+6, y[i],x2[i]+6, y[i],code=linecode[i])}
    text(x1[1:3]-.8+6,y[1:3],linecode[1:3],pos=4); text(7,0.1,"arrow\ncode",pos=4)
[(back to top)](#table-of-contents)

   
      