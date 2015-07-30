library(shiny)
library(maps)
library(leaflet)
library(rgdal)
library(rgeos)
library(sp)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(jsonlite)
library(Hmisc)

load("county_map.RData")

palette1 <- c("#FFEDA0", "#FED976", "#FEB24C", "#FD8D3C",
            "#FC4E2A", "#E31A1C", "#BD0026", "#800026", "#34000f", "#000000")
giniBreaks <- c(0, 0.25, 0.30, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 1)
povertyBreaks <- c(0, 0.05, 0.1, 0.15, 0.20, 0.25, 0.30, 0.40, 0.50, 0.75,1)

colorpal1 <- reactive({
  #colorNumeric(palette = 'YlOrBr', domain=county_map$gini2009.y)
  colorNumeric(palette = palette1, domain=county_map$gini2009.y)
})

colorpal2 <- reactive({
  colorNumeric(palette = palette1, domain=county_map$poverty1990.y)
})


colorsgini_2009 <- structure(
  palette1[cut(county_map$gini2009.y, giniBreaks)],
  names = as.character(county_map$polyname))

colorsgini_2013 <- structure(
  palette1[cut(county_map$gini2013.y, giniBreaks)],
  names = as.character(county_map$polyname))

colorspoverty_1990 <- structure(
  palette1[cut(county_map$poverty1990, povertyBreaks)],
  names = as.character(county_map$polyname))

colorspoverty_2000 <- structure(
  palette1[cut(county_map$poverty2000, povertyBreaks)],
  names = as.character(county_map$polyname))

colorspoverty_2010 <- structure(
  palette1[cut(county_map$poverty2010, povertyBreaks)],
  names = as.character(county_map$polyname))

shinyServer(function(input, output, session){
  values <- reactiveValues(highlight = c())
  
  #map <- createLeafletMap(session, "map")
  # map %>% addProviderTiles("CartoDB.Positron")
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(lng=-100, lat=40, zoom=4)
  })
  
  observe({
    counties <- map("county", plot = FALSE, fill = TRUE)
    if (input$baseyear2 == '1990'){
      colorinput <- colorspoverty_1990
      colorpal <- colorNumeric(palette = palette1, domain=county_map$poverty1990.y)
    }
    if(input$baseyear2 == '2000'){
      colorinput <- colorspoverty_2000
      colorpal <- colorNumeric(palette = palette1, domain=county_map$poverty2000.y)
    }
    if(input$baseyear2 == '2010'){
      colorinput <- colorspoverty_2010
      colorpal <- colorNumeric(palette = palette1, domain=county_map$poverty2010.y)
    }
    if(input$baseyear2 == '2009'){
      colorinput <- colorsgini_2009
      colorpal <- colorNumeric(palette = palette1, domain=county_map$gini2009.y)
    }
    if(input$baseyear2 == '2013'){
      colorinput <- colorsgini_2013
      colorpal <- colorNumeric(palette = palette1, domain=county_map$gini2009.y)
    }
    
    leafletProxy('map') %>%
      clearControls() %>%
      addPolygons(data = counties, layerId = ~names,
                  fillColor = I(lapply(counties$names, function(x) {
                                colorinput[[x]]
                                })),
                  fillOpacity = 0.7,
                  stroke = TRUE, color = 'white', weight = 0.5, opacity =1, popup = paste0('<h4><strong>', counties$names, '</strong></h4>')) %>%
      addLegend(position = 'bottomleft', pal = colorpal, values = county_map$gini2009.y)
    #addPolygons()
  })

  observe({
    values$highlight <- input$map_shape_mouseover$id
  })
  
  
  output$countyInfo <- renderUI({
    if (is.null(values$highlight)) {
      return(tags$div("Hover over a county"))
    } else {
      CountyName <- county_map$polyname[values$highlight == county_map$polyname] 
      return(tags$div(
        tags$h4(CountyName),
        tags$h5("1990 Poverty Level:", round(county_map[county_map$polyname == CountyName,]$poverty1990, digits=3)*100, "%"),
        tags$h5("2000 Poverty Level:", round(county_map[county_map$polyname == CountyName,]$poverty2000, digits=3)*100, "%"),
        tags$h5("2010 Poverty Level:", round(county_map[county_map$polyname == CountyName,]$poverty2010, digits=3)*100, "%"),
        tags$h5("2009 Gini Index:", round(county_map[county_map$polyname == CountyName,]$gini2009.y, digits=2)),
        tags$h5("2013 Gini Index:", round(county_map[county_map$polyname == CountyName,]$gini2013.y, digits =2))
      ))
    }
  })

})  
