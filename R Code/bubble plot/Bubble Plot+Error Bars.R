##########################################
## User Input
path<-"Q:\\beauty_care\\clinical\\Biometrics\\XiaojieZhou\\SAS_R Code\\R Code\\bubble plot\\"


infile<-"bubble data.csv"

inch<-0.25                 #Default size for largest circle in inches
colors<-c("red","blue")    #Day colors
symbols<-c(1,15)           #Symbols for 2 trts (1=open circles,15=closed square)
indata<-read.csv(file=paste(path,infile,sep=""),header=T)





##########################################
Bubble.Plot(yvar="mean_1" , yvar.label= "My Scalp Was Dry", 
            xvar="asfs" , xvar.label="ASFS Group" , trtvar="TrtLabel" , dayvar="StudyDay" ,sizevar="n_3" ,stdvar="stderr_3")
Bubble.Plot(yvar="mean_2" , yvar.label= "My Scalp Was Itchy", 
            xvar="asfs" , xvar.label="ASFS Group" , trtvar="TrtLabel" , dayvar="StudyDay" ,sizevar="n_3" ,stdvar="stderr_3")
Bubble.Plot(yvar="mean_3" , yvar.label= "My Scalp Was Flaky", 
            xvar="asfs" , xvar.label="ASFS Group" , trtvar="TrtLabel" , dayvar="StudyDay" ,sizevar="n_3" ,stdvar="stderr_3")




##########################################
Bubble.Plot <- function(yvar, yvar.label, xvar, xvar.label, trtvar, dayvar,sizevar,stdvar ){
  
# indata<-indata[indata$StudyDay==1,]
head(indata)
y.ind<-which(colnames(indata)==yvar)
x.ind<-which(colnames(indata)==xvar)
d.ind<-which(colnames(indata)==dayvar)
t.ind<-which(colnames(indata)==trtvar)
s.ind<-which(colnames(indata)==sizevar)
sd.ind<-which(colnames(indata)==stdvar)

plotdata<-data.frame(indata[,d.ind],indata[,x.ind],indata[,y.ind],
                     indata[,t.ind],indata[,s.ind],indata[,sd.ind])

colnames(plotdata)<-c("day",'xvar','yvar','trt','size','std')

days<-unique(sort(plotdata$day))
xgrps<-unique(sort(plotdata$xvar))

yrange<-range(plotdata$yvar+c(-2.5,2.5)*plotdata$std)
xrange<-range(seq(1:length(xgrps)))+c(-.5,.5)

trts<-unique(plotdata$trt)
trt1<-trts[1]
trt2<-trts[2]

circs<-plotdata[plotdata$trt==trt1,]
circ.rad<-sqrt(circs$size/pi)/4
sqrs<-plotdata[plotdata$trt==trt2,]
sqr.leng<-2*sqrt(sqrs$size/pi)

par(fig=c(0,1,0,1), bty='o',mar=c(4,5,4,2), lwd=2,cex=0.8)

plot(xrange, yrange, type="n", xaxt="n", xlab=paste(xvar.label), ylab=paste(yvar.label)) 
axis(labels=paste(xgrps),side=1,at=seq(1,length(xgrps)))

mtext(paste(yvar.label,' vs ',xvar.label,sep=""),side=3,outer=FALSE,line=1,cex=1)


 for (i in 1:length(days)) {
  circs.day<-circs[circs$day==days[i],]
  circ.rad.day<-circ.rad[circs$day==days[i]]
  sqrs.day<-sqrs[circs$day==days[i],]
  sqr.leng.day<-sqr.leng[circs$day==days[i]]
  
  #Circles(Trt 1)
  xcoord1<-which(xgrps %in% circs.day$xvar)+.10*i
  symbols(xcoord1,circs.day$yvar,circles=circ.rad.day,
            inches=inch/2,  fg=colors[i],bg=NA,add=TRUE)

  #Error bars
  arrows(xcoord1,circs.day$yvar+circs.day$std, 
         xcoord1,circs.day$yvar-circs.day$std,
         , angle=70, code=3, length=0,col=colors[i]) 
  
  #squares (Trt 2)  
  xcoord2<-which(xgrps %in% sqrs.day$xvar)-.10*i
      symbols(xcoord2,sqrs.day$yvar,squares=sqr.leng.day,
            inches=inch, 
            fg="white",bg=colors[i],add=TRUE)
  #Error bars
  arrows(xcoord2,sqrs.day$yvar+sqrs.day$std, 
         xcoord2,sqrs.day$yvar-sqrs.day$std,
         , angle=90, code=3, length=0,col=colors[i]) 

}


# legend
labels<-NULL

for (j in 1:length(days)) {
  for (i in 1:length(trts)){
    lb<-paste(trts[i],days[j],sep=" @ Day ")
    labels<-rbind(labels,lb)
    row.names(labels)<-NULL
  }
}

colors1<-sort(rep(colors,length(days)), decreasing=T)
symbols1<-rep(symbols,length(days))
  


legend(locator(1),paste(labels),col=colors1, 
       ,pch=symbols1, bty="n")
}
# rm(list=ls())