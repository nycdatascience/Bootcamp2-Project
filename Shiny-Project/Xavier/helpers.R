# line=1
# direction="N"
# timeinf=0
# timesup=24
# datafile=mtafile_cleaned
# delays=NULL



graph_trip_time_subway<-function(line,timeinf,timesup,datafile,delays,direction){
  ## Select line and directions:
#   line_input = line
#   direct_input = c('S')
  
  
  
  library(dplyr)
  library(lubridate)
  library(chron)
  
  ## Given the timeframe for the project, the calculation is simplified:
  ## A. Given the unexpected behaviour happening at terminal, the train time is going to be capture on the first station after terminal
  ## B. Given that the historical file is updated every 5 min, the train arrival time is going to be capture on last two stations to get more significant data points
  ## => B. the update needs to be fixed in future.
  
  ## Select start and arrival station:
  ## we are limiting the study to line 1 and 4 for purpose of this exercise:
  ##
  if (direction=='S'){
    station_line = c("103S","139S","140S","402S","419S","420S")
    starting_station = c("103S","402S")
  } else {
    station_line = c("101N","103N","139N","401N","402N","420N")
    starting_station = c("139N","420N")
  }
  
  #starting_station = paste(ss, direct_input, sep="")
  mtahist010 = filter(datafile,
                      Route %in% line,
                      stop_id %in% starting_station )
  
  mathist011 = filter(mtahist010,timesup>chron::hours(mtahist010$TmpSys),
                                 timeinf<chron::hours(mtahist010$TmpSys))

  ## isoler les ID des trains partant entre les 2 dates
  mathist013 = distinct(arrange(mathist011,desc(ArrivalTime)), TrainId)

  
  ## in the large historique file, isolate the ID from prev step
  mathist015 = filter(datafile, TrainId %in% mathist013$TrainId)

  mathist016 = filter(mathist015,stop_id %in% station_line)%>%
    group_by(.,TrainId) %>%
    mutate(.,tempsroulage=(max(ArrivalTime)-min(ArrivalTime))/60)
  mathist017=  arrange(mathist016,desc(tempsroulage))
  mathist018=  distinct(arrange(mathist016,desc(tempsroulage)), TrainId)
  mathist019 = (filter(mathist018,tempsroulage>1))
  #mean(mathist019$tempsroulage)

  #color for graph
  if (length(line)==1){
    if (line==1){
      couleurline = c("#EE352E")
    } else{
      couleurline = "#00933C"
    }
  } else {
    couleurline = c("#EE352E","#00933C")
  }
  print(line)
  print(direction)
  print(couleurline)
  Sys.setenv(TZ='GMT')
  library(ggplot2)
  if (delays==FALSE){
    g = ggplot(mathist019, aes(TmpSys,tempsroulage, group=Route,color=Route)) + 
      geom_point(alpha=.7) +
      coord_cartesian(ylim=c(0,100)) +
      geom_smooth(method="auto") +
      geom_rug() +
      scale_color_manual(values=couleurline)+
      xlab("Depart Time") +
      ylab("Travel Time (in minutes)") +
      ggtitle("MTA Subway Travel Time") +
      scale_x_chron(format="%H:%M")
  } else {
    g = ggplot(mathist019, aes(TmpSys,tempsroulage)) + 
      geom_point(aes(group=Route,color=Route),alpha=.7) +
      coord_cartesian(ylim=c(0,100)) +
      geom_smooth(aes(group=Route,color=Route),method="auto") +
      geom_rug(aes(group=Route,color=Route)) +
      geom_point(aes(group=Delays,size=Delays,color=Route)) +
      scale_color_manual(values=couleurline)+
      xlab("Depart Time") +
      ylab("Travel Time (in minutes)") +
      ggtitle("MTA Subway Travel Time") +
      scale_x_chron(format="%H:%M")
  }
  return(g)
}


