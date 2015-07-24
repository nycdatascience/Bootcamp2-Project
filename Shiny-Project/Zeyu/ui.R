library(shiny)
library(leaflet)

features = c(
  'Breakfast' = 'Breakfast',
  'Internet' = 'Internet',
  'Gym' = 'Gym',
  'TV' = 'TV'
  )

vars = c(
  'All Types' = 'All Types',
  'Real Bed' = 'Real Bed',   
  'Pull-out Sofa' = 'Pull-out Sofa',
  'Airbed' = 'Airbed',
  'Futon' = 'Futon',
  'Couch' = 'Couch'
)

shinyUI(navbarPage('Airbnb Pricing Analysis', id='nav', theme = 'bootstrap.css',
            
    tabPanel('Interactive Map',
      div(class='outer', 
          
          tags$head(
            # Include custon CSS
            includeCSS('style.css'),
            tags$script(src = "message-handler.js")
          ),
          
          leafletOutput("map", width="100%", height="100%"),
          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                        draggable = FALSE, top = 90, left = "auto", right = 10, bottom = "auto",
                        width = 320, height = "auto",
                        
                        h2("Price Explorer"),
                        
                        sliderInput('price', 'Price Range', min(result$Price), max(result$Price), 
                                    value = range(result$Price), step = 1
                        ),
                        
                        selectInput("bedtype", "Bed Type", vars, selected = 'All Types'),
                        
                        h5('Features'),
                        
                        #checkboxGroupInput('feature', 'Feature', choices=features),
                        
                        checkboxInput("breakfast", "Breakfast", FALSE),
                        
                        checkboxInput("internet", "Internet", FALSE),
                        
                        checkboxInput("shampoo", "Shampoo", FALSE),
                        
                        checkboxInput("detector", "Smoke.Detector", FALSE),
                        
                        checkboxInput("tv", "TV", FALSE)

                        #checkboxInput("legend", "Show legend", TRUE)
                        
                        #verbatimTextOutput('debug')
                          
          )
      )
    ),
    
    tabPanel('Data Explorer',
      fluidRow(
        column(2,
          radioButtons('feature', 'Choose a feature',
            c('Internet' = 'i', 'TV' = 't', 'Shampoo' = 's', 
              'Breakfast' = 'b', 'Somke Detector' = 'd', 'Number of beds' = 'n')),
          radioButtons('response', 'Choose a response',
            c('Price' = 'p')),
          radioButtons('type', 'Choose a plot type',
            c('Box plot' = 'b', 'Histogram' = 'h'))
        ),
        column(10,
          plotOutput('plot')
        )
      )
    ),
    
    tabPanel('Name Your Own Price',
      fluidRow(
        column(12,
          checkboxInput('model1', 'First Model:'),
          p('Price ~ Number of beds + TV + Shampoo + Breakfast + Interent + Smoke.Detector')

        ),
        column(12,
          verbatimTextOutput('summary'),
          verbatimTextOutput('summary1'),
          actionButton('backward', 'Backward Stepwise')
        )
      )
                 
    )
    
    
))

