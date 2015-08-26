

# Before running, update url_log_full_paths file.

####################################################
### FINAL SCRIPT FOR SPARK TO DOWNLOAD LOG FILES
####################################################


from pyspark import SparkContext
sc = SparkContext(master='local[7]', appName = 'learnSpark')

import numpy as np
from bs4 import BeautifulSoup
import requests
import re
import csv
import urllib


# fonction to download and save the log files /  ready for parallelisation:
def download_log(url_log):
    path_with_log_name = '/data1/crandata/'+ re.sub('(http:\/\/cran-logs.rstudio.com\/[0-9]+\/)','',url_log)
    urllib.urlretrieve(url_log, path_with_log_name)  
    

url_log_full_paths = [line.strip() for line in open("url_log_full_paths.txt", 'r')]

print 'Spark started'
    
doc_log= sc.parallelize(url_log_full_paths[1003:1007])  #1004:1054
doc_log.map(download_log).collect()

print 'Spark finished'