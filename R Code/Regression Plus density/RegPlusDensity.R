path<-"Q:\\beauty_care\\clinical\\Biometrics\\XiaojieZhou\\Capability\\Graph Lib\\Regression Plus density"

set.seed(12413)

beta0<-10
beta1<-0.5
n<-40
group<-c(rep(1,n),rep(0,n))
sd.x<-5
sd.y<-5

x<-c(rnorm(n)*sd.x+10, rnorm(n)*sd.x+20)
y<-beta0+beta1*x+group*10+rnorm(2*n)*sd.y



#######################################
## Reg plot
fit<-lm(y ~ group+x )
summary(fit)

## png(width=1000,height=1000,paste(path,"\\ANCOVA Plot+Histogram.png",sep=""),pointsize = 10)

par(fig=c(0,1,0,1), bty='o')
par(mar=c(4,4,4,2), lwd=3)

range.x<-c(0, max(x)*1.2)
range.y<-c(0,range(y)[2]*1)

plot(x,y,col=group+1,ylim=range.y,xlim=range.x, pch=group+16,cex=0.7, ylab='CFB',xlab='Baseline', new=TRUE,yaxt='s')
#,xaxt='n',bty='n')

line1<-c(coef(fit)[1],coef(fit)[3])
line2<-c(coef(fit)[1]+coef(fit)[2],coef(fit)[3])
abline(line1,lty=1,col=1, new=TRUE, lwd=3)
abline(line2,lty=1,col=2, new=TRUE, lwd=3)

text(locator(1),"Trt", col="Red", cex=1.1)
text(locator(1),"Cntrl", col="Black", cex=1.1)


mean.x.0<-mean(x[group==0])
mean.x.1<-mean(x[group==1])
mean.x<-mean(x)

mean.y.0<-coef(fit)[1]+coef(fit)[3]*mean.x.0
mean.y.1<-coef(fit)[1]+coef(fit)[3]*mean.x.1+coef(fit)[2]

mean.y0<-coef(fit)[1]+coef(fit)[3]*mean.x
mean.y1<-coef(fit)[1]+coef(fit)[3]*mean.x+coef(fit)[2]

segments(mean.x,mean.y0,mean.x,mean.y1,lty=1, col="Blue")
points(mean.x.0,mean.y.0,pch=15, cex=1.2, col="Black")
points(mean.x.1,mean.y.1,pch=15, cex=1.2, col="Red")

segments(mean.x.1,mean.y.0,mean.x.1,mean.y.1,lty=1, col="Blue")
segments(mean.x.0,mean.y.0,mean.x.1,mean.y.0,lty=2, col="Blue")


text(locator(1), "LS Mean Diff", col="Blue")


text(locator(1), "Raw Mean Diff",col="Blue")

# plot densities 

par(fig=c(0,1,0,0.4), new=TRUE ,bty='n',lwd=2 )
library(sm)
sm.density.compare(x, group,  xlab='', ylab="", xlim=range.x, col=c(1,2) ,xaxt='n', yaxt='n', frame.plot=T, lty=c(2,2))


#  legend(locator(1), levels(cyl.f), fill=colfill) 


mtext("Least Squares Mean vs Raw Mean", side=3, outer=TRUE, line=-3, cex=2) 

text(mean(x[group==0]), 0, "*", cex = 0.8)
text(mean(x[group==1]), 0, "*", cex = 0.7, col=2)
text(mean(x), 0, "*", cex = 0.5, col=2)


text(locator(1), "distribution of baseline values")

segments(mean.x.1,0,mean.x.1, 0.1,lty=2, col="Red")

segments(mean.x.0,0,mean.x.0, 0.08,lty=2, col="Black")



#p1 <- locator(1)
#p2 <- locator(1)
#segments(p1$x, p1$y, p2$x, p2$y, col = 'Red', lty=4)



#p1 <- locator(1)
#p2 <- locator(1)
#segments(p1$x, p1$y, p2$x, p2$y, col = 'Black', lty=4)
