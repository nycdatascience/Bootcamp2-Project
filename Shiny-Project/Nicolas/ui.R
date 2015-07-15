library(shiny)
library(leaflet)

# Choices for drop-downs
vars <- c(
  "Gross Generation" = "GrossLoad.MWh",
  "Net Generation" = "NetGen.MWh",
  "CO2 Emissions" = "CO2.Short.Tons",
  "SO2 Emissions" = "SO2.Tons",
  "NOX Emissions" = "NOx.Tons",
  "Production Efficiency CO2" = "Efficiency.CO2sTons.MWh",  
  "Plant Type" = "FuelType.Primary"
)


shinyUI(navbarPage("SuperPower", id="nav",
                   
                   tabPanel("Interactive map",
                            div(class="outer",
                                
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css")
                                ),
                                
                                leafletOutput("map", width="100%", height="100%"),
                                
                                # Shiny versions prior to 0.11 should use class="modal" instead.
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 330, height = "auto",
                                              
                                              h2("SuperPower Explorer"),
                                              
                                              selectInput("color", "Color", vars, selected = "FuelType.Primary"),
                                              selectInput("size", "Size", vars, selected = "NetGen.MWh"),
                                              actionButton("resetButton", "Reset to Total"),
                                              plotOutput("lineHisto", height = 250),
                                              plotOutput("scatterPower", height = 250)
                                ),
                                
                                tags$div(id="cite",
                                         'Data source ', tags$em('EIA and EPA'), ' by Nicolas Girod.'
                                )
                            )
                   ),
                   
                   
                   conditionalPanel("false", icon("crosshair"))
))