library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(ggplot2)
load("sumdata.RData")
load("sumdatasimpl.RData")
# Helper functions that allow string arguments for  dplyr's data modification functions like arrange, select etc. 
# Author: Sebastian Kranz

# Examples are below

#' Modified version of dplyr's filter that uses string arguments
#' @export
s_filter = function(.data, ...) {
  eval.string.dplyr(.data,"filter", ...)
}

#' Modified version of dplyr's select that uses string arguments
#' @export
s_select = function(.data, ...) {
  eval.string.dplyr(.data,"select", ...)
}

#' Modified version of dplyr's arrange that uses string arguments
#' @export
s_arrange = function(.data, ...) {
  eval.string.dplyr(.data,"arrange", ...)
}

#' Modified version of dplyr's arrange that uses string arguments
#' @export
s_mutate = function(.data, ...) {
  eval.string.dplyr(.data,"mutate", ...)
}

#' Modified version of dplyr's summarise that uses string arguments
#' @export
s_summarise = function(.data, ...) {
  eval.string.dplyr(.data,"summarise", ...)
}

#' Modified version of dplyr's group_by that uses string arguments
#' @export
s_group_by = function(.data, ...) {
  eval.string.dplyr(.data,"group_by", ...)
}

#' Internal function used by s_filter, s_select etc.
eval.string.dplyr = function(.data, .fun.name, ...) {
  args = list(...)
  args = unlist(args)
  code = paste0(.fun.name,"(.data,", paste0(args, collapse=","), ")")
  df = eval(parse(text=code,srcfile=NULL))
  df  
}

library(dplyr)





shinyServer(function(input, output, session) {
  
  ## Interactive Map ###########################################
  
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -70, lat = 37.45, zoom = 5)
  })
  
  
  output$lineHisto <- renderPlot({
    
    colorBy <- input$color
    sizeBy <- input$size
    
    seasonemi = sumdata %>%
    s_group_by("Period")  %>%  
    s_summarise(paste("TotalColor = sum(",input$color,",na.rm=T)",sep=''))
    PlotLine(seasonemi,"Period","TotalColor")
  })
  
  library(scales)
  PlotLine <- function(DS, x, y) {    
    ggplot(DS, aes_string(x = x, y = y)) + 
      geom_line() +
      ylab(input$color) +
      xlab('') +
      labs(title="History") +
      theme(legend.position="bottom") +
      stat_smooth(method="lm") +
      scale_y_continuous(labels = comma)

  }
  
  output$scatterPower <- renderPlot({
    
    colorBy <- input$color
    sizeBy <- input$size
    
    #print(xyplot(as.formula(paste(colorBy ,"~", sizeBy)), data = sumdata, ))  
    
    qplot(x=sumdata[[sizeBy]],y=sumdata[[colorBy]]) +
      ylab(colorBy) +
      xlab(sizeBy)
    
  })
  
  # This observer is responsible for maintaining the circles and legend,
  # according to the variables the user has chosen to map to color and size.
  observe({

    
    colorBy <- input$color
    sizeBy <- input$size

    colorData <- sumdatasimpl[[colorBy]]
    
    if (colorBy == "FuelType.Primary"){
      pal <- colorFactor("Spectral", colorData)
    }
    else{
      pal <- colorBin("Spectral", colorData)
      
    }
    
        
    radius <- sumdatasimpl[[sizeBy]] / max(sumdatasimpl[[sizeBy]],na.rm=TRUE) * 100000
    
    leafletProxy("map", data = sumdatasimpl) %>%
      clearShapes() %>%
      addCircles(~Facility.Longitude, ~Facility.Latitude, radius=radius, layerId=~Facility.ORIS.ID,
                 stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
      addLegend("bottomleft",pal =pal, values=colorData, title=colorBy,
                layerId="colorLegend")
    
  })
  
  # Show a popup at the given location
  showPlantPopup <- function(plantname, lat, lng) {
    selectedPlant <- sumdata[sumdata$Facility.ORIS.ID == plantname,]
    content <- as.character(tagList(
      tags$h4(unique(selectedPlant$Facility.Name)),tags$br(),
      tags$strong(sprintf("Type: %s",unique(selectedPlant$FuelType.Primary))),tags$br(),
      sprintf("Period Jan2009-Mar2015"), tags$br(),
      sprintf("CO2 Emissions: %s s Tons", format(sum(selectedPlant$CO2.Short.Tons,na.rm=T),scientific=F,big.mark=",")), tags$br(),
      sprintf("SO2 Emissions: %s Tons", format(sum(selectedPlant$SO2.Tons,na.rm=T),scientific=F,big.mark=",")), tags$br(),
      sprintf("NOx Emissions: %s Tons", format(sum(selectedPlant$NOx.Tons,na.rm=T),scientific=F,big.mark=","))
    ))                             
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = selectedPlant$Facility.Name)
    #Update the historical line graph
    output$lineHisto <- renderPlot({
      
      colorBy <- input$color
      sizeBy <- input$size
      
      seasonemi = sumdata[sumdata$Facility.ORIS.ID == plantname,] %>%
        s_group_by("Period")  %>%  
        s_summarise(paste("TotalColor = sum(",input$color,",na.rm=T)",sep=''))
      PlotLine(seasonemi,"Period","TotalColor")
    })
  }
  
  # When map is clicked, show a popup with city info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      
      return()
    
    isolate({
      showPlantPopup(event$id, event$lat, event$lng)
    })
    
  })
  # When reset is clicked well reset
  observeEvent(input$resetButton,   
               
    output$lineHisto <- renderPlot({
    
    colorBy <- input$color
    sizeBy <- input$size
    
    seasonemi = sumdata %>%
      s_group_by("Period")  %>%  
      s_summarise(paste("TotalColor = sum(",input$color,",na.rm=T)",sep=''))
    PlotLine(seasonemi,"Period","TotalColor")
  }))
  
})