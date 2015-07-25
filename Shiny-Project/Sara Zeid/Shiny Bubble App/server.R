region <- readRDS("Data/region.RDS")
income <- readRDS("Data/income.RDS")
gini <- readRDS("Data/gini.RDS")
grouping <- readRDS("Data/grouping.RDS")
reginc <- readRDS("Data/regionandincome.RDS")
library(ggplot2)
library(dplyr)
library(googleVis)
library(shiny)
library(DT)

shinyServer(
  function(input, output) {
    
    data <- reactive({
      if (input$Region == 'All'){
        df <- region %>%
          filter(year >= input$year[1], year<=input$year[2])  
      }
      else {
        df <- region %>%
          filter(year >= input$year[1], year<=input$year[2], Region==input$Region)
      }
    })
    
    output$gdppop <- renderPlot({
      if (input$yax == "Average GDP per Capita (Current $US)") {
        y_var = "gdpavg"
      } else {
        if (input$yax == "Average Population Growth (%)") {
          y_var = "popavg"
        } else {
          y_var= "sumpop"}
      }
      
      if (input$bub == "Average GDP per Capita (Current $US)") {
        size_var = "gdpavg"
      } else {
        if (input$bub == "Average Population Growth (%)") {
          size_var = "popavg"
        } else {
          size_var= "sumpop"}
      }
      
      output$table <- renderDataTable({
        dat <- data()
        res <- brushedPoints(dat, input$plot_brush)
        datatable(res, colnames = c("Region", "Year", 
                                    "Average GDP per Capita (Current $US)", 
                                    "Average Population Growth (%)", 
                                    "Total Population"))
      })

      ggplot(data(), aes_string(x = "year", y = y_var,
                         size = size_var, color="Region")) + 
        geom_point()+scale_size_continuous(range = c(4, 12))+
        scale_color_manual("Legend", values = c("East Asia & Pacific" = "blue3", 
                                                "Europe & Central Asia"= "palevioletred1", 
                                                "Latin America & Caribbean" = "orange", 
                                                "Middle East & North Africa" = "chartreuse4", 
                                                "North America"= "magenta3", 
                                                "South Asia" = "black", 
                                                "Sub-Saharan Africa" = "red"))+
        guides(colour = guide_legend(override.aes = list(size=5)))+
        ylab(input$yax)+xlab("Year")+labs(size=input$bub)
    })
    
    #TAB 2!
    
    data2 <- reactive({
      if (input$Income == 'All'){
        df <- income %>%
          filter(year >= input$year2[1], year<=input$year2[2])  
      }
      else {
        df <- income %>%
          filter(year >= input$year2[1], year<=input$year2[2], Income.group==input$Income)
      }
      
    })
    
    output$gdppopincome <- renderPlot({
      if (input$yax2 == "Average GDP per Capita (Current $US)") {
        y_var2 = "gdpavg"
      } else {
        if (input$yax2 == "Average Population Growth (%)") {
          y_var2 = "popavg"
        } else {
          y_var2 = "sumpop"}
      }
      
      if (input$bub2 == "Average GDP per Capita (Current $US)") {
        size_var2 = "gdpavg"
      } else {
        if (input$bub2 == "Average Population Growth (%)") {
          size_var2 = "popavg"
        } else {
          size_var2 = "sumpop"}
      }
      
      output$table2 <- renderDataTable({
        dat2 <- data2()
        res2 <- brushedPoints(dat2, input$plot_brush2)
        datatable(res2, colnames = c("Income Group", "Year", 
                                     "Average GDP per Capita (Current $US)", 
                                     "Average Population Growth (%)", 
                                     "Total Population"))
      })
      
      ggplot(data2(), aes_string(x = "year", y = y_var2,
                                 size = size_var2, color="Income.group")) + 
        geom_point()+scale_size_continuous(range = c(4, 12))+
        scale_color_manual("Legend", values = c("High income: nonOECD" = "blue3", 
                                                "High income: OECD"= "palevioletred1", 
                                                "Low income" = "red", 
                                                "Lower middle income" = "orange",
                                                "Upper middle income" = "chartreuse4"))+
        guides(colour = guide_legend(override.aes = list(size=5)))+
        ylab(input$yax2)+xlab("Year")+labs(size=input$bub2)
    })
    
    #TAB 3
    
    data3 <- reactive({
      if (input$country == 'All'){
        df <- gini %>%
          filter(year >= input$year3[1], year<=input$year3[2])  
      }
      else {
        df <- gini %>%
          filter(year >= input$year3[1], year<=input$year3[2], Country==input$country)
      }
    })
    
    output$incomeineq <- renderPlot({
      if (input$yax3 == "GDP per Capita (Current $US)") {
        y_var3 = "gdpcap"
      } else {
        if (input$yax3 == "Population Growth (%)") {
          y_var3 = "popgrowth"
        } else {
            if (input$yax3 == "Gini Coefficient") {
              y_var3 = "gini"
              } else {
                y_var3 = "population"
              }
        }
      }
      
      if (input$bub3 == "GDP per Capita (Current $US)") {
        size_var3 = "gdpcap"
      } else {
        if (input$bub3 == "Population Growth (%)") {
          size_var3 = "popgrowth"
        } else {
          if (input$bub3 == "Gini Coefficient") {
            size_var3 = "gini"
          } else {
            size_var3 = "population"
          }
        }
      }
      
      output$table3 <- renderDataTable({
        dat3 <- data3()
        res3 <- brushedPoints(dat3, input$plot_brush3)
        datatable(res3, colnames = c("Country", "Region",
                                     "Income Group", "Year",
                                     "GDP per Capita (Current $US)", 
                                     "Population Growth (%)", 
                                     "Total Population",
                                     "Gini Coefficient"))
      })
      
      ggplot(data3(), aes_string(x = "year", y = y_var3,
                                 size = size_var3, color="Country")) + 
        geom_point()+scale_size_continuous(range = c(4, 12))+
        guides(colour = guide_legend(override.aes = list(size=5)))+
        ylab(input$yax3)+xlab("Year")+labs(size=input$bub3)
    
    })
    
    #TAB 4
    
    output$motionchart <- renderGvis({
      names(reginc) <- c("Country", "Year", "GDP per Capita", "Population Growth", 
                         "Total Population", "Region", "Income Group")
      gvisMotionChart(reginc, idvar = "Country", timevar = "Year", xvar = "GDP per Capita",
                      yvar = "Population Growth", colorvar = "Region", sizevar = "Total Population",
                      options = list(width= 850, showChartButtons=TRUE))
    })
    
    output$motionchartgini <- renderGvis({
      names(gini) <- c("Country", "Region", "Income Group", "Year", "GDP per Capita", 
                      "Population Growth", "Total Population", "Gini Coefficient")
      gvisMotionChart(gini, idvar = "Country", timevar = "Year", xvar = "Gini Coefficient",
                      yvar = "Population Growth", colorvar = "Income Group", sizevar = "GDP per Capita",
                      options = list(width=850, showChartButtons=TRUE))
    })
    
    #TAB 5
    
    output$Grouping <- renderDataTable({grouping})
    
  })

