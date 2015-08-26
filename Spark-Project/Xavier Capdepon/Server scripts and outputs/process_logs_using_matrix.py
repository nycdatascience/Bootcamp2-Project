


# Before running, need to update:
# 1. rows_matrix_simplified 
#  + cols_matrix_simplified
# 2. dictPackages_valueToIndex
# 3. url_log_paths_jan_may_2015

###############################################################################################################################
### FINAL SPARK SCRIPT CODE TO REMOVE IMPORTED PACKAGES
###############################################################################################################################


from pyspark import SparkContext
sc = SparkContext(master='local[10]', appName = 'learnSpark')

import gzip 
from time import strftime
from bs4 import BeautifulSoup
import numpy as np
import pandas as pd
import requests
import re


def extract_info_from_logs(filename):
    with gzip.open(filename, 'rb') as f:
        log_content = pd.read_csv(f)
    
    log_content['date_str']= pd.to_datetime(log_content.date).apply(lambda x: x.strftime('%Y%m%d')).map(str)
    log_content['ip_id'] = log_content.ip_id.map(str).map(lambda x: x.zfill(6))
    log_content['ip_date_id'] = log_content.date_str.map(str)+log_content.ip_id.map(str)
    
    logs_db = log_content[['package','ip_date_id']]
    return logs_db


def extract_package_id_after_mat_process(filename):
    

    
    logs_db = extract_info_from_logs(filename)
    
    ## MATRIX DEFINITION
    ## definition of the sparse matrix
    rows_matrix = [line.strip() for line in open("/home/xaviercapdepon/cran/rows_matrix_simplified", 'r')] #/home/xaviercapdepon/cran/rows_depends
    cols_matrix = [line.strip() for line in open("/home/xaviercapdepon/cran/cols_matrix_simplified", 'r')] #/home/xaviercapdepon/cran/cols_depends 
    #print len(rows_matrix)==len(cols_matrix)
    data_matrix = np.ones(len(rows_matrix))
    #print len(rows_matrix)==len(data_matrix)
    
    ## need the full dimension of the matrix by looking at the number of packages available
    ## download dictionnary of package
    import csv
    reader = csv.reader(open('/home/xaviercapdepon/cran/dictPackages_valueToIndex.txt', 'rb')) #/home/xaviercapdepon/cran/dictPackages_valueToIndex.txt 
    dictPackages_valueToIndex = dict(x for x in reader)
    total_nb_packages = len(dictPackages_valueToIndex)
    
    ## regrouping all info together to form the matrix
    from scipy.sparse import coo_matrix
    depends_matrix = coo_matrix((data_matrix, (rows_matrix, cols_matrix)), shape=(total_nb_packages,total_nb_packages)).toarray()
    depends_matrix
    
    
    
    
    ## from log file
    ## constitue array of unique IP
    unique_IP = logs_db.ip_date_id.unique()
    #print unique_IP

    package_download_by_log = []

    for IP in unique_IP:
        ## contitute set package for each unique IP 
        packages_name_set_by_IP = logs_db.package[logs_db.ip_date_id==IP]
        #print packages_name_set_by_IP
        
        packages_id_set_by_IP = []
        ## change the package names into id
        for i in packages_name_set_by_IP:
            try:     ## the two loops try/excepts are implemented to take care of the packages that are not referenced anymore by CrAN
                individual_packages_id_set_by_IP = int(dictPackages_valueToIndex[i])
                packages_id_set_by_IP.append(individual_packages_id_set_by_IP)
            except:
                packages_id_set_by_IP.append(i)
                pass
                

        packages_id_set_by_IP = set(packages_id_set_by_IP)
        ## column index of packages to be imported for a given package
        # a[x].nonzero()[0] where x is a package id


        # define a final set of package id that will be
        packages_id_set_by_IP_final = packages_id_set_by_IP


        for package_id in packages_id_set_by_IP:
            try:  ## the two loops try/excepts are implemented to take care of the packages that are not referenced anymore by CRAN
                toto = set(depends_matrix[package_id].nonzero()[0])
                packages_id_set_by_IP_final = set(list(packages_id_set_by_IP_final - toto))
            except:
                pass

        package_download_by_IP = list(packages_id_set_by_IP_final)
        #print package_download_by_IP
        package_download_by_log.extend(package_download_by_IP)


    return (package_download_by_log,[logs_db.shape[0]])


#for file_name in ['2012-10-02.csv.gz','2012-10-03.csv.gz','2012-10-04.csv.gz']:
#    print extract_package_id_after_mat_process(file_name)

list_of_files = [line.strip() for line in open("/home/xaviercapdepon/cran/url_log_paths_jan_may_2015", 'r')]
list_of_files = ['/data1/crandata/'+ i for i in list_of_files]
    
doc_log = sc.parallelize(list_of_files)
doc_len = doc_log.map(extract_package_id_after_mat_process)#.filter(lambda x: x is not None)
#print doc_len.collect()



packages_roots = doc_len.map(lambda x: x[0]).flatMap(lambda x:x).collect()
#print packages_roots

# save list of package url on disk in text file
with open('packages_roots', 'w'): pass ## clean file
with open('packages_roots', 'a') as f:
    for item in packages_roots:
        f.write("%s\n" % item)

list_download_by_day = doc_len.map(lambda x: x[1]).flatMap(lambda x:x).collect()
#print list_download_by_day

# save list of package url on disk in text file
with open('list_download_by_day', 'w'): pass ## clean file
with open('list_download_by_day', 'a') as f:
    for item in list_download_by_day:
        f.write("%s\n" % item)