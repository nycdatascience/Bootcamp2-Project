# ui.R
#library(R2HTML)

shinyUI(
  navbarPage("Fastest Subway Line in NYC",
    tabPanel("Overview",
      fluidPage(
        titlePanel(h3("Redrawing NY City Map using Public Transportation Data")),
        sidebarLayout(
         sidebarPanel(
           helpText("New York City public transportation is heavily used by all the commuters from the five boroughs and outside of the city. The transit network is among the largest ones in the world and is characterized by the coverage of five main area separated by rivers.", 
                    br(),
                    br(), 
                    "Right: The map is generated using NYC public transportation bus and subway network static data files (see Sources). The brighter lines indicate multiple bus lines on the same path.", 
                    br(), 
                    "Manhattan benefits from a heavy and parallel network. The network in the others borough, on the other hand, are more transversal or designed to bring commuters towards Manhattan. ")),
          mainPanel(img(src="AllBusesSubways2.png",height=604,width=800,align="center"))))),

    
    tabPanel("Subway Timing Analysis",
      fluidPage(
        titlePanel("Fastest Subway Line Analysis"),
      
        sidebarLayout(
          sidebarPanel(
            helpText("Please allow 30 to 45s for loading."),
            helpText("Subway portion studied: Bronx to Lower Manhattan."), br(),
            helpText("Line 1: Local, 36 stations,",br(),
                     "Line 4: Express, 16 stations."),br(),helpText(h3("1. What line is faster ?", br(), "2. What line is more reliable ?")),
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
                        value = c(0,24))
#             helpText("Subway portion studied: Bronx - downtown Manhattan."), br(),
#             helpText("Line 1: Local, 36 stations,",br(),
#                      "Line 4: Express, 16 stations."),br(),helpText("What line is faster ? What line is more reliable ?")
          ),
            
    
        mainPanel(
          
          tabsetPanel(
            tabPanel("Map",
                     img(src="Subways14.png",height=768,width=640)
                     #span(plotOutput("MTAMap"))
                     ),
            
            tabPanel("Hypothesis",
                     h3("Observations and hypothesis:"),
                     p("The data analysis was made on the portion of the subways lines 1 and 4 from the Bronx to downtown Manhattan"),
                     p("Given the unexpected behaviour of some trains on hold for 30+ min. at the train terminals, the analysis was effectued on the following portions:"), 
                     p("- South Direction (S): a) from 238th station to either Rector and South Ferry stations for line 1 and b) from the Mosholu Pkwy station to either Wall Street or Bowling Green stations for line 4 (due to a lack of datapoints: see Sources)"),
                     p("- North Direction (N): a) from Rector station to either 238th and 242th street stations for line 1 and b) from Whitehall Street to either Moshulu Pkwy or Woodlawn stations for line 4 (due to a lack of datapoints: see Sources)")
#                      br(),
#                      h3("Sources:"),
#                      p("Buses and Subways Maps were generated with RStudio using the MTA info Static Data Feeds:", a("MTA for Developer", href="http://web.mta.info/developers/developer-data-terms.html#data")),
#                      p("The historical Subway traffic time data were with Python package 'google.transit' built using the MTA API:", a("Real Time Data Feeds - Subway TimeTM",href="http://datamine.mta.info/"), ". The feeds provide the real time data for line 1-2-3, 4-5-6 and the S line between Times Square and Grand Central. The real time data was downloaded every 5 minutes for a period of 5 days starting July 7th, 2015 (subject to change). Reasonnaly, the data shall have been downloaded every 90s in order to catch most of the traffic."),
#                      p("Delays were collected with Python BeautifulSoup (webscraping) every 5 minutes (subject to change) on:", a("MTA info Service Status", href="http://www.mta.info/"), ".")
              ),
            
            tabPanel("Analysis",
                     plotOutput("Alys")),
            
            tabPanel("Conclusion",
                     h3("Timing of the subways:"),
                     p("Given the historical dataset constituted over a period of 5 days, the 1 train takes on average 70 minutes to go in Lower Manhattan when the 4 train takes approximately 62 minutes, which makes the line 4 faster than the line 1 during the period. However, it is surprising to observe a similar time for a local line versus an express lines."),
                     p("In comparison, Google maps is relatively accurate based on scheduled times and provides with the following figures for the same trip:"),
                     p("Line 1: 238th-SouthFerry 62min (Tues 8am)"),
                     p("Line 4: Mosholu Pkwy 59min (Tues 8am)"),
                     br(),
                     p("The trip is approximately 17 miles which would correspond to a speed of 17 mph"),
                     p("The newspaper Le Monde was reporting a speed of 12.4-16.1 mph fo the RATP paris subway in 2011."),
                     p("Also, on July 10-12 2015, the amnewyork newspaper was reporting a speed of NY Yellow Cab of 8.51mph for 2014, source: July 10-12 amnewyork 2015."),
                     br(),
                     h3("Delays:"),
                     p("Although the delays were downloaded from the Service Status mta info website, there are particularily difficult to interpret from a programming code point of view as they are redacted in a natural langage which changes over time."),
                     p("Moreover, the delays are published for a line or multiple line and are not associated to a train Id which makes the information difficult to quantify."),
                     p("It can however been observed that there are more delays on the green line (4-5-6) as anticipated but this result shall be confirmed by further historical data.")
                     )

#             tabPanel("Sources",
#                      h3("Sources:"),
#                      p("Buses and Subways Maps were generated with RStudio using the MTA info Static Data Feeds:", a("MTA for Developer", href="http://web.mta.info/developers/developer-data-terms.html#data")),
#                      p("The historical Subway traffic time data were with Python built using the MTA API:", a("Real Time Data Feeds - Subway TimeTM",href="http://datamine.mta.info/"), ". The Python package used to download the files is google.transit available on:", a("Google Developpers realtime transit", href="https://developers.google.com/transit/gtfs-realtime/code-samples", ".The feeds provide the real time data for line 1-2-3, 4-5-6 and the S line between Times Square and Grand Central. The real time data was downloaded every 5 minutes for a period of 5 days starting July 7th, 2015 (subject to change). Reasonnaly, the data shall have been downloaded every 90s in order to catch most of the traffic."),
#                      p("Delays were collected with Python BeautifulSoup (webscraping) every 5 minutes (subject to change) on:", a("MTA info Service Status", href="http://www.mta.info/"), ".")
#             )                 
          )
        )
        ) 
   )
    
  ),
    tabPanel("Subway Real Time",
      fluidPage(
        titlePanel("Real Time Map"),
        sidebarLayout(
          sidebarPanel(
             helpText("The feed is uploaded every 30s using a Python code (see Sources).", br(),br(),"Be Patient!"),
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
                          selected = 1),
             helpText("Note: MTA provides the expected time of Arrival and Depart for every future station to go but doesn't provide actual location.")
             ),
        mainPanel(
               plotOutput("realTimeMap")
             )
      ))
    
    ),
    tabPanel("Sources",
      fluidRow(
          column(4,
             img(src="statenisland.png",height=330,width=400,align="center")),
          column(6,
             h3("Sources:"),
             p("Buses and Subways Maps were generated with RStudio using the MTA info Static Data Feeds:", a("MTA for Developer", href="http://web.mta.info/developers/developer-data-terms.html#data")),
             p("The historical Subway traffic time data were with Python built using the MTA API:", a("Real Time Data Feeds - Subway TimeTM",href="http://datamine.mta.info/"), ". The Python package used to download the files is google.transit available on:", a("Google Developpers realtime transit", href="https://developers.google.com/transit/gtfs-realtime/code-samples"), ".The feeds provide the real time data for line 1-2-3, 4-5-6 and the S line between Times Square and Grand Central. The real time data was downloaded every 5 minutes for a period of 5 days starting July 7th, 2015 (subject to change). Reasonnaly, the data shall have been downloaded every 90s in order to catch most of the traffic."),
             p("Delays were collected with Python BeautifulSoup (webscraping) every 5 minutes (subject to change) on:", a("MTA info Service Status", href="http://www.mta.info/"), "."),
             p("The real time Map is using the same feed that the data used for the historical Analysis: the feed is uploaded through a Python code using the google.transit package into a txt file. Shiny detects the refresh of the file through the reactiveFileReader() fonction every second and then the txt file is read,filtered and mapped.")
             )))
 )
)
