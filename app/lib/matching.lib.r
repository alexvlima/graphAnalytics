
#Matching JSON TWITTER: relação user words
#Exemplo abaixo está sendo quebrado por palavras
# Dependência SparkR

#To do:
	#Data cleaning


#https://twitter.com/intent/user?user_id=


library(jsonlite)
library(randomNames)
library(SparkR)


setLinkData<-function(strId, word, colName = c("from","to","word")) {

    tryCatch({
        
      #  strId <- stri_enc_toutf8(strId)
        ids <- unique(strsplit(as.character(strId), " ")[[1]])
        idsLen <- length(ids)
        linkedData <- NULL
    
        for(i in 1:idsLen){
           
           jLen <- (idsLen - (i+1)) + 1
           
           if(jLen > 0) {
               subIds <- vector(,jLen)
               p <- i + 1 
               
                for(j in 1:jLen) {
                    subIds[j] <- as.character(ids[p])
                    p <- p + 1
                }
                subLen <- length(subIds)
        
                for(k in 1:subLen) {
                    #linkedData <- rbind(linkedData, data.frame(ids[i],subIds[k], word))
                     linkedData <- rbind(linkedData, data.frame(as.character(ids[i]),as.character(subIds[k]), word))
                }
           }
        
        }
    
        colnames(linkedData) <- colName
    
        return(linkedData)
    }, error=function(e){ 
        #print(i) 
        #print(e) 
    
    })
}


# Recebe json
json = readLines(file('stdin', 'r'), n=1)
#json <- "/var/www/html/int.txt"
raw.data <- readLines(json, warn = "F")
rd <- fromJSON(raw.data)
bagw <- data.frame(rd$text,rd$user)
colnames(bagw) <- c("text","user")

bagwd <- SparkR:::createDataFrame(sqlContext, bagw)
bagwd.rdd <- SparkR:::toRDD(bagwd)


#SparkR RDD

words <-  SparkR:::flatMap(bagwd.rdd,
      function(str) {
        paste(unique(strsplit(as.character(str[1]), " ")[[1]]),str[[2]],sep=".SPL.")
})
                 
wordCount <- SparkR:::lapply(words, function(word) { 
    wordPlit <- strsplit(as.character(word), ".SPL.")[[1]]

    list(wordPlit[[1]],wordPlit[[2]])
  
})

counts <- SparkR:::reduceByKey(wordCount, "paste", numPartitions=2)	  

commonRDD <- SparkR:::filterRDD(counts, function (str) { 
    length(strsplit(as.character(str[2]), " ")[[1]]) > 1 & nchar(str[1]) > 1 & str[1] != 'RT'
})


output <- collect(commonRDD)
outputLen <- length(commonRDD)

#nodes and edges

bagwd.df <- data.frame(matrix(, nrow=outputLen, ncol=2))
colnames(bagwd.df) <- c("word","usrs")

lnkData <- NULL
nodeData <- NULL

i<-0

for (twt in output) {
	wdStr <- twt[[1]]
	wdUsr <- twt[[2]]

	bagwd.df$word[i] <- wdStr
	bagwd.df$usrs[i] <- wdUsr

	lnkd <- setLinkData(wdUsr, wdStr)
	lnkData$edges <- rbind(lnkData$edges, lnkd)

	i <- i + 1
}


## usuarios unicos
s <- unique(unlist(strsplit(bagwd.df$usrs, split = " "), use.names = FALSE))
s <- s[!is.na(s)]


sLen <- length(s)
#nomde de pessoas aleatorias
rName <- unique(randomNames(sLen*3.5, name.order = "first.last", name.sep = " "))




for (i in 1:sLen){
   nodeData$nodes <- rbind(nodeData$nodes, data.frame(s[i],rName[i]))
}

colnames(nodeData$nodes) <- c("id","label")
colnames(lnkData$edges) <- c("from","to","word")


#converte para json pretty deixado como false para lembrar que existe
gphJson <- toJSON(c(nodeData,lnkData), pretty = FALSE)

#retorna o json
write(gphJson, "/var/www/html/rfiles/word-relation.json")


