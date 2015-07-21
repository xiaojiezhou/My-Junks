############
#USER INPUT
############

study<-"Q:\\beauty_care\\clinical\\Biometrics\\Lin Fei\\2012\\CRB 12-04-054 - Surf and Turf"
path<-"Q:\\beauty_care\\clinical\\Biometrics\\XiaojieZhou\\SAS_R Code\\R Code\\BarPlot"


setwd(path)

require(XLConnect)


wb = loadWorkbook("Q:\\beauty_care\\clinical\\Biometrics\\Lin Fei\\2012\\CRB 12-04-054 - Surf and Turf\\Xiaojie\\Plots\\Pre_post wash Results for Plot 17June2013 v1.xlsx", create = TRUE)
indata = readWorksheet(wb, sheet = "Combined",  startRow=3, endRow = 57, startCol = 1, endCol = 26, header=TRUE)
indata<-indata[!is.na(indata[,2]),]
dim(indata)
dimnames(indata)

library(gplots)

##################################################################
#### Prepare data for plotting #####
indata[,2]<- sub("Un_YMD_Mean", "Unwashed", indata[,2])
indata[,2]<- sub("Wa_YMD_Mean", "Washed", indata[,2])
indata[,4]<- sub("Endpt", "Week 8", indata[,4])
indata[,4]

names(indata)[14]<-paste("bar.height")
names(indata)[16]<-paste("se")

names(indata)[3]<-paste("trts")
names(indata)[4]<-paste("group1.names")
names(indata)[2]<-paste("group2.names")
names(indata)[18]<-paste("cfb.probt")
names(indata)[25]<-paste("trtcmp.pvalue")



########## By cGroup:  Trt vs Cntrl ##########

#---- Set up global parameters ---#
subtitle1="Measured by OFDA "
bar.spc1 <-c(2,1,2,1,4,1,2,1)
bar.color1<-rep(c("deepskyblue4", "aliceblue"),4)


plotdata=indata[(indata$group2.names !="Washedaway") & (indata$cGroup=="BC368PNC vs Cntrl") & ( (indata$group1.names =="BL") | (indata$group1.names =="Week 8")),]
bar.plot (trts=plotdata$trts, 
          group1.names= c("Unwashed","Washed","Unwashed","Washed" ), 
          group1.hpos=c(2,4,6,8), 
          group1.side=1,
          group1.line=-1,
          group2.names= c("BL", "Week 8"), 
          group2.hpos=c(2,6),
          group2.side=3,
          group2.line=1,
          main.title="BC368PNC vs Its Control")


bar.color1<-rep(c("darkolivegreen3", "deepskyblue4"),4)
plotdata=indata[(indata$group2.names !="Washedaway") & (indata$cGroup=="KelpP vs Cntrl") & ( (indata$group1.names =="BL") | (indata$group1.names =="Week 8")),]
bar.plot (trts=plotdata$trts, 
          group1.names= c("Unwashed","Washed","Unwashed","Washed" ), 
          group1.hpos=c(2,4,6,8), 
          group1.side=1,
          group1.line=-1,
          group2.names= c("BL", "Week 8"), 
          group2.hpos=c(2,6),
          group2.side=3,
          group2.line=1,
          main.title="Kelp&P vs Its Control")

bar.color1<-rep(c("darksalmon", "deepskyblue4"),4)
plotdata=indata[(indata$group2.names !="Washedaway") & (indata$cGroup=="NAcGluc vs Cntrl") & ( (indata$group1.names =="BL") | (indata$group1.names =="Week 8")),]
bar.plot (trts=plotdata$trts, 
          group1.names= c("Unwashed","Washed","Unwashed","Washed" ), 
          group1.hpos=c(2,4,6,8), 
          group1.side=1,
          group1.line=-1,
          group2.names= c("BL", "Week 8"), 
          group2.hpos=c(2,6),
          group2.side=3,
          group2.line=1,
          main.title="NAG vs Its Control")

dev.off()

#---- All groups:  by visit (BL, CFB, Endpt) ---#
subtitle1="Measured by OFDA "
bar.spc1 <-c(2,1,2,1,2,1,4,1,2,1,2,1)
bar.color1<-rep(c("deepskyblue4", "aliceblue", "darkolivegreen3", "deepskyblue4", "darksalmon", "deepskyblue4"),2)


plotdata=indata[ (indata$group2.names !="Washedaway") & (indata$group1.names =="BL") ,]
bar.plot (trts=plotdata$trts, 
          group1.names= c("Unwashed","Washed"), 
          group1.hpos=c(4,10), 
          group1.side=3,
          group1.line=1,
          group2.names= c(" "), 
          group2.hpos=c(2),
          group2.side=3,
          group2.line=1,
          main.title="Hair Diameter at Baseline")

plotdata=indata[(indata$group2.names !="Washedaway") &  (indata$group1.names =="Week 8") ,]
bar.plot (trts=plotdata$trts, 
          group1.names= c("Unwashed","Washed"), 
          group1.hpos=c(4,10), 
          group1.side=3,
          group1.line=1,
          group2.names= c(" "), 
          group2.hpos=c(2),
          group2.side=3,
          group2.line=1,
          main.title="Hair Diameter at Week 8")

plotdata=indata[(indata$group2.names !="Washedaway") &  (indata$group1.names =="CFB") ,]
bar.plot (trts=plotdata$trts, 
          group1.names= c("Unwashed","Washed"), 
          group1.hpos=c(4,10), 
          group1.side=3,
          group1.line=1,
          group2.names= c(" "), 
          group2.hpos=c(2),
          group2.side=3,
          group2.line=1,
          ylabel.left="Change From BL (um)", 
          main.title="Hair Diameter CFB at Week 8")


plotdata=indata[ (indata$group2.names =="Washedaway") & (indata$group1.names !="CFB"),]
plotdata

bar.plot (trts=plotdata$trts, 
          group1.names= unique(plotdata$group1.names), 
          group1.hpos=c(4,10), 
          group1.side=3,
          group1.line=1,
          group2.names= c(" "), 
          group2.hpos=c(2),
          group2.side=3,
          group2.line=1,
          ymin=2, ymax=6,
          trtcmp.pvalue.xadj=1,
          trtcmp.pvalue.line=-2,
          arrow="-------------------------- ", 
          ylable.right=" ",
          ylabel.left="Unwashed - washed diameter Difference (um)", 
          main.title="Hair Diameter Difference Due to Washing")

########## Begining of the bar.plot function  ##########

bar.plot <- function(trts=plotdata$trts, 
                     group1.names= c("Unwashed","Washed","Unwashed","Washed" ), 
                     group1.hpos=c(2,4,6,8), 
                     group1.side=3,
                     group1.line=1,
                     group2.names= c("BL", "Week 8"), 
                     group2.hpos=c(3,7),
                     group2.side=3,
                     group2.line=2,
                     bar.height=plotdata$bar.height, 
                     ci.u = plotdata$bar.height +  plotdata$se,
                     ci.l = plotdata$bar.height -  plotdata$se,                    
                     trtcmp.pvalue=plotdata$trtcmp.pvalue,
                     trtcmp.pvalue.xadj=-1,
                     trtcmp.pvalue.line=-2,
                     cfb.probt=plotdata$cfb.probt,
                     cfb.probt.xadj=1,
                     bar.color=bar.color1, bar.spc=bar.spc1, 
                     ymin=floor(min(plotdata$bar.height)*0.95), 
                     ymax=ceiling(max(plotdata$bar.height)*1.05), 
                     ylabel.left="Left Label", 
                     arrow="--------------------------> ", 
                     ylable.right="Favorable",
                     main.title="Main Title", 
                     subtitle=subtitle1){
 
     
  ntrts = length(trts)
  ngroup1 = length(group1.names)
  ngroup2 = length(group2.names)
  
  png(file=paste(main.title,".png"), width = 800, height = 600)
  
  
  par(mar=c(10,4,1.5,3), oma=c(0,0,8,0))
  
  bp<-barplot2(as.numeric(bar.height), col=bar.color, 
               space=bar.spc,xpd=F,plot.ci = TRUE,ci.l = ci.l, ci.u = ci.u,
               plot.grid = TRUE,cex.axis = 1, ylim=c(ymin,ymax))
  
  mtext(side=2, text=paste(ylabel.left), cex=1.5, line=2.2,font=2)
  mtext(side=4, text=paste(arrow), line=1, cex=2)
  mtext(side=4, text=paste(ylable.right),line=1.5, cex=1.5,font=4)
  
  
  #  Add Labels for each group
  for (i in 1:ngroup1){
    # i=1
    mtext(side = group1.side, at=bp[group1.hpos[i]], text=paste(group1.names[i]), cex=1.5, font=2, adj=1, line=group1.line)
  }
  
  
  #  Add Labels for each group
  for (i in 1:ngroup2){
    # i=1
    mtext(side = group2.side, at=bp[group2.hpos[i]], text=paste(group2.names[i]), cex=1.5, font=2, adj=1, line=group2.line)
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
         paste(trts[tr]),pos=4, col="black",cex=1.3,srt=-55, xpd=TRUE,font=4)        
  }
  
  #Add trtcmp.pvalue: Trt vs Control  
  for (pv in 1:length(trtcmp.pvalue)){
    #pv<-4
    if(!is.na(trtcmp.pvalue[pv])){
      if (trtcmp.pvalue[pv]!="."){
        mtext(side = 3, at=bp[pv]+trtcmp.pvalue.xadj, text=paste("p =",trtcmp.pvalue[pv]), cex=1.3, font=4, line=trtcmp.pvalue.line, col="red")
      }
    }
  }
   
  #Add pvalues for change from baseline: cfb.probt
  for (pv in 1:length(cfb.probt)){
    #pv<-1
    if(!is.na(cfb.probt[pv])){
      if (as.numeric(cfb.probt[pv])<0.05){
        text(bp[pv]+cfb.probt.xadj,bar.height[pv]*0.75 ,paste("*"), pos=2, 
             col="black", cex=2, font=4, srt=-25)
      }
    }
  }
  
  if(   length(cfb.probt[!is.na(cfb.probt)])>0){
    mtext(side = 1, text="* indicates statistically significantly change from baseline at 0.05 confidence level", cex=1, font=3, line=8)
  }
  
  
  box()
  
  # Main title
  title(paste(main.title), outer=TRUE, col="black",cex=5,font.main = 4, cex.main=2, line=5)
  mtext(paste(subtitle), line=4, cex=1.5)
  dev.off()
}
########## End of the bar.plot function  ##########
