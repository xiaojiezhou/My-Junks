############
#USER INPUT
############
#1-Set current working directory containing csv data file using "setwd" function.
#2-Specify main title for all plots in "main.title".
#3-Specify direction for improvement & ylabel
#4-Other pamrameters may require adjustement:
#    - bar.spc: space between bars
#    - height& width of the graph: control orientaion of the graph
#    - trt.xadj, trt.yadj: affect XY location of treatment label 
#    - pval.xadj, pval.yadj: affect XY location of p-value
#Note: Final graph is store at "Bar Plots1.png" in working directory entered in "setwd".

study<-"Q:\\beauty_care\\clinical\\Biometrics\\Lin Fei\\2011\\CRB 11-12-149 Oxidative Damage - Maaike Bose"
path<-"Q:\\beauty_care\\clinical\\Biometrics\\Lin Fei\\2011\\CRB 11-12-149 Oxidative Damage - Maaike Bose\\Xiaojie\\QOL\\Plot"


setwd(path)

require(XLConnect)

wb = loadWorkbook("Q:\\beauty_care\\clinical\\Biometrics\\Lin Fei\\2011\\CRB 11-12-149 Oxidative Damage - Maaike Bose\\Xiaojie\\QOL\\Results\\QOL Part2 TrtCmpr v1.xlsx", create = TRUE)
indata = readWorksheet(wb, sheet = "Graphs",  startRow=1, endRow = 18, startCol = 1, endCol = 17)
indata<-indata[!is.na(indata[,2]),]
dim(indata)

library(gplots)

##################################################################

###############Call functions #####################


data.and.plot(set="BL", 
              main.title="Baseline Treatment Comparison", 
              subtitle=" ",
              arrow="<-------------------------- ",
              ylabel="Mean")


data.and.plot(set="CFB", 
              main.title="Adjusted Mean Change From Baseline at Week 16", 
              subtitle=" ",
              arrow="<-------------------------- ",
              ylabel="CFB")



########################################################
##   data.and.plot function:  Prepare data and plot
#------------------------ Begin -----------------------#

data.and.plot <- function(set, main.title, subtitle, arrow, ylabel){
  
  
  plotdata=indata[indata$Response.Variable==set,]
#  plotdata
  
  trts<-plotdata$TrtLabel
  (ntrts<-length(trts))
  
  
  group<-plotdata$NAME.OF.FORMER.VARIABLE
  ngroup<-length(unique(group[!is.na(group)]))
  
  
  bar.height<-plotdata$LSMean.ALL.DATA 
  se<-plotdata$STDERR.ALL.DATA
  
  trtcmp.pvalue<-plotdata$Pvalue.Diff.ALL.DATA
  cfb.probt<-plotdata$Pvalue.ALL.DATA
  
  dimnames(plotdata)
  
  # Data Range
  ymin<-floor(floor(min(bar.height))*0.5)
  ymax<-ceiling(max(bar.height))*1.2
  
  ymin<-min(bar.height)-abs(max(bar.height)-min(bar.height))/6
  ymax<-max(bar.height)+abs(max(bar.height)-min(bar.height))/6
  
  #------Paramerter may need to adjust--------#
  #### bar.spc: Control space between bars ####
  #-------------------------------------------#
  
  bar.spc<-rep(c(2,1),ngroup) 
  bar.spc
  
  # colors for bars - bars within same group share same color
  
  bar.spc<-rep(c(2,1),ngroup) 
  bar.color<-sort( rep(palette(rainbow(ngroup)),2))
  
  
  #---------------Paramerter may need to adjust----------------#
  ##### width and height controls the orientation of graph #####
  #------------------------------------------------------------#
  png(file=paste(main.title,".png"), width = 800, height = 600)
  
  par(mar=c(10,4,1.5,3), oma=c(0,0,8,0))
  
  bp<-barplot2(as.numeric(bar.height), col=bar.color, 
               space=bar.spc,xpd=F,plot.ci = TRUE,ci.l = bar.height - se, ci.u = bar.height + se,
               plot.grid = TRUE,cex.axis = 1, ylim=c(ymin,ymax))
  
  mtext(side=2, text=paste(ylabel), cex=1.2, line=2.2,font=2)
  mtext(side=4, text=paste(arrow), line=1, cex=2)
  mtext(side=4, text="Improvement",line=1.5, cex=1.2,font=4)
  
  
  #  Add Labels for each group
  for (pv in 1:length(trtcmp.pvalue)){
    #pv<-4
    if(!is.na(trtcmp.pvalue[pv])){
      if (trtcmp.pvalue[pv]!="."){
        mtext(side = 3, at=bp[pv], text=paste(group[pv]), cex=1, font=2,adj=0)
      }
    }
  }
  
  # Add Trt label 
  #---------------Paramerter may need to adjust----------------#
  ##### trt.yadj: adjust vertically  #####
  ##### trt.xadj: adjust horizontally  #####
  #------------------------------------------------------------#  
  trt.xadj<-0.75
  trt.yadj<-0.05
  for (tr in 1:length(trts)){  #  tr<-1
    text(x=bp[tr]-0.5,y=ymin-trt.yadj*(max(bar.height)-min(bar.height)), 
         paste(trts[tr]),pos=4, col="black",cex=1,srt=-45, xpd=TRUE,font=4)        
  }
  
  #Add trtcmp.pvalue   
  #-----Paramerter may need to adjust------#
  ##### pval.xadj: adjustment horizontally  #####
  ##### pval.yadj: adjustment vertically  #####
  #----------------------------------------#  
  # x-space for pvalues
  pval.xadj <- 0.8
  
  #Add pvalues vs cntrl
  for (pv in 1:length(trtcmp.pvalue)){
    #pv<-4
    if(!is.na(trtcmp.pvalue[pv])){
      if (trtcmp.pvalue[pv]!="."){
        mtext(side = 3, at=bp[pv]+1, text=paste("p =",trtcmp.pvalue[pv]), cex=1, font=4, line=-1, col="red")
      }
    }
  }
  
  
  #Add pvalues for change from baseline: cfb.probt
  for (pv in 1:length(cfb.probt)){
    #pv<-1
    if(!is.na(cfb.probt[pv])){
      if (cfb.probt[pv]<0.05){
        text(bp[pv]+pval.xadj,bar.height[pv]*0.75 ,paste("*"), pos=2, 
             col="black", cex=2, font=4, srt=-25)
      }
    }
  }
  
  if(   length(cfb.probt[!is.na(cfb.probt)])>0){
  mtext(side = 1, text="* indicates statistically significantly change from baseline at 0.05 confidence level", cex=1, font=3, line=8)
  }
  

  box()
  
  # Main title
  title(paste(main.title), outer=TRUE, col="black",cex=5,font.main = 4, cex.main=2)
  mtext(paste(subtitle), line=3, cex=1.4)
  dev.off()
  
}
#------------------------ End -----------------------#
##   data.and.plot function - End
########################################################  
  
