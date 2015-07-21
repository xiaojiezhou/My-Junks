
path<-"Q:\\clinical\\Biometrics\\HairBiology\\Studies\\2013\\CRB 13-04-044 RL\\Xiaojie\\R"
setwd(path)

###### Read in data ###### 
require(XLConnect)
wb = loadWorkbook("OFDA Summary.xlsx", create = TRUE)
indata = readWorksheet(wb, sheet = "Sheet1",  startRow=2, endRow = 9, startCol = 1, endCol = 9, header=TRUE)

indata

###### Meta-analysis via metafor###### 
require(metafor)

#--- random effect model ---#
res<- rma.uni(yi=Diameter_Mean, sei=Diameter_StdErr, data=indata )
res

#--- Mixed effect model ---#
mix.res <- rma(yi=Diameter_Mean, sei=Diameter_StdErr,  mods = PNC.level.1, data = indata)
mix.res

#-- Foest plot --#

png(file="Overal PNC Diameter Benefit - Forest Plot.png", width = 800, height = 400)
par(cex=1.1)

forest(res, slab=paste(indata$StudyNo))

text(0, 10, "Mean Diameter Difference (95% CI) Between Minoxidil & its Control", cex=1.5, font=2)
text(-9, 8.5, "CRB No.")
text(9, 8.5, "Diff (95%CI)")

text(9.2, -1.7, "Overall Effect",font=3)
text(9.2, -1.45, "__________________")

dev.off()

#-- Other plot and tests --#
funnel(res, main="Random Effect Model")
qqnorm(res,main="Random Effect Model")

regtest(res, model="lm")
blup(res)

#-- radial plot of random and fixed effect model --#
par(mfrow=c(1,2))
radial(res, main="Random Effect Model")

res.fe<- rma.uni(yi=Diameter_Mean, sei=Diameter_StdErr, data=indata, method="FE" )
radial(res.fe, main="Fixed Effect Model")