graph_real_time<-function(file,subwayline,realTimeDirection){

#subwayline = c(1)
#realTimeDirection="N"
  
  ##############################
  #   Change the direct path   #
  ##############################
  
  ## modified script for nyc data science server
  fileData <- system("sudo /usr/bin/python mtaRealTime.py", intern=TRUE)
  tester <- sapply(fileData,function (x) {strsplit(x,split = ",")} )
  filetxt <- as.data.frame(matrix(ncol = 10))
  for(i in 1:length(tester)) {
    filetxt <- rbind(filetxt,tester[[i]])
  }
  filetxt <- filetxt[-1,]
  filetxt = select(filetxt, tmpSys=V1,
                   TripId=V2,
                   StartDate=V3,
                   Route=V4,
                   alert=V5,
                   j=V6,
                   stop_id=V7,
                   ArrivalTime=V8,
                   jenesaisquoi=V9)

## Load real time data feed using Python (launch file mtaRealTime.ipynb in shiny app folder)
mtaRealTimeRaw = filetxt #read.csv("data/mtaRealTime.txt",header=FALSE,stringsAsFactors = FALSE)
names(mtaRealTimeRaw) <- c('tmpSys','TripId','StartDate','Route','alert','j','stop_id','ArrivalTime','Delays')



### capture colors of the subway lines:
routes = read.csv("data/routes.txt")
stops = read.csv("data/stops.txt")

###colors associated with lines + change 'GS' for 'S'
### add # in front forcolor HEX
routes002 = select(routes,route_id,route_color) %>% 
  mutate(route_color = paste0("#", route_color))
routes002$route_color[18]<-'#6D6E71'
routes002$route_color[26]<-'#2850AD'
routes002$route_color[28]<-'#6D6E71'
routes003 = filter(routes002, route_id %in% subwayline)

###subway stops :parent_station==''
stops002 = filter(stops,parent_station=='')
stops003 = mutate(stops002,route_id = substr(stop_id,1,1))
stops005 = filter(stops003, route_id %in% subwayline)
## => ready for print using routes003

## prepare stops for inner joint with real time data:
stops_RT = mutate(stops,route_id=substr(stop_id,1,1)) %>%
  filter(., route_id %in% subwayline) %>% 
  select(.,c(1:6),-stop_code,-stop_desc)




## Datafile Setup:
## Select only first record for each trainId for each time stamp: j==0
## Add direction N or S 
## Capture and convert time from date stamps
## Add col of unique trainID
mtahist001 = filter(mtaRealTimeRaw,j==0) %>% filter(.,Route==subwayline)
mtahist002 = mutate(mtahist001,Direction=substr(mtahist001$stop_id,4,5)) %>%
  filter(.,Direction==realTimeDirection)%>%
  mutate(.,TrainId = paste(TripId,StartDate,sep=""))
mtahist002 = mutate(mtahist002,Location=ifelse(ArrivalTime==0,"At Station","Arriving"))
mtahist004 = mutate(mtahist002,ArrivalTime=ifelse(ArrivalTime==0,
                                                  as.numeric(ymd_hms(mtahist002$tmpSys, tz = "America/New_York")),
                                                  ArrivalTime))
mtahist003 = mutate(mtahist004,TmpSys=substr(tmpSys,12,20))
mtahist003$TmpSys <- chron(times. = mtahist003$TmpSys)
mtafile_cleaned = mtahist003

combined <- sort(union(levels(mtafile_cleaned$stop_id), levels(stops_RT$stop_id)))
mtaRT1_coord <- left_join(mutate(mtafile_cleaned, stop_id=factor(stop_id, levels=combined)),
               mutate(stops_RT, stop_id=factor(stop_id, levels=combined)),by='stop_id')

# mtaRT1_coord = left_join(mtafile_cleaned,stops_RT, by='stop_id')

library(ggplot2)
graph002 = ggplot() +
  geom_path(data=stops005,
            aes(stop_lon, 
                stop_lat, 
                color=route_id
            ),
            size=5) +
  scale_color_manual(values=c(routes003$route_color,"blue","green","red"))+
  geom_point(data=stops005,
             aes(stop_lon, 
                 stop_lat),
             size=2.5,
             color="white")+
  geom_point(data=mtaRT1_coord,
             aes(stop_lon, 
                 stop_lat,
                 group=Location,
                 color=Location
             ),
             size=5,
             alpha=1
             #shape=c("N","S"),
             #color=c("blue","green"),
  )+
  geom_text(data=mtaRT1_coord,
            aes(stop_lon, 
                stop_lat,label=stop_name),hjust=1, vjust=1, angle=-45,size = 4)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(panel.background = element_rect(fill = "white"))+
  ylab("")+
  xlab("")+
  coord_cartesian(xlim=c(-74.1,-73.80),ylim=c(40.65,41))
  #coord_fixed()
graph002
}

