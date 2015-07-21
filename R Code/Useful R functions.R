
########## Fill the next cell with value from previous row if it is blank ###############
retains<-function(in.col)
{
  temp<-in.col
  for (i in 1:length(temp)){
    if (temp[i]=="")
      temp[i]=temp[i-1]
  }
return(temp)
}

#  indata$PrimaryAnal<-retains(indata$PrimaryAnal)
#  head(indata)

########## remove dots and < and convert it to numberic p-value  ###############

c2n.pvalue<-function(cpvalue)
{
  temp<-sub("<", "0", cpvalue)
  
  for (i in 1:length(temp)){
    if (temp[i]=='.' | is.na(temp[i]))
      temp[i]="NA"
  }
  
  return(as.numeric(temp))
}

#  c2n.pvalue(cpvalue)
