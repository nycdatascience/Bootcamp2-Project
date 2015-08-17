library(d3heatmap)
# 
# loc <- c("The New York Times Bldg." = "nyt")

category <- c("Everything",
              "Art",
              "Classical & Opera" = "Classical",
              "Comedy",
              "Dance",
              "Jazz",
              "Movies",
              "Rock & Pop" = "Pop",
              "Theater",
              "Spare Times" = "spareTimes",
              "For Children" = "forChildren")

borough <- c("Everywhere",
             "Manhattan",
             "Brooklyn",
             "Queens")

axis <- c("Day" = "day",
          "Category" = "category",
          "Neighborhood" = "neighborhood")

shinyUI(navbarPage(theme="readable.css",                   
                   a(href="http://www.nytimes.com/",
                     target="_blank",
                     img(src="NYT_logo.png",
                         alt="The New York Times",
                         width = 160)),
                   tabPanel("Arts & Entertainment Guide",
                            fluidRow(
                                column(2,
                                       radioButtons("category", "CATEGORY",
                                                    category, selected="Everything"),
                                       selectInput("borough", "LOCATION",
                                                    borough, selected="Everywhere"),
                                       numericInput("limit", "LIMIT", 
                                                    value=20, min=5, max=1000),
                                       checkboxInput("offline", label = "Use Local Data", 
                                                     value = FALSE),
                                       actionButton("writeToDB", "Save Events")
                                       ),
                                column(10, 
                                       htmlOutput("gvis"),
                                       p("________________"),
                                       fluidRow(
                                           column(4, textInput("address", "Nearby")),
                                           column(2, numericInput("radius", "Within (mi)", 
                                                                  value=2, min=.5, max=10, step=.5)
                                           ),
                                           column(4, textInput("keywords", "Search Keywords")),
                                           column(2, br(), actionButton("search", "Find Events"))
                                           )
                                       )
                                )
                            ),

                   tabPanel("Event Analysis",
                            fluidRow(
                                column(2,
                                       actionButton("readFromDB", "Update Events"),
                                       h5("FILTERS"),
                                       checkboxInput("checkTotal", label = "Total", value = TRUE),
                                       checkboxInput("checkPick", label = "Times Pick", value = FALSE),
                                       checkboxInput("checkKid", label = "Kid Friendly", value = FALSE),
                                       checkboxInput("checkFree", label = "Free", value = FALSE),
                                       br(),
                                       h5("HEATMAP"),

                                       selectInput("xaxis", "X:",
                                                   axis, selected="day"),
                                       selectInput("yaxis", "Y:",
                                                   axis, selected="category"),
                                       actionButton("heatmapAxis", "Generate")
                                       
                                ),
                                
                                column(10,
                                       tabsetPanel(
                                                   tabPanel("By Day", htmlOutput("byDay")), 
                                                   tabPanel("By Category", htmlOutput("byCategory")),
                                                   tabPanel("Heatmaps", d3heatmapOutput("heatmap")),
                                                   tabPanel("Event Listings", htmlOutput("eventTable"))
                                                   )
                                       )
                            
                            )
                   ),
                   tabPanel("Help")
))
