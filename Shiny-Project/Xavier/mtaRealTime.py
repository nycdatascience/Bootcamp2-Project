from google.transit import gtfs_realtime_pb2
import urllib
import time
import datetime

from bs4 import BeautifulSoup
import requests
import re
import json

### save in file definition
def cleanfile():
    # 'a' to add line to txt file
    with open('data/mtaRealTime.txt', 'w'): pass




### save in file definition
def savefile(listitems):
    # 'a' to add line to txt file
    with open('data/mtaRealTime.txt', 'a') as f:
            f.write(listitems + '\n')


def loopdwlmta(x):

    #cleanfile realtime txt
    #cleanfile()

    #system time for reference
    tmpSys = datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d %H:%M:%S')

    ##load list of lines perturbated
    #listlineperturbated = listofperturbations(urllist)

    ## send request to api mta.info using my own key
    feed = gtfs_realtime_pb2.FeedMessage()
    response = urllib.urlopen('http://datamine.mta.info/mta_esi.php?key=5a8f6f4375e9f4bdea9b0c86afeaf911')
    feed.ParseFromString(response.read())


    ## looping the content downloaded
    for entity in feed.entity:
        if entity.HasField('trip_update'):

            ## trip update: 3 data characterisitcs
            TripIdi = entity.trip_update.trip.trip_id
            StartDatei = entity.trip_update.trip.start_date
            Routei = entity.trip_update.trip.route_id
            #if Routei in listlineperturbated:
            #    Delaysi = "delays"
            #else:
            Delaysi = ""


            ## trip alert: 1 data characterisitcs
            if entity.HasField('alert'):
                Alerti = entity.alert.header_text
            else:
                Alerti = ''

            ## looking to record first 3 predicted arrival time 
            Arrivetmp=[]
            stop_id=[]

            tripcomplete = []

            if len(entity.trip_update.stop_time_update) <> 0:
                #record only first three trip updates
                p3trip = min(len(entity.trip_update.stop_time_update),1)

                j=0
                while j < p3trip:
                    tripcomplete = []
                    #print j
                    ArrivalTime = entity.trip_update.stop_time_update[j].arrival.time
                    stop_id = entity.trip_update.stop_time_update[j].stop_id
                    station_nth=j

                    tripcomplete.extend([tmpSys,TripIdi,StartDatei,Routei,Alerti,station_nth,stop_id,ArrivalTime,Delaysi])
                    #print tripcomplete, type(tripcomplete)
                    tripcomplstr = ','.join([str(i) for i in tripcomplete])
                    #savefile(tripcomplstr)
                    print tripcomplstr

                    j+=1

loopdwlmta(1)


# if __name__ == "__main__":
#     import time
#     while True:
#         try:
#             loopdwlmta(1)
#         except:
#             continue
#         time.sleep(30)
