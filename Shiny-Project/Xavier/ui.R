# ui.R
#library(R2HTML)

shinyUI(
  navbarPage("MTA Transit",
    tabPanel("Overview",
      fluidPage(
             #HTML('<center><img src="./www/AllBusesSubways2.png",height="604",width="800"> </center>')
             img(src="AllBusesSubways2.png",height=604,width=800,align="center")
             )),
    tabPanel("Data Analysis",
      fluidPage(
        titlePanel("New York Transit Map"),
      
        sidebarLayout(
          sidebarPanel(
            helpText("Please allow 30 to 45s for loading."),
            ## Analysis of Travel Time      
            radioButtons("analys_subw", 
                         label = h5("Select Subway Line(s):"),
                         choices = list("Line 1" = 1, 
                                        "Line 4" = 4,
                                        "Line 1 & 4" = 3),
                                        selected = 1),
            radioButtons("analys_direct", 
                         label = h5("Select Direction:"),
                         choices = list("North" = "N", 
                                        "South" = "S" ),
                                        selected = "S"),
            checkboxInput("analys_delays", "Show delays:", value = FALSE),
            sliderInput("analys_timeint", 
                        label = "Depart Time Interval:",
                        min = 0, 
                        max = 24,
                        step=1, 
                        value = c(0,24)),
            helpText("Subway portion studied: Bronx - downtown Manhattan."), br(),
            helpText("Line 1: Local, 36 stations,",br(),
                     "Line 4: Express, 16 stations."),br(),helpText("What line is faster ? What line is more reliable ?")
          ),
            
    
        mainPanel(
          
          tabsetPanel(
            tabPanel("Map",
                     img(src="Subways14.png",height=768,width=640)
                     #span(plotOutput("MTAMap"))
                     ),
            
            tabPanel("Definitions",
                     h3("Hypothesis:"),
                     p("The data analysis was made on the portion of the subways lines 1 and 4 from the Bronx to downtown Manhattan"),
                     p("Given the unexpected behaviour of some trains on hold for 30+ min. at the train terminals, the analysis was effectued on the following portions:"), 
                     p("- South Direction (S): a) from 238th station to either Rector and South Ferry stations for line 1 and b) from the Mosholu Pkwy station to either Wall Street or Bowling Green stations for line 4 (due to a lack of datapoints: see Sources below)"),
                     p("- North Direction (N): a) from Rector station to either 238th and 242th street stations for line 1 and b) from Whitehall Street to either Moshulu Pkwy or Woodlawn stations for line 4 (due to a lack of datapoints: see Sources below)"),
                     br(),
                     h3("Sources:"),
                     p("Buses and Subways Maps were generated with RStudio using the MTA info Static Data Feeds:", a("MTA for Developer", href="http://web.mta.info/developers/developer-data-terms.html#data")),
                     p("The historical Subway traffic time data were with Python package 'google.transit' built using the MTA API:", a("Real Time Data Feeds - Subway TimeTM",href="http://datamine.mta.info/"), ". The feeds provide the real time data for line 1-2-3, 4-5-6 and the S line between Times Square and Grand Central. The real time data was downloaded every 5 minutes for a period of 5 days starting July 7th, 2015 (subject to change). Reasonnaly, the data shall have been downloaded every 90s in order to catch most of the traffic."),
                     p("Delays were collected with Python BeautifulSoup (webscraping) every 5 minutes (subject to change) on:", a("MTA info Service Status", href="http://www.mta.info/"), ".")
              ),
            
            tabPanel("Analysis",
                     plotOutput("Alys")),
            
            tabPanel("Appendix",
                     h3("Google Maps:"),
                     p("Line 1: 238th-SouthFerry 62min (Tues 8am)"),
                     p("Line 4: Mosholu Pkwy 59min (Tues 8am)"),
                     br(),
                     p("Metro RATP Paris: 20 to 26km/h (12.4-16.1 mph) -- source: LeMonde 2011"),
#                      br(),
#                      h5("Other transportation:"),
                     p("NY Yellow Cab: 13,7km/h (8.51mph) in 2014, source: July 10-12 amnewyork 2015")
#                      p("Paris Taxi: ~16km/h (10mph)")
#                      p("")
                     )
            
              
                     
                     
          )
        )
        ) 
   )    
  ),
    tabPanel("Subway Real Time",
      fluidPage(
        sidebarLayout(
          sidebarPanel(
             helpText("The feed is loaded through Python google.transit package into the data folder (file:mtaRealTime.ipynb ."),
             radioButtons("real_time_NS", 
                          label = h5("Select Direction:"),
                          choices = list("North" = "N", 
                                         "South" = "S" ),
                          selected = "N"),
             radioButtons("real_time_line", 
                          label = h5("Select Subway Line(s):"),
                          choices = list("Line 1" = 1, 
                                         "Line 6" = 6 
                                         ),
                          selected = 1)
             ),
        mainPanel(
               plotOutput("realTimeMap")
             )
      ))
    )
 )
)
