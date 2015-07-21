###### Back calculate SD of the data from Diff and SE of treatment difference ########

# calculate SE from pvalue and diff assuming normal distribution
    diff=0.306
    pvalue=0.0016
    
    s.effect=qnorm(p=pvalue/2, mean=0)
    s.effect
    
    se.norm=abs(diff/s.effect)
    se.norm

# calculate standard error from pvalue and diff assuming t-test with df degree of freedom
    diff=20.984-9.259
    pvalue=0.001
    df=37
    
    s.effect=qt(p=pvalue/2, df=df, ncp=0, lower.tail = TRUE, log.p = FALSE)
    
    se.t=abs(diff/s.effect)
    se.t

#  Calculate SE from SD 
    n1=183
    n2=185
    sd=12.81
    
    se=sd*sqrt(1/n1+1/n2)
    se

#  Calculate SD from SE
    n1=42
    n2=42
    se=c(2.119, 2.357)
    
    sd=se/sqrt(1/n1+1/n2)
    sd
