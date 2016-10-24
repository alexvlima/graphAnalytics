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


#bibloteca necessaria
library(jsonlite)

# Recebe json
json = readLines(file('stdin', 'r'), n=1)

#transforma em um atomic vector
json = fromJSON(json)

#processamento aqui

#transforma o atomic vector em um json
json = toJSON(json)

#retorna o json
write(json, '')
