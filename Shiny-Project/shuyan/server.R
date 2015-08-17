library(shiny)
library(googleVis)
library(d3heatmap)
source("helpers.R")

gmap_url <- "http://maps.google.com/maps/api/geocode/json?address="

shinyServer(function(input, output) {
    # NYT api url
    url <- reactiveValues(data = NULL)
    # By Advanced search
    observeEvent(c(input$search, input$borough, input$category, input$limit), {
        
        ll <- "ll="
        query <- ""
        filters <- ""
        radius <- paste0("radius=", input$radius * 1600)
        limit <- paste0("limit=", input$limit)
        if(input$address == "") {
            ll <- paste0(ll, nyclatlng)
        } else {
            addr <- fromJSON(paste0(gmap_url, gsub(" ", "+", input$address), 
                                    "&sensor=false"))$results
            latlng <- addr$geometry$location
            latlng <- latlng[latlng$lat > latRange[1] &
                                 latlng$lat < latRange[2] &
                                 latlng$lng > lngRange[1] &
                                 latlng$lng < lngRange[2], ]
            print(ll)
            ll <- paste0(ll, (gsub(" ", "",paste(latlng[1,1], ",", latlng[1,2]))))
        }
        if(input$borough != "Everywhere") {
            ll <- ""
            radius <- ""
            filters <- paste0("borough:", input$borough)
        }
        if(input$category != "Everything") {
            filters <- paste0(filters, ",category:", input$category)
        }
        if(filters != "") {
            filters  <- paste0("filters=", filters)
        }
        
        if(input$keywords != "") {
            query <- paste0("query=", gsub(" +", "+", input$keywords))
        }
        
        url$data <- paste(base_url, ll, query, filters, radius, limit, api_key, sep = "&")
        print(url$data)
    })
    
    retrieved <- reactive({
        if(input$offline) {
            filted <- events
            if(input$category != "Everything") {
                filted <- filted[events$category == input$category,]
            }
            if(input$borough != "Everywhere") {
                filted <- filted[events$borough == input$borough,]
            }
            return(filted)
        } else {
            retrieveEvent(url$data)
        }
    })
    
    output$gvis <- renderGvis({ 
        # plot events on google map
        eventToPlot <- formatEvent(retrieved())
        print(paste0("Plotting events: ", nrow(eventToPlot)))
        gvisMap(eventToPlot, locationvar = "LatLong" , tipvar = "info", 
                options=list(width=200,
                             height=500,
                             showTip=TRUE, 
                             showLine=TRUE, 
                             enableScrollWheel=TRUE,
                             mapType="styledMap",
                             showLine=TRUE,
                             useMapTypeControl=TRUE,
                             icons=paste0("{",
                                          "'default': {'normal': 'http://icons.iconarchive.com/",
                                          "icons/icons-land/vista-map-markers/48/",
                                          "Map-Marker-Ball-Pink-icon.png',\n",
                                          "'selected': 'http://icons.iconarchive.com/",
                                          "icons/icons-land/vista-map-markers/48/",
                                          "Map-Marker-Ball-Right-Pink-icon.png'",
                                          "}}"),
                             maps=paste0("{",
                                         "'styledMap': {",
                                         "'name': 'Styled Map',\n",
                                         "'styles': [",
                                         "{'featureType': 'landscape',",
                                         "'stylers': [{'hue': '#259b24'}, {'saturation': 10}, {'lightness': -22}]",
                                         "}",
                                         "]}}")
                             ))
    })
    
    writeToDB <- eventReactive(input$writeToDB, {
        if(!input$offline) {
            toDB(dbPath, tbName, retrieved())
        }        
    })
    observe(writeToDB())
    
    readFromDB <- eventReactive(input$readFromDB, {
        events <<- fromDB(dbPath, tbName)
        days <<- dayFreq(events)
        event.day <<- eventByDay(events, days)
    })
    
    headMapAxis <- eventReactive(input$heatmapAxis, {
        c(input$yaxis,input$xaxis)
    })
    
    observe(readFromDB())
    
    output$byDay <- renderGvis({
        
        eventByDay <- data.frame("Day"          = c("SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"),
                              "Total"        = sapply(days, sum),
                              "Times Pick"   = sapply(days, function(x) sum(events$times_pick==1 & x)),
                              "Kid Friendly" = sapply(days, function(x) sum(events$kid_friendly==1 & x)),
                              "Free"         = sapply(days, function(x) sum(events$free==1 & x))
                              )
        checkTotal <- input$checkTotal
        if(!(input$checkPick || input$checkKid || input$checkFree)) {
            checkTotal <- TRUE
        }
        print(nrow(eventByDay))
        gvisAreaChart(eventByDay[, c(TRUE, checkTotal, 
                                 input$checkPick,
                                 input$checkKid,
                                 input$checkFree 
                                 )], 
                      options=list(width="900px", height="600px"))
    })
    
    output$byCategory <- renderGvis({
        df2 <- events[,c("category", "times_pick", "kid_friendly", "free")]
        df2.category <- df2 %>% group_by(category) %>% count(category)
        df2.pick <- df2 %>% filter(times_pick==1) %>% group_by(category) %>% count(category)
        df2.kid <- df2 %>% filter(kid_friendly==1) %>% group_by(category) %>% count(category)
        df2.free <- df2 %>% filter(free==1) %>% group_by(category) %>% count(category)
        
        pie.category <- gvisPieChart(df2.category, 
                                     options=list(width=800, height=800, 
                                                  title="Total"))
        pie.pick <- gvisPieChart(df2.pick, 
                                 options=list(width=200, height=200, 
                                              title="Times Pick", legend='none'))
        pie.kid <- gvisPieChart(df2.kid, 
                                options=list(width=200, height=200, 
                                             title="Kid Friendly", legend='none'))
        pie.free <- gvisPieChart(df2.free, 
                                 options=list(width=200, height=200, 
                                              title="Free", legend='none'))
        gvisMerge(pie.category,
                  gvisMerge(pie.pick, 
                            gvisMerge(pie.free, pie.kid, horizontal=FALSE), horizontal=FALSE),
                  horizontal=TRUE)
#         gvisMerge(pie.category, pie.pick, horizontal=TRUE)

    })
    
    output$heatmap <- renderD3heatmap({
        axis <- headMapAxis()
        if(axis[1] ==  axis[2]) {
            return()
        }
        print(axis)
        d3heatmap(table(event.day[,axis]), colors="Greens", scale = "column", Colv = FALSE)
    })
    
    output$eventTable <- renderGvis({
        df3 <- events
        df3$name <- apply(df3, 1, 
                             function(x) paste0("<a href=\"", 
                                                x["event_detail_url"], "\" target=\"_blank\">", 
                                                x["event_name"], "</a>"))
        if(input$checkPick) {
            df3 <- df3[df3$times_pick==1,]
        }
        if(input$checkKid) {
            df3 <- df3[df3$kid_friendly==1,]
        }
        if(input$checkFree) {
            df3 <- df3[df3$free==1,]
        }
        gvisTable(data.frame("Name"=df3$name, "Venue"=df3$venue_name, 
                             "Category"=df3$category, "Neighborhood"=df3$neighborhood),
                  options=list(page='enable', pageSize=20))
    })
        
 
})
