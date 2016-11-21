## Filtra tweets por palavras. Caso exista mais de uma separar por virgula
## Apresenta como size no node a quantidade de retweets
## Relacao dos edges e por tweet e word

## echo json_content | Rscript app/lib/filtered-tweet.lib.r --word=the --rtwt=200 --label
# Formato do json a ser retornado: 
#{
#	'nodes': [
#		{
#			'id': 'id do tweet',
#			'label': 'tweet text',
#     'size': 'qtd retweet'
#		}
#	],
#	'edges': [
#		{
#			'from': 'id do tweet',
#			'to': 'id do tweet',
#     			'label': 'word'
#		}
#	]
#}

if(!require(RCurl,quietly = TRUE)) install.packages('RCurl',dependencies=TRUE, repos="http://cran.rstudio.com/")
if(!require(jsonlite,quietly = TRUE)) install.packages('jsonlite',dependencies=TRUE, repos="http://cran.rstudio.com/")
if(!require(digest,quietly = TRUE)) install.packages('digest',dependencies=TRUE, repos="http://cran.rstudio.com/")
    
suppressWarnings(suppressMessages(library(RCurl)))
suppressWarnings(suppressMessages(library(jsonlite)))
suppressWarnings(suppressMessages(library(digest)))

## CLI inicio
args = commandArgs(TRUE)

parseArgs <- function(x) strsplit(sub("^--", "", x), "=")
argsDF <- as.data.frame(do.call("rbind", parseArgs(args)))
argsL <- as.list(as.character(argsDF$V2))
names(argsL) <- argsDF$V1

qtdRtwt <- -1
pattern <- ""
showLabel <- FALSE
	
if( !is.null(argsL$rtwt)) {
	qtdRtwt <- as.numeric(argsL$rtwt)
}

if( !is.null(argsL$word)) {
	pattern <- argsL$word
} else {
	print("Passar pelo menos a palavra de pesquisada no socket --word=palavra")
}
	
if( !is.null(argsL$label)) {
	showLabel <- TRUE
}
## CLI fim    

concatWord <- function(bagwDF, minOccur=0) {
    tryCatch({
        concatDF <- aggregate(bagwDF$id,bagwDF['word'],paste,collapse=',')
        colnames(concatDF) <- c("word", "id")
        #caso tenha mais de minOccur iteracoes da palavra
        concatDF <- concatDF[countCharOccurrences(',', concatDF$id) > minOccur, ]
        rownames(concatDF) <- NULL
        return(concatDF)
    }, error=function(e){ 
        #print(i) 
        #print(e) 
    })
}

countCharOccurrences <- function(char, s) {
    s2 <- gsub(char,"",s)
    return (nchar(s) - nchar(s2))
}

cleanText <- function(text, join = TRUE) {
    pangram <- text
    pangram <- gsub("^RT([^:]*.)","",pangram, perl=TRUE)
    pangram <- gsub("[[:punct:]]", "", pangram)
    
    if(join) {
      pangram <- gsub("\\s", "", pangram)  
    }
    
    return (pangram)
}

shirnkText <- function(text) {
    sntzText <- cleanText(text, FALSE)
    sntzText <- substr(sntzText, 1, 139)
    sntzText <- tolower(sntzText)
    return (sntzText)
}

checksumText <- function(text) {
    
    sntzText <- cleanText(text)
    sntzText <- substr(sntzText, 2, 30)
    
    cehcksum <- digest::digest(sntzText,algo='md5', serialize = FALSE)
    return (cehcksum)
}

vectorFind <- function(patt, text) {
    
    cPatt <- unlist(strsplit(patt, ","))
    cLen <- length(cPatt)
 
    for(i in 1:cLen) {
        print(grepl(cPatt[i], text))
    }
}

permuteUser <- function(userArr, twoWay = TRUE, colName = c("from","to")) {
    
    lnkdUser <- NULL
    
    if(twoWay) {
        lnkdUser <- expand.grid(userArr,userArr)
        colnames(lnkdUser) <- colName
        lnkdUser <- lnkdUser[which(lnkdUser$from != lnkdUser$to),]
        row.names(lnkdUser) <- NULL           
    } else {
            
        lnkdUser <- combn(userArr, 2, simplify=FALSE) 
    }
    
    return (lnkdUser)
}

#URL <- "localhost:1234/collection/Local/twitter/tweets/export/true"
#rawJson <- getURLContent(URL)
rawJson = readLines(file('stdin', 'r'), n=1)    
rd <- fromJSON(rawJson)
bagTwt <- data.frame(rd$id, rd$text,rd$user, rd$retweet_count, rd$retweeted_status)
colnames(bagTwt) <- c("id","text","user","retweet_count","retweeted_status")
##gera o md5 do texto do twiter

bagTwt$chksum <- sapply(bagTwt$text, checksumText)
bagTwt$text_small <- sapply(bagTwt$text, shirnkText)
bagTwt[, 4] <- as.numeric(as.character( bagTwt[, 4] ))

bagTwt <- bagTwt[which(is.na(bagTwt$retweeted_status)),]
bagTwt <- aggregate(bagTwt$retweet_count, by=list(id=bagTwt$chksum, text=bagTwt$text_small), FUN=sum)
colnames(bagTwt) <- c("id","text","qtd_rtw")

## Padrao retweets > -1
bagTwt <- bagTwt[which(bagTwt$qtd_rtw > qtdRtwt ),]
    
#head(bagTwt)

#pattern <- "murica"
pattern <- tolower(pattern)
pattVect <- unlist(strsplit(pattern, ","))
pattVectLen <- length(pattVect)

bgwDF  <- data.frame(id= character(0), word= character(0), qtd = integer(0))

for(i in 1:pattVectLen){
    
    pattLower <- pattVect[i]

    filteredDF <- bagTwt[which(grepl(pattLower,bagTwt$text)),]
    ftdLen <- nrow(filteredDF)
    
    if(ftdLen > 0) {
        for (j in 1:ftdLen) {
            bgwDF <- rbind( bgwDF, data.frame(filteredDF$id[j],pattLower,1 ))
        }           
    }

    #filteredDF <- NULL

}
colnames(bgwDF) <- c("id","word","qtd")
#bgwDF
if(nrow(bgwDF) < 1) {
	##opt <- options(show.error.messages=FALSE) 
	##on.exit(options(opt)) 
	stop('{"nodes":[], "edges":[]}')
}
	
bgwDF <- aggregate( as.matrix(bgwDF[,3]), as.list(bgwDF[,1:2]), FUN = sum)
bgwDF.concat <-concatWord(bgwDF,-1)
len <- nrow(bgwDF.concat)
#head(bgwDF.concat, 50)


## CRIA ARQUIVO DE SAIDA

logFile <- tempfile()

cat("", file=logFile, append=FALSE, sep = "")

ukTwt <- unique(unlist(unique(strsplit(bgwDF.concat$id, split = ","), use.names = FALSE)))
ukTwt <- ukTwt[!is.na(ukTwt)]
ukTwtLen <- length(ukTwt)

ukIdDF  <- data.frame(id= character(0), label= character(0), size = integer(0))
bagTwtLen <- nrow(bagTwt)

if(bagTwtLen > 0) { 
    for(i in 1:ukTwtLen){
        for(j in 1:bagTwtLen) {
            if(ukTwt[i] == bagTwt$id[j]) {
                ukIdDF <- rbind( ukIdDF, data.frame(ukTwt[i],bagTwt$text[j],bagTwt$qtd_rtw[j] ))
                break
            }   
        }
    }    
}
colnames(ukIdDF) <- c("id","label","size")
#head(ukIdDF)

## CLUSTER INICIO
ukIdDFScale <- na.omit(ukIdDF$size)
ukIdDFScale <- scale(ukIdDFScale)
qtdUkIdDFScale <- nrow(unique(ukIdDFScale))
qtdCluster <- 0

wss <- (nrow(ukIdDFScale)-1)*sum(apply(ukIdDFScale,2,var))

if(!is.na(wss)){
	qtdCluster <- as.numeric(wss[1])
}
if(qtdCluster > 10) {
	qtdCluster <- 10
	qtdUkIdDFScale <- 10
}
if(qtdCluster > 2) {
	fit <- kmeans(ukIdDFScale, qtdUkIdDFScale)
	ukIdDFScale <- data.frame(ukIdDFScale, fit$cluster)
	colnames(ukIdDFScale) <- c( "scale", "cluster" )  
	ukIdDF <- cbind(ukIdDF,ukIdDFScale)
}
## CLUSTER FIM

## CRIA OS NODES DO ARQUIVO JSON graphi

if(qtdCluster > 2) {
	nodeDF <- ukIdDF[,c("id","label","size","cluster")]
	nodeDF <- within(nodeDF,  cluster <- paste("G",as.character(cluster), sep=""))
} else {
	nodeDF <- ukIdDF[,c("id","label","size")]
	nodeDF <- within(nodeDF,  cluster <- paste("G1", sep=""))
}

colnames(nodeDF) <- c("id","label","size","group")
ukUsr <- NULL

cat('{', file=logFile, append=TRUE, sep = "\n")
cat('"nodes": [', file=logFile, append=TRUE, sep = "\n")

##output como JS
##cat('var nodes = [', file=logFile, append=TRUE, sep = "\n")

nodeJson <- toJSON(nodeDF, pretty = FALSE)
nodeJson <- gsub("^\\[", "", nodeJson)
nodeJson <- gsub("\\]$", "", nodeJson)

cat(nodeJson, file=logFile, append=TRUE, sep = "\n")

cat(']', file=logFile, append=TRUE, sep = "\n")
cat(',', file=logFile, append=TRUE, sep = "\n")

##output como JS
##cat('];', file=logFile, append=TRUE, sep = "\n")

# cria os edges do visio JSON graphi
#bgwDF.concat
len <- nrow(bgwDF.concat)

edgeStr <- NULL
cat('"edges": [', file=logFile, append=TRUE, sep = "\n")

##output como JS
#cat('var edges = [', file=logFile, append=TRUE, sep = "\n")

for (i in 1:len){
    
    usrWord <- as.character(bgwDF.concat[i,1])
    usrArr <- strsplit(bgwDF.concat[i,2], ",")[[1]]
    p <- i + 1
    
    if(grepl(",", bgwDF.concat[i,2])) {
	usrPermute <- (permuteUser(usrArr, TRUE))

    	if(showLabel) {
    		usrPermute$label <- usrWord 
    	}
    	edgeJson <- toJSON(usrPermute, pretty = FALSE)
    	edgeJson <- gsub("^\\[", "", edgeJson)
    	edgeJson <- gsub("\\]$", "", edgeJson)
    
    	cat(edgeJson, file=logFile, append=TRUE, sep = "")
    
    	if(i < len & grepl(",", bgwDF.concat[p,2]) ) {
        	cat(",", file=logFile, append=TRUE, sep = "\n")
    	}
    }
}

cat('\n]', file=logFile, append=TRUE, sep = "\n")
cat('}', file=logFile, append=TRUE, sep = "\n")

##output como JS
##cat('\n];', file=logFile, append=TRUE, sep = "\n")

strOut <- readChar(logFile, file.info(logFile)$size)

unlink(logFile, recursive=TRUE)
write(strOut, stdout())
