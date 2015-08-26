from pyspark import SparkContext
sc = SparkContext(master='local[10]', appName = 'learnSpark')


####################################################
### FINAL SCRIPT FOR SPARK FOR MATRIX CONSTRUCTION
####################################################
## All script to build depends/imports / Reverse matrix


import numpy as np
from bs4 import BeautifulSoup
import requests
import re
import csv

#definition of web scarping extracting function 

def extract_url_content(urlv):
        # Request by url and headers
        headers=None
        req =  requests.get(urlv, headers=headers)
        demande = req.text
        # Request status code
        statut_demande = req.status_code
        if statut_demande/100 in [4,5]:
            return 'error on requests with error: ', statut_demande
        return BeautifulSoup(demande)

headers = None


## modification of the definition above for the purpose of Spark parallelisation

## for purpose of running through Spark, we change the structure of the sparce matrix into list of tuple 
## that will be easier to deal with using Spark

headers = None
def pull_sparse_matrix_Depends_Imports_url(url_link):
    # definition of list that will serve to built a sparce matrix
    depends_row = []
    depends_col = []
    depends_data = []
    
    Reverse_row = []
    Reverse_col = []
    Reverse_data = []
    
    depends_tuple = tuple()
    Reverse_tuple = tuple()
    result_depends_rev = []
    
    package_name = re.search('https://cran.r-project.org/web/packages/.*index.html', url_link)
    package_name2 = package_name.group()
    #print header2
    package_name3 = re.sub('(https://cran.r-project.org/web/packages/)|(/index.html)','',package_name2)
    #print package_name3
    
    j=dictPackages_valueToIndex[package_name3]

    # web scraping of the link using beautiful soup
    headers = None
    textpackageindex= extract_url_content(url_link)
    #print textpackageindex.prettify

    # extract all tag tr
    textpackage = textpackageindex.find_all('tr')
    #print textpackage

    # extract text from in the tr tag
    textPackageIndex = []
    for part in textpackage:
        textPackageIndex.append(part.get_text())
    #print textPackageIndex

    # determine where the 'depends' information is located:
    for text in textPackageIndex:
        #print 'TEXT TO BE EXAMINED', text

               

        if re.search('(Reverse\\xa0depends:\n.*)|(Reverse\\xa0imports:\n.*)', text)!=None: # detect if the word "Imports" is mentionned in text, if so:
            # text is cleaned and the package "Imports" are stored in a list
            Reverse= re.search('(Reverse\\xa0depends:\n.*)|(Reverse\\xa0imports:\n.*)', text) 
            Reverse2 = Reverse.group()
            #print header2
            Reverse3 = re.sub('(Reverse\\xa0depends:\n)| |\([^)]*\)|(Reverse\\xa0imports:\n)','',Reverse2)
            Reverse4 = Reverse3.split(',')
            #print Imports3
            #print Reverse4

            new_items = 0
            for i in Reverse4:
                try: 
                    toto = dictPackages_valueToIndex[i]
                    Reverse_col.append(toto)
                    Reverse_row.append(j)
                    Reverse_data.append(1)
                    #print Imports_col
                    new_items +=1
                except:
                    pass
            if len(Reverse_row)!=0:
                Reverse_tuple = [((Reverse_col[i],Reverse_row[i]), Reverse_data[i]) for i in range(len(Reverse_row))]
                #print Reverse_tuple
    
    if len(depends_tuple)!=0:
        result_depends_rev.append(depends_tuple)
    if len(Reverse_tuple)!=0:
        result_depends_rev.append(Reverse_tuple)
    if len(result_depends_rev)!=0:
        return [val for sublist in result_depends_rev for val in sublist]

## download list of package urls
url_package_list = [line.strip() for line in open("/home/xaviercapdepon/cran/list_package_url.txt", 'r')] #/home/xaviercapdepon/cran/list_package_url.txt 

packages_url=url_package_list

## download dictionnary of package
import csv
reader = csv.reader(open('/home/xaviercapdepon/cran/dictPackages_valueToIndex.txt', 'rb')) #/home/xaviercapdepon/cran/dictPackages_valueToIndex.txt 
dictPackages_valueToIndex = dict(x for x in reader)


## pure python loop for verification of results against spark
#for i in url_package_list[:7]:
#    print i
#    print pull_sparse_matrix_Depends_Imports_url(i)

doc = sc.parallelize(url_package_list)
doc_len = doc.map(pull_sparse_matrix_Depends_Imports_url).filter(lambda x: x is not None)
a = doc_len.flatMap(lambda x:x)
a.cache()
print a.collect()

rows_depends = a.map(lambda x: x[0][0]).collect()


# save list of package url on disk in text file
with open('rows_sparse_mat', 'w'): pass ## clean file
with open('rows_sparse_mat', 'a') as f:
    for item in rows_depends:
        f.write("%s\n" % item)

cols_depends = a.map(lambda x: x[0][1]).collect()

# save list of package url on disk in text file
with open('cols_sparse_mat', 'w'): pass ## clean file
with open('cols_sparse_mat', 'a') as f:
    for item in cols_depends:
        f.write("%s\n" % item)