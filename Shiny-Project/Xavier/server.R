source("helpers.R")
source("global.R")

##1. Map creation using static MTA transit static 


##2. Load the file for historical data 
## based on scrap of real time MTA API
library(dplyr)
library(lubridate)
library(chron)

# ## Load historical file of real time data records built using Python.
# mtahist = read.csv("data/mta.txt",header=FALSE,stringsAsFactors = FALSE)
# names(mtahist) <- c('tmpSys','TripId','StartDate','Route','alert','j','stop_id','ArrivalTime','Delays')
# 
# ## Datafile Setup:
# ## Select only first record for each trainId for each time stamp: j==0
# ## Add direction N or S 
# ## Capture and convert time from date stamps
# ## Add col of unique trainID
# mtahist001 = filter(mtahist,j==0)
# mtahist002 = mutate(mtahist001,Direction=substr(mtahist001$stop_id,4,5)) %>%
#   mutate(.,TrainId = paste(TripId,StartDate,sep=""))
# mtahist004 = mutate(mtahist002,ArrivalTime=ifelse(ArrivalTime==0,
#                                                   as.numeric(ymd_hms(mtahist002$tmpSys, tz = "America/New_York")),
#                                                   ArrivalTime))
# mtahist003 = mutate(mtahist004,TmpSys=substr(tmpSys,12,20))
# mtahist003$TmpSys <- chron(times. = mtahist003$TmpSys)
# saveRDS(mtahist003, "mtaHistoricalFeed.rds")
## file was saved in rds format for better results on shiny server
mtafile_cleaned = readRDS("data/mtaHistoricalFeed.rds")


i="ready"
print(i)

#################################################

source("helpers.R")

shinyServer(
  function(input, output,session) {

    ##1. management of outputs for subway and bus map    
    #finallistbus_react <- reactive({shapesbus_filefct(input$buses,shapes)})
    
    #mapsubways_buses <- reactive({drawmap(input$subways,shapesbus_filefct(input$buses,shapesbuses))})
    #output$MTAMap <- renderPlot({mapsubways_buses})
    
    
    ##2. drawing analytics charts using ggplot
    ## chart Travel Time vs Depart Time
    
    analys_temps <- reactive({input$analys_timeint})
    analys_subway <- reactive({input$analys_subw})
    analys_delays <-reactive({input$analys_delays})
    analys_direction <- reactive({input$analys_direct})
    
    output$Alys <- renderPlot({
      line = analys_subway()
      if (line==3) {line=c(1,4)}
      
      borneinf = min(analys_temps())
      bornesup = max(analys_temps())
      
      graph_trip_time_subway(line,
                             borneinf,bornesup,
                             mtafile_cleaned,
                             analys_delays(),
                             analys_direction())})
    
    
    ##3. Real time MTA Map
    
    ## original script for my own computer
    #fileData <- reactiveFileReader(1000, session, 'data/mtaRealTime.txt',read.csv)
    #filetmp <- reactive({fileData()
    #                     read.csv("data/mtaRealTime.txt",header=FALSE,stringsAsFactors = FALSE)})
    
    ## modified script for nyc data science server
    autoInvalidate <- reactiveTimer(10000, session)
    
    reatTime_direct <- reactive({input$real_time_NS})
    reatTime_line <- reactive({input$real_time_line})
    output$realTimeMap <- renderPlot({autoInvalidate()
                                      graph_real_time(2,reatTime_line(),reatTime_direct())})
    
    
  }
)