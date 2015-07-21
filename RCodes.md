# R codes


## Table of Contents
1. [Useful R websites](#id-section1)
2. [Read in data](#id-section2)
3. [Data Manipulation](#id-section3)
4. [Example2](#id-section4)
5. [Useful R website](#id-section5)
6. [Example2](#id-section6)
7. [Useful R website](#id-section7)
8. [Example2](#id-section8)
9. [Useful R website](#id-section9)
10. [Example2](#id-section10)
11. [Useful R website](#id-section11)
12. [Example2](#id-section12)
13. [Useful R website](#id-section13)
14. [Example2](#id-section14)
15. [Useful R website](#id-section15)
16. [Example2](#id-section16)
17. [Useful R website](#id-section17)
18. [Example2](#id-section18)
19. [Useful R website](#id-section19)

  
  
  
  

  
  



<div id='id-section1'/>
## Useful R websites
Transition to R (Gregory S. Gilbert website):
      http://people.ucsc.edu/~ggilbert/RTransition.html#Graphics   
Quick R:
      http://www.statmethods.net/  
Help within R
      library(help="igraph") or help("igraph") as a starting point.


<div id='id-section2'/>
##  Read in data   
### -- Read in Excel file --
require(XLConnect)  
wb = loadWorkbook("C:\\Xiaojie\\Plots\\Summary - Plots.xlsx", create = TRUE)  
indata = readWorksheet(wb, sheet = "BL HDvsLDvsND",  startRow=2, endRow = 36, startCol = 1, endCol = 45, header=TRUE)  
head(indata)  

<div id='id-section3'/>
##  Data Manipulation  
### -- Sort --
    BL=BL[with(BL, order(-MeasureGroup, NewMeasure, Population)),]
    #Above is same as following
    BL=BL[order(-BL$MeasureGroup, BL$NewMeasure, BL$Population),]

### -- Select columns --
    DvsND = DvsND[,c(4,27)]

### -- Select rows
    indata<-indata[!is.na(indata[,3]),]

  
### --Different type of joins --;  
    Outer join: merge(x = df1, y = df2, by = "CustomerId", all = TRUE)
    Left outer: merge(x = df1, y = df2, by = "CustomerId", all.x=TRUE)
    Right outer: merge(x = df1, y = df2, by = "CustomerId", all.y=TRUE)
    Cross join: merge(x = df1, y = df2, by = NULL)
  
      