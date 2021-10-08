import pandas as pd
import re

dados=pd.read_csv("dataset.csv", encoding='utf-8', sep=",",decimal =".").dropna()

saveFile = open('arestas.pl','w',encoding='utf-8')
valores = [] 
valores1 = []
valores2 = []
arestas = []

dict ={}
for i in range(0,dados.shape[0]): 
    for j in range(0,dados.shape[1]): 
        if j == 4: 
            valores = str(dados.iloc[i,j]).split(":")
            informacaoRua=valores[1]        
            numeroRua = valores[0]
            if informacaoRua not in dict : 
                dict[informacaoRua] = numeroRua 

for i in range(0,dados.shape[0]):
    for j in range(0,dados.shape[1]):
        if(j == 4 ) :
            
            valores1 = str(dados.iloc[i,j]).split(":") 
            numeroRua1=valores1[0]
            if len(valores1)> 2 :
                ruas = valores1[2].replace(" ","")[0:-1] 
            
                rua = ruas.split("-") 
                for k in rua :
                    for d in dict.keys():
                        if re.search(r'\(',d):
                            ruinha = d.split("(")
                            
                        if re.search(r',',d):
                            ruinha = d.split(",")

                        ruaComparacao = ruinha[0].replace(" ","")
                         
                        if k == ruaComparacao:    
                            numeroRuaNova = dict[d] 
                            if (numeroRua1,numeroRuaNova) not in arestas:
                                saveFile.write('aresta(')
                                saveFile.write(str(numeroRua1))
                                saveFile.write(', ')
                                saveFile.write(str(numeroRuaNova))
                                saveFile.write(').')
                                saveFile.write('\n')
                                arestas.append((numeroRua1,numeroRuaNova))
anterior = None
for v in dict.values():
    if anterior is not None:
        if (anterior,v) not in arestas:
                saveFile.write('aresta(')
                saveFile.write(str(anterior))
                saveFile.write(', ')
                saveFile.write(str(v))
                saveFile.write(').')
                saveFile.write('\n')
                arestas.append((anterior,v))
    anterior = v
saveFile.close()
