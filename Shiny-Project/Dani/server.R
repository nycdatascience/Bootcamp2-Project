shinyServer(function(input, output, session) {

    # show flight counts plot in main panel
    output$countPlot = renderPlot({
        
        # get number of flights per carrier
        subset_count = filter(flights, 
                              ORIGIN_CITY_NAME == input$origin_select & 
                              DEST_CITY_NAME == input$dest_select & 
                              FL_DATE >= input$dateRange[1] & 
                              FL_DATE <= input$dateRange[2] &
                              CRS_DEP_TIME >= input$early_time &
                              CRS_DEP_TIME <= input$late_time)
        carrier_count = group_by(subset_count, CARRIER_NAME) %>% summarise(count = n())
        countTitle = paste("Number of flights from", input$origin_select, "to", input$dest_select)
        
        # make plot
        par(mfrow = c(2, 1))
        p = ggplot(carrier_count, aes(y = count))
        carrier_count$ordered = reorder(carrier_count$CARRIER_NAME, -carrier_count$count)
        p + geom_bar(aes(x = ordered, fill = ordered), stat = "identity", data = carrier_count) +
            scale_fill_brewer(palette = "Set2", name = "Carriers") +
            xlab('') +
            ylab('') +
            ggtitle(countTitle) +
            theme_bw() +
            theme(axis.text.x = element_text(angle = 45, hjust = 1),
                  text = element_text(size = 16)) +
            theme(legend.position="none")
        
    })
    
    # show flight delays plot in main panel
    output$delayPlot = renderPlot({
        
        # get delay by carrier
        subset_delay = filter(flights, 
                              ORIGIN_CITY_NAME == input$origin_select & 
                              DEST_CITY_NAME == input$dest_select &
                              FL_DATE >= input$dateRange[1] & 
                              FL_DATE <= input$dateRange[2] &
                              CRS_DEP_TIME >= input$early_time &
                              CRS_DEP_TIME <= input$late_time)
        
        medians = group_by(subset_delay, CARRIER_NAME) %>% 
                           summarise(median(ARR_DELAY, na.rm = T))
        medians_sorted = sort(unlist(medians[2]))
        delayTitle = paste("Arrival delay from", input$origin_select, "to", input$dest_select)
        
        # make plot
        p = ggplot(subset_delay, aes(x = reorder(CARRIER_NAME, ARR_DELAY, na.rm = TRUE, FUN = median), y = ARR_DELAY))
        p + geom_boxplot(middle = medians_sorted, aes(fill = CARRIER_NAME)) +
            scale_fill_brewer(palette = "Set2", name = "Carriers") +
            ylim(-50, 50) +
            xlab('') +
            ylab('Arrival Delay (minutes)') +
            ggtitle(delayTitle) +
            theme_bw() +
            theme(axis.text.x = element_text(angle = 45, hjust = 1),
                  text = element_text(size = 16)) +
            theme(legend.position="none")
    })
    
    # show delay type plot in main panel
    output$typePlot = renderPlot({
        
        # get delay types by carrier
        subset_dtype = filter(flights, 
                              ORIGIN_CITY_NAME == input$origin_select & 
                              DEST_CITY_NAME == input$dest_select & 
                              !is.na(CARRIER_DELAY) &
                              FL_DATE >= input$dateRange[1] & 
                              FL_DATE <= input$dateRange[2] &
                              CRS_DEP_TIME >= input$early_time &
                              CRS_DEP_TIME <= input$late_time)
        dtypeTitle = paste("Delay type proportions from", input$origin_select, "to", input$dest_select)
        sum_dtype = group_by(subset_dtype, CARRIER_NAME) %>% summarise(CARRIER_DELAY_TOT = sum(CARRIER_DELAY), 
                                                                       WEATHER_DELAY_TOT = sum(WEATHER_DELAY),
                                                                       SECURITY_DELAY_TOT = sum(SECURITY_DELAY),
                                                                       NAS_DELAY_TOT = sum(NAS_DELAY),
                                                                       LATE_AIRCRAFT_DELAY_TOT = sum(LATE_AIRCRAFT_DELAY))
        
        # rearrange data by making new data frame where columns become categories for each carrier
        rearrange_dtype = rbind(data.frame(DELAY = sum_dtype$CARRIER_DELAY_TOT, TYPE = "Carrier", CARRIER = sum_dtype$CARRIER_NAME), 
                                data.frame(DELAY = sum_dtype$WEATHER_DELAY_TOT, TYPE = "Weather", CARRIER = sum_dtype$CARRIER_NAME),
                                data.frame(DELAY = sum_dtype$SECURITY_DELAY_TOT, TYPE = "Security", CARRIER = sum_dtype$CARRIER_NAME),
                                data.frame(DELAY = sum_dtype$NAS_DELAY_TOT, TYPE = "NAS", CARRIER = sum_dtype$CARRIER_NAME),
                                data.frame(DELAY = sum_dtype$LATE_AIRCRAFT_DELAY_TOT, TYPE = "Late Aircraft", CARRIER = sum_dtype$CARRIER_NAME))
        
        
        # make plot
        ggplot(rearrange_dtype, aes(x = CARRIER, y = DELAY, fill = TYPE)) + 
            geom_bar(position = "fill", stat = "identity") + 
            xlab('') + 
            ylab('') +
            ggtitle(dtypeTitle) +
            scale_fill_brewer(palette = "Set3", name = "Delay Type") +
            theme_bw() +
            theme(axis.text.x = element_text(angle = 45, hjust = 1),
                  text = element_text(size = 16)) + 
            guides(fill = guide_legend(reverse=TRUE))
    })
    
    # show flight cancellations plot in main panel
    output$cancelPlot = renderPlot({
        
        # get cancellations by carrier
        subset_cancel = filter(flights, 
                               ORIGIN_CITY_NAME == input$origin_select & 
                               DEST_CITY_NAME == input$dest_select & 
                               CANCELLED == 1 &
                               FL_DATE >= input$dateRange[1] & 
                               FL_DATE <= input$dateRange[2] &
                               CRS_DEP_TIME >= input$early_time &
                               CRS_DEP_TIME <= input$late_time)
        cancelTitle = paste("Cancellations from", input$origin_select, "to", input$dest_select)
        
        # make plot
        qplot(CARRIER_NAME, data = subset_cancel, geom = 'bar', fill = CANCELLATION_DESC, position = 'dodge') +
            xlab('') + 
            ylab('# Cancellations') +
            ggtitle(cancelTitle) +
            scale_fill_brewer(palette = "Set2", name = "Cancellation Reason") +
            theme_bw() +
            theme(axis.text.x = element_text(angle = 45, hjust = 1),
                  text = element_text(size = 16))

    })
    
    output$mapPlot = renderPlot({
        
        # plot flight map
        map_plot(input$origin_select, input$dest_select)
    })
      
})