rm(list=ls())
############
#USER INPUT
############
path <-"Q:\\beauty_care\\clinical\\Biometrics\\XiaojieZhou\\SAS_R Code\\R Code\\3in1withLogAxis\\"

setwd(path)

library(gplots)


require(XLConnect)
wb = loadWorkbook("Results Summary.xlsx", create = TRUE)
plotdata = readWorksheet(wb, sheet = "LSMean_LSMeanDiff",  startRow=1, endRow = 81, startCol = 1, endCol = 7, header=TRUE)
head(plotdata)


##################################################################
##################################################################


##################
# Prepare data
##################


# Assign colors based on direction of SNR
# positive & Sig ==> Green
# negative & Sig ==> Red

for (r in 1:nrow(plotdata)){
  if (plotdata$SNR[r] < 0  ){
    plotdata$Direction.color[r]<- "green"
  } else if (plotdata$Direction[r] >= 0){
    plotdata$Direction.color[r]<- "red"
  }
}

x  <- unique(plotdata$Measure)
y1.BL <- plotdata$N_Power_10_80[plotdata$Week=="Baseline"]
y1.Wk16 <- plotdata$N_Power_10_80[plotdata$Week=="Week16"]
y2.BL <- plotdata$Pvalue[plotdata$Week=="Baseline"]
y2.Wk16 <- plotdata$Pvalue[plotdata$Week=="Week16"]
color.BL <- plotdata$Direction.color[plotdata$Week=="Baseline"]
color.Wk16 <- plotdata$Direction.color[plotdata$Week=="Week16"]

##################
#Begin Plotting
##################


png(file="Plot.png", width = 1000, height = 800)

par(fig=c(0,0.75,0.52,1), new=FALSE, bty='o',mar=c(0,2,2,2), oma=c(15,6,5,5),lwd=2)

plot(c(1, length(x)), c(1,500),  ylab="",  xlab="", log="y", xaxt="n", ylim=c(10,500), cex.main=1.5,  main="inner title",type="n")

# Main Title
mtext(paste("FTIR Measurements \n Other Protein Peaks",sep=""),     side=3, line=1.5, outer=TRUE,cex=1.8)


abline(v=1:length(unique(plotdata$Measure)), lty=3, lwd=1, col="gray")
abline(h=50, lty=3, lwd=1, col="gray")
abline(h=100, lty=3, lwd=1, col="gray")
abline(h=490, lty=3, lwd=1, col="gray")
abline(h=200, lty=3, lwd=1, col="gray")

# Plot number of subjects
points((1:length(x)), y1.BL, col="black", bg="gray", pch=21, cex=1.3)
points((1:length(x)), y1.Wk16, col="black", bg="gray", pch=24, cex=1.1)


# Plot Pvalue
par(fig=c(0,0.75,0,0.5) ,new=TRUE, bty='u',mar=c(1,2,0,2),lwd=2)
plot(c(1,length(x)), c(0,1),  xlab="", ylab="", xaxt="n",yaxt="n",ylim=c(0,1),type="n")

abline(v=1:length(x), lty=3, lwd=1, col="gray")
abline(h=0.05, lty=2, lwd=1, col="darkgray")
abline(h=0.1, lty=2, lwd=1, col="darkgray")      

points((1:length(x)), y2.BL, col=color.BL, bg=color.BL, pch=21, cex=1.3)
points((1:length(x)), y2.Wk16, col=color.Wk16, bg=color.Wk16, pch=24, cex=1.2)


axis(side=2,at=(1:10)/10)

# Add X-axis labels
xlabs<- x
text(x=1:length(xlabs),y=rep(-0.1,length(xlabs)), 
     paste(xlabs),
     pos=4, col="black",cex=1.3,srt=-55, xpd=NA,font=1) 

# Add tick marks on x axis
axis(side = 1, at=1:length(x), 
     labels=FALSE,
     cex.axis=0.8,col="black") 

# Add Y-Axis Labels
mtext("# Subjects/Group", side=2,line=1,outer=TRUE, cex=1.5,adj=0.8)
mtext("P-Value", side=2,line=1,outer=TRUE, cex=1.5, adj=0.2)

###########################Plot Legdend#######################################

#  png(file="3in1Plot.png", width = 1000, height = 600)

#  dev.off()

par(fig=c(0.7,1,0,1), new=TRUE, bty='o',mar=c(0,2,2,2), oma=c(15,6,5,5),lwd=2)

x=c(0,10)
y=c(0,10)


plot(x,y, xlab="", ylab="", xaxt="n", yaxt="n", type="n",axes=F)

legend(0,7,
       legend=c("Baseline:  Dandruff vs Non-dandruff","Week 16: Pantene-D vs BC1-D"), pch=c(21,24),
       col=c("black","black"),pt.bg=c("white","white"),
       bty="n",box.col="gray",pt.cex=c(2,1.5), x.intersp=2,
       xpd=NA, cex=1.2, ncol=1)


text(0.1,4.2,paste("Colors indicate direction of difference\n between groups",sep=""), cex=1.2, adj=0)

legend(0,3.7,
       legend=c("Dandruff   < Non-dandruff at BL      ","Dandruff   > Non-dandruff at BL",     
                "Pantent-D < BC1-D at Week 16",         "Pantent-D > BC1-D at Week 16"), pch=c(21,21, 24, 24),
       col=c("red","green","red","green"),pt.bg=c("red","green","red", "green"),
       bty="n",box.col="gray",pt.cex=c(2,2,1.5,1.5), x.intersp=2,
       xpd=NA, cex=1.2, ncol=1)


dev.off()
###################################Plot Legdend############################


