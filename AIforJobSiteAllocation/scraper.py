import elasticsearch
import pandas as pd
import csv
from elasticsearch_dsl import Search

# Set the number of instances you want to scrape before stopping
numRows = 500000

c=elasticsearch.Elasticsearch('https://fifemon-es.fnal.gov')
s = Search(using=c, index="hepcloud-classads-slots-*").extra(size=10000)
response = s.execute()
i = 0

with open('output_file.csv', 'a+') as f:  
    entireKeyList = []
    header_present = False
    for doc in response:
        my_dict = doc.to_dict()
        keyList = my_dict.keys()
        entireKeyList = entireKeyList + list(set(keyList) - set(entireKeyList))
    for doc in s.scan():
        if i > numRows:
            break
        i = i + 1
        my_dict = doc.to_dict()
        if not header_present:
            w = csv.DictWriter(f, entireKeyList, extrasaction='ignore')
            w.writeheader()
            header_present = True
        w.writerow(my_dict)
    f.close()
