library(XLConnect)
library(tm)


wb = loadWorkbook("B:\\XiaojieZhou\\2014\\GCR Survery\\From Others\\Global English CX Results to Jun 1.xlsx")
Comments = readWorksheet(wb, sheet = "report1433191502074", header = TRUE,startCol=13,endCol=13)
Comments=Comments[!is.na( Comments$CX.Service.Comments),]
Comments=as.data.frame(Comments)


txt<-VectorSource(Comments)
txt.corpus<-Corpus(txt)
txt.corpus<-tm_map(txt.corpus,tolower)
txt.corpus<-tm_map(txt.corpus,removePunctuation)
txt.corpus<-tm_map(txt.corpus,removeNumbers)
txt.corpus<-tm_map(txt.corpus,removeWords,stopwords("english"))
txt.corpus <- tm_map(txt.corpus, PlainTextDocument)
tdm<- TermDocumentMatrix(txt.corpus)
temp <- inspect(tdm)
FreqMat <- data.frame(terms = rownames(temp), freq = rowSums(temp))
row.names(FreqMat) <- NULL
FreqMat<-FreqMat[order(FreqMat$freq,decreasing=T),]
FreqMat$terms=gsub("(<)[a-zA-Z0-9\\+]*(>)",'',FreqMat$terms)



terms<-FreqMat$terms
freq<-FreqMat$freq
terms2test<- FreqMat$term[FreqMat$freq<3]
terms_right<- FreqMat$term[FreqMat$freq>=10]

###obtain the wrong words and dictionary suggestion
# program='C:\\Users\\shi.h.4\\AppData\\Roaming\\SepllCheckers\\Aspell\\bin\\aspell.exe'

program='C:\\Program Files (x86)\\Aspell\bin\\aspell.exe'

result<-aspell(as.factor(terms2test),program=program)
suggestion<-sapply(result$Suggestions, function(x) unlist(x)[1])
non.null.list <- lapply(suggestion,function(x)ifelse(is.null(x), 'NA', x))
suggestion<-unlist(non.null.list)
WrongTerms<-as.data.frame(cbind(result$Original,suggestion))
WrongTerms<-WrongTerms[!WrongTerms$V1== tolower(as.character(WrongTerms$suggestion)),]

DisMat<-adist(terms_right,WrongTerms$V1)
min_dist_index<-apply(DisMat,2, function(x) which(x==min(x))[1] )
min_dist<-apply(DisMat,2, function(x) x=min(x))
Close_terms<-terms_right[min_dist_index]

df2<-cbind(WrongTerms, Close_terms ,min_dist)

df2$Suggestion_combined=tolower(as.character(df2$suggestion))
df2$Suggestion_combined[df2$min_dist ==1]=as.character(df2$Close_terms[df2$min_dist ==1])

#temp=df2[ df2$Suggestion_combined ==df2$Close_terms & !as.character(df2$suggestion) ==df2$Close_terms, ]

