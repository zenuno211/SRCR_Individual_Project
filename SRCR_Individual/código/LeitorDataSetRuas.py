import re
import csv
#rua(IDrua, latitude ,longitude ,[contentor_Residuo], soma de contentor_total_litros)
arquivo = open('databaseRuas.pl', 'w')

residuos = []
somaContentor = 0
anterior = None
contador = 0
latitude = None
longitude = None
fsLine = True

with open('dataset.csv') as ficheiro:
    reader = csv.reader(ficheiro)
    for line in reader:
       sepID = re.split(":",line[4])
       if anterior is not None and (anterior==sepID[0]):
           print("passou" + anterior)
           fsLine = False
           residuos.append(line[5])
           somaContentor = somaContentor + int(line[9])
       
       elif anterior is not None and fsLine:
            fsline = False
            anterior = sepID[0]
            latitude = re.sub(r',','.',line[0])
            longitude = re.sub(r',','.',line[1]) 
            somaContentor = int(line[9])
            residuos = []
            residuos.append(line[5])
            contador = 1

       else:
           if fsLine: 
               anterior = sepID[0]
               print("fsline")
           else:   
               if anterior is not None and longitude is not None and latitude is not None:
                   residuosProlog = re.sub('\"','\'',str(residuos))
                   arquivo.writelines("rua(" + anterior + "," + latitude + "," + longitude + "," + residuosProlog + "," + str(somaContentor) + ").\n")  
               anterior = sepID[0]
               latitude = re.sub(r',','.',line[0])
               longitude = re.sub(r',','.',line[1]) 
               somaContentor = int(line[9])
               residuos = []
               residuos.append(line[5])
               contador = 1
    residuosProlog = re.sub('\"','\'',str(residuos))
    arquivo.writelines("rua(" + anterior + "," + latitude + "," + longitude + "," + residuosProlog + "," + str(somaContentor) + ").\n")    

arquivo.close()