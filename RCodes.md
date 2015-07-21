## R codes



# Table of Contents
1. [Useful Web Links](#Useful R website)
2. [Example2](#example2)

asdas
asdasd
adsads
adsasa
adsads




## Useful R website
Transition to R (Gregory S. Gilbert website):
      http://people.ucsc.edu/~ggilbert/RTransition.html#Graphics
Quick R:  
      http://www.statmethods.net/
Help within R
      library(help="igraph") or help("igraph") as a starting point.

## Example2
Add somehting here.  Example 2.





############  Data Manipulation  ############# 
#-- Read in Excel file --#
require(XLConnect)
    wb = loadWorkbook("Q:\\beauty_care\\clinical\\Biometrics\\HairBiology\\Studies\\2012\\CRB 12-10-106 OSLO\\Xiaojie\\Plots\\Summary - Plots.xlsx", create = TRUE)
    indata = readWorksheet(wb, sheet = "BL HDvsLDvsND",  startRow=2, endRow = 36, startCol = 1, endCol = 45, header=TRUE)
    head(indata)

#-- Sort --#
    BL=BL[with(BL, order(-MeasureGroup, NewMeasure, Population)),]
    #Above is same as followinf
    BL=BL[order(-BL$MeasureGroup, BL$NewMeasure, BL$Population),]

#-- Slect columns
    DvsND = DvsND[,c(4,27)]

#-- Select rows
    indata<-indata[!is.na(indata[,3]),]

  
######## Different type of joins #########;  
    Outer join: merge(x = df1, y = df2, by = "CustomerId", all = TRUE)
    Left outer: merge(x = df1, y = df2, by = "CustomerId", all.x=TRUE)
    Right outer: merge(x = df1, y = df2, by = "CustomerId", all.y=TRUE)
    Cross join: merge(x = df1, y = df2, by = NULL)
  
      