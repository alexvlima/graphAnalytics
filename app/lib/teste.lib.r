# RScript aqui
# Executar com 'rscript teste.lib.r "{a: 0}"' que, chama o arquivo e passa uma string que e um json

# Recebe json
args = commandArgs(trailingOnly=TRUE)

# printa um json de volta
args[1]
