
#Faz o maching entre o filtro e pessoas que escreveram alguma coisa
#Exemplo abaixo está sendo quebrado por palavras
# Dependência SparkR

#To do:
	#Data cleaning


#https://twitter.com/intent/user?user_id=


json_file <- "in.txt"
raw.data <- readLines(json_file, warn = "F")
rd <- fromJSON(raw.data)

bagw <- data.frame(rd$text,rd$user)
colnames(bagw) <- c("text","user")

bagwd <- createDataFrame(sqlContext, bagw)
bagwd.rdd <- SparkR:::toRDD(bagwd)


words <-  SparkR:::flatMap(bagwd.rdd,
    function(str) {
        paste(strsplit(as.character(str[1]), " ")[[1]],str[[2]],sep=".SPL.")
  })
                 
wordCount <- SparkR:::lapply(words, function(word) { 
    wordPlit <- strsplit(as.character(word), ".SPL.")[[1]]


    list(wordPlit[[1]],wordPlit[[2]])
    
})

counts <- SparkR:::reduceByKey(wordCount, "paste", numPartitions=2)


commonRDD <- SparkR:::filterRDD(counts, function (str) { 

 
    length(strsplit(as.character(str[2]), " ")[[1]]) > 1

})


output <- collect(commonRDD)
outputLen <- length(commonRDD)

bagwd.df <- data.frame(matrix(, nrow=outputLen, ncol=2))
colnames(bagwd.df) <- c("word","usrs")

i<-0

for (twt in output) {
   #cat(twt[[1]], ": ", twt[[2]], "\n")
   bagwd.df$word[i] <- twt[[1]]
   bagwd.df$usrs[i] <- twt[[2]]
   i <- i + 1
}


head(bagwd.df,4)