# RScript aqui
# =======================
# Essa eh uma bibloteca de teste, nao transformando dados em rede para
# provar o conceito. Assim provado, fazer uma para cada funcao que o R tera
# Dados a receber a definir para task acima
# =======================
# NODEJS
# mude o JSON no arquivo abaixo de acordo com o desejado
# caso de erro o json retornado e invalido 
# para usar o node para testar passando json, execute (na pasta raiz):
# node .\app\utils\rjson.server.util.js
# =======================
# Standalone
# O json usado no 'echo' abaixo deve ser no fomato descrito logo em seguida
# Executar com 'echo "{a: 0}" | rscript teste.lib.r ' que, chama o arquivo e
# passa uma string que eh um json, por pipe (stdin)
# =======================

# Definir campos do JSON
# Definir approach
# Definir funcoes

# Formato do json a ser retornado: 
#{
#	'nodes': [
#		{
#			'id': 'id do tweet dele',
#			'label': '@usuario: tweet texto aqui'
#		}
#	],
#	'edges': [
#		{
#			'from': 'id do tweet',
#			'to': 'id do tweet'
#		}
#	]
#}

if(!require(RCurl)) install.packages('RCurl',dependencies=TRUE, repos="http://cran.rstudio.com/")
if(!require(jsonlite)) install.packages('jsonlite',dependencies=TRUE, repos="http://cran.rstudio.com/")
if(!require(randomNames)) install.packages('randomNames',dependencies=TRUE, repos="http://cran.rstudio.com/")
#if(!require(mongolite)) install.packages('mongolite',dependencies=TRUE, repos="http://cran.rstudio.com/")
    
#http://ec2-52-67-202-64.sa-east-1.compute.amazonaws.com:1234/collection/Local/twitter/tweets/export/true
#http://ec2-52-67-202-64.sa-east-1.compute.amazonaws.com:1234/collection/Local/twitter/users/export/true

library(RCurl)
library(jsonlite)
library(randomNames)


pivotText <- function(userId, text, minWord = 4, colName = c("user","word")) {
    
    tryCatch({
        text <- tolower(text)
        spltText <- strsplit(text, " ")[[1]]

        bagw.expd <- expand.grid(c(userId),spltText)
        colnames(bagw.expd) <- colName
        bagw.expd <- bagw.expd[!(nchar(as.character(bagw.expd$word)) < minWord),]
        #rownames(bagw.expd) <- seq(length=nrow(bagw.expd))
        rownames(bagw.expd) <- NULL
        return(bagw.expd)
        
    }, error=function(e){ 
        #print(i) 
        #print(e) 
    })
}

concatWord <- function(bagwDF, minOccur=0) {
    tryCatch({
        
        concatDF <- aggregate(bagwDF$user,bagwDF['word'],paste,collapse=',')
        colnames(concatDF) <- c("word", "user")
        #caso tenha mais de minOccur iteracoes da palavra
        concatDF <- concatDF[countCharOccurrences(',', concatDF$user) > minOccur, ]
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

permutations <- function(n){
    if(n==1){
        return(matrix(1))
    } else {
        sp <- permutations(n-1)
        p <- nrow(sp)
        A <- matrix(nrow=n*p,ncol=n)
        for(i in 1:n){
            A[(i-1)*p+1:p,] <- cbind(i,sp+(sp>=i))
        }
        return(A)
    }
}

## retorn JSON de API adminMongo stdin comentado
URL <- "localhost:1234/collection/Local/twitter/tweets/export/true"
rawJson <- getURLContent(URL)
#rawJson = readLines(file('stdin', 'r'), n=1)
rd <- fromJSON(rawJson)
bagw <- data.frame(rd$text,rd$user)
colnames(bagw) <- c("text","user")


#head(bagw)
bagwLen <- nrow(bagw)
#bagwLen

bgwDF <- NULL

for (i in 1:bagwLen){
    
    userId <- as.character(bagw$user[i])
    pangram <- tolower(as.character(bagw$text[i]))
    pangram <- gsub("[[:punct:]]", " ", pangram)
    
    #pvText <- pivotText("27434900",pangram, 6)
    pvText <- pivotText(userId,pangram, 6)
    pvText$qtd <- 1
    
    #print(head(pvText))
    
    if(i == 1) {
        bgwDF <- pvText
    } else {        
        bgwDF <- rbind(bgwDF,pvText)
    }
}
#nrow(bgwDF)
#head(bgwDF, 12)

## remove a mesma palavra mencionada pela mesma pessoas
bgwDF <- aggregate( as.matrix(bgwDF[,3]), as.list(bgwDF[,1:2]), FUN = sum)

bgwDF.concat <- concatWord(bgwDF,4)
len <- nrow(bgwDF.concat)
#head(bgwDF.concat, 50)

## CRIA ARQUIVO DE SAIDA

logFile <- tempfile()
#print(logFile)
##logFile = "/var/www/outfile/log_file.js"
cat("", file=logFile, append=FALSE, sep = "")


## CRIA OS NODES DO ARQUIVO JS visjs
    
ukUsr <- unique(unlist(unique(strsplit(bgwDF.concat$user, split = ","), use.names = FALSE)))
ukUsr <- ukUsr[!is.na(ukUsr)]
ukUsrLen <- length(ukUsr)
randName <- randomNames(ukUsrLen, name.order = "first.last", name.sep = " ")


nodeDF <- data.frame(ukUsr,randName)
colnames(nodeDF) <- c("id","label")
ukUsr <- NULL


cat('var nodes = [', file=logFile, append=TRUE, sep = "\n")

nodeJson <- toJSON(nodeDF, pretty = FALSE)
nodeJson <- gsub("^\\[", "", nodeJson)
nodeJson <- gsub("\\]$", "", nodeJson)

cat(nodeJson, file=logFile, append=TRUE, sep = "\n")

cat('];', file=logFile, append=TRUE, sep = "\n")

#bgwDF.concat
len <- nrow(bgwDF.concat)

edgeStr <- NULL

cat('var edges = [', file=logFile, append=TRUE, sep = "\n")


for (i in 1:len){
    
    usrWord <- as.character(bgwDF.concat[i,1])
    usrArr <- strsplit(bgwDF.concat[i,2], ",")[[1]]
    usrPermute <- (permuteUser(usrArr, TRUE))
   
   # usrPermute$label <- usrWord 
     
    edgeJson <- toJSON(usrPermute, pretty = FALSE)
    edgeJson <- gsub("^\\[", "", edgeJson)
    edgeJson <- gsub("\\]$", "", edgeJson)
    
    cat(edgeJson, file=logFile, append=TRUE, sep = "")
    
    if(i < len ) {
        cat(",", file=logFile, append=TRUE, sep = "\n")
    } 

}

cat('\n];', file=logFile, append=TRUE, sep = "\n")

# faz o output do arquivo, dependendo ter de colocar print
strOut <- readChar(logFile, file.info(logFile)$size)
#remover arquivo temporario
unlink(logFile, recursive=TRUE)
write(strOut, stdout())
