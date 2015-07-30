library(shiny)
library(leaflet)
library(maps)

# Choices for drop-downs

years2 <- list("1990: % of Population in Poverty" = 1990, "2000: % of Population in Poverty" = 2000, "2010: % of Population in Poverty" = 2010, "2009 Gini Index" = 2009, "2013 Gini Index" = 2013)

palette <- c("#FFEDA0", "#FED976", "#FEB24C", "#FD8D3C",
             "#FC4E2A", "#E31A1C", "#BD0026", "#800026", "#34000f", "#000000")
giniBreaks <- c(0, 0.25, 0.30, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 1)
giniRanges <- data.frame(
  from = head(giniBreaks, length(giniBreaks)-1),
  to = tail(giniBreaks, length(giniBreaks)-1)
)

shinyUI(navbarPage("Poverty and Economic Inequality", id = "nav",
                   
                   tabPanel(
                     "Interactive Map",
                     div(
                       class = "outer",
                       
                       tags$head(includeCSS("styles.css")),
                       
                       
#                        leafletMap(
#                          "map", "100%", 500,
#                          options = list(
#                            center = c(40,-100),
#                            zoom = 4,
#                            maxBounds = list(list(10,-180), list(80, 180))
#                          )
#                        ),
                      
                      leafletOutput('map', width = '100%', height = '100%'),
                       
                       absolutePanel(
                         id = "controls", class = "panel panel-default", fixed = TRUE,
                         draggable = FALSE, top = 100, left = "auto", right =
                           10, bottom = "auto",
                         width = 330, height = "auto",
                         
                         h4("Poverty and Gini Index by Year"),
                         uiOutput("countyInfo"),

                         
                         h4("Mapping Poverty and Economic Inequality"),
                         
                         radioButtons(
                           "baseyear2", "Choose a Year and Index", years2, selected = 1990
                         ),

          tags$div(id="cite",
         'Data Sources: ', tags$em('Census1990, Census2000, Census2010, American Community Survey 2005-2009, and American Community Survey 2009-2013')
          )
                       )
                       
                     )
                   ),

tabPanel("Definitions",
           div(
             class = "outer",
             
             tags$head(includeCSS("styles.css")),
             
             mainPanel(
               h3("How to Measure Poverty"),
               p("U.S.Census Bureau uses a set of money income thresholds that 
                 vary by family size and composition to determine who is in 
                 poverty. If a family's total income is less than the family's 
                 threshold, then that family and every individual in it is 
                 considered in poverty. The official poverty thresholds do not 
                 vary geographically, but they are updated for inflation using 
                 Consumer Price Index (CPI-U). The official poverty definition 
                 uses money income before taxes and does not include capital 
                 gains or noncash benefits (such as public housing, Medicaid, 
                 and food stamps)."),
               h3("U.S. Average Poverty Rates"),
               p("1990: 13.1%"),
               p("2000: 12.4%"),
               p("2010: 14.9%"),
               h3("What is Gini Index"),
               p("The Gini Index is a statistical measure of income equality 
                 ranging from 0 to 1. A measure of 1 indicates perfect 
                 inequality; i.e., one person has all the income and rest have none. 
                 A measure of 0 indicates perfect equality; i.e., all people have 
                 equal shares of income.")
               
             )
         )

))
)

