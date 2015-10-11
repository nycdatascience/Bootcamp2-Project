library(shiny)
library(leaflet)
library(dplyr)
library(DT)
library(ggplot2)
library(googleVis)

shinyServer(function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    
    df <- result[result$Price >= input$price[1] & result$Price <= input$price[2],]
    if (input$breakfast){
      df <- df[df$Breakfast == input$breakfast, ]
    }
    if (input$internet){
      df <- df[df$Internet == input$internet, ]
    }
    if (input$shampoo){
      df <- df[df$Shampoo == input$shampoo, ]
    }
    if (input$tv){
      df <- df[df$TV == input$tv, ]
    }
    if (input$detector){
      df <- df[df$Smoke.Detector == input$detector, ]
    }
    if (input$bedtype != 'All Types'){
      df <- df[df$Bed.type == input$bedtype, ]
    }
#     if(is.null(input$feature))
#       return (df)
#     df <- df[df$temp() ==1, ]
    return (df)
  })
    

  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric(palette='YlGnBu', domain=result$Price)
  })

  # Create the base map  
  output$map <- renderLeaflet({
    leaflet(result) %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(lng = -73.95, lat = 40.78, zoom = 13) %>%
      addLegend(position = 'bottomright',
        pal = colorpal(), values = ~Price, title = 'Price',
        opacity = 1, labFormat = labelFormat(prefix = "$"))
  })
  
  
  # Change the map according to the different input
  observe({
    pal <- colorpal()
    price <- filteredData()$Price
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(~Long, ~Lat, radius = ~Beds * 40, weight = 1, color = "#777777",
                 fillColor = ~pal(Price), fillOpacity = 0.7, 
                 popup = paste(paste0('<h5><strong>', 'Price: ', '</strong>', '$', filteredData()$Price, '</h5>'), 
                               paste0('<h5><strong>', 'URL: ', '</strong>', paste0('<a href=',filteredData()$URL, ' target="_blank">', filteredData()$URL, '</a></h5>')), 
                               sep='<br/>')
      )
  })
  
#   # Use a separate observer to recreate the legend as needed.
#   observe({
#     proxy <- leafletProxy("map", data = result)
#     
#     # Remove any existing legend, and only if the legend is
#     # enabled, create a new one.
#     proxy %>% clearControls()
#     if (input$legend) {
#       pal <- colorpal()
#       proxy %>% addLegend(position = 'bottomright',
#                           pal = pal, values = ~Price, title = 'Price',
#                           opacity = 1, labFormat = labelFormat(prefix = "$")
#       )
#     }
#   })
#   
  # Data Explorer Part
  # Filter the dataset to be displayed on the plot
  plotdata <- reactive({
    df <- switch(input$feature,
                   i = data.frame(feature=result$Internet, response=result$Price),
                   t = data.frame(feature=result$TV, response=result$Price),
                   n = data.frame(feature=result$Beds, response=result$Price),
                   s = data.frame(feature=result$Shampoo, response=result$Price),
                   d = data.frame(feature=result$Smoke.Detector, response=result$Price),
                   b = data.frame(feature=result$Breakfast, response=result$Price))
                   #l = data.frame(feature=result[result$Location != 'Not Found', ]$Location,
                   #               response=result[result$Location != 'Not Found', ]$Price))
    return (df)
    })
  
  
  # Plot the figure according to what users have chosen
  output$plot <- renderPlot({
    if (input$type == 'b'){
      ggplot(plotdata(), aes(factor(feature), response)) + geom_boxplot() + theme_bw() + 
        theme (panel.grid.major = element_blank(), panel.grid.minor = element_blank(), text = element_text(size=20))
    } else if(input$type == 'h'){
      if(input$feature != 'n'){
       ggplot() +
         geom_histogram(aes(x=response, fill='r', colour='r'), binwidth=30, alpha=0.4, data=plotdata()[plotdata()$feature==1, ]) +
         geom_histogram(aes(x=response, fill='b', colour='b'), binwidth=30, alpha=0.4, data=plotdata()[plotdata()$feature==0, ]) +
         scale_colour_manual(name="feature", values=c("r"="red", "b"="blue"), labels=c("b"="0", "r"="1")) +
         scale_fill_manual(name="feature", values=c("r"="red", "b"="blue"), labels=c("b"="0", "r"="1")) +
         theme(text = element_text(size=20))
      } else{
        ggplot() +
          geom_histogram(aes(x=response, fill='r', colour='r'), binwidth=30, alpha=0.4, data=plotdata()[plotdata()$feature==1, ]) +
          geom_histogram(aes(x=response, fill='b', colour='b'), binwidth=30, alpha=0.4, data=plotdata()[plotdata()$feature==2, ]) +
          geom_histogram(aes(x=response, fill='y', colour='y'), binwidth=30, alpha=0.4, data=plotdata()[plotdata()$feature==3, ]) +
          geom_histogram(aes(x=response, fill='g', colour='g'), binwidth=30, alpha=0.4, data=plotdata()[plotdata()$feature==4, ]) +
          scale_colour_manual(name="Number of beds", values=c("r"="red", "b"="blue", "y"="yellow", "g"="green"), labels=c("r"="1", "b"="2", "y"="3", "g"="4"))+
          scale_fill_manual(name="Number of beds", values=c("r"="red", "b"="blue", "y"="yellow", "g"="green"), labels=c("r"="1", "b"="2", "y"="3", "g"="4")) +
          theme(text = element_text(size=20))
      }
    }
    
  })
  
  
  # Name your own price
  # Try to build a linear model
  action <- eventReactive(input$backward,{
    
    df1 <- result[, c('Breakfast', 'Beds', 'Internet', 'TV', 'Shampoo', 'Smoke.Detector', 'Price')]
    full <- lm(Price ~ ., data = df1)
    empty <- lm(Price ~ 1, data = df1)
    start <- full
    
    return(step(start, 
                scope = list(upper = full,
                             lower = empty),
                direction = "backward"))
  })

#   output$summary <- renderPrint({
#     df1 <- result[, c('Breakfast', 'Beds', 'Internet', 'TV', 'Shampoo', 'Smoke.Detector', 'Price')]
#     full <- lm(Price ~ ., data = df1)
#     
#     if (input$model1){
#       return (summary(full))
#     } 
#   })
#   
#   output$summary1 <- renderPrint({    
#     action()
#   })


  output$apartmenttable <- DT::renderDataTable({
    df <- apartment
    action <- DT::dataTableAjax(session, df)
    
    DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
  })

})
