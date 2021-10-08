import re
import csv

arquivo = open('databasePontos.pl', 'w')

with open('dataset.csv') as ficheiro:
    reader = csv.reader(ficheiro)
    for line in reader:
       latitude = re.sub(r',','.',line[0])
       longitude = re.sub(r',','.',line[1]) 
       sepID = re.split(":",line[4])
       if len(sepID)>2:
            arquivo.writelines("ponto(" + latitude + "," + longitude + "," + line[2] + ",'" 
            + line[3] + "'," + sepID[0] + ",'" + sepID[1] + "','" + sepID[2] + "','" + line[5] +
            "','" + line[6] + "'," + line[7] + "," + line[8] + "," + line[9] + ").\n")
       elif len(sepID)>1 and len(sepID)<2:
            arquivo.writelines("ponto(" + latitude + "," + longitude + "," + line[2] + ",'" + line[3] +
            "'," + sepID[0] + ",'" + sepID[1] + "','" + line[5] +
            "','" + line[6] + "'," + line[7] + "," + line[8] + "," + line[9] + ").\n")

arquivo.close()