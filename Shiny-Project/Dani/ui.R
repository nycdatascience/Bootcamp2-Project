shinyUI(pageWithSidebar(
    headerPanel('Airline Comparison Tool'),
    
    sidebarPanel(
        selectInput('origin_select', 
                    label = 'Origin', 
                    choices = origin, 
                    selected = 'New York, NY'),
        
        selectInput('dest_select', 
                    label = 'Destination',
                    choices = dest,
                    selected = 'San Francisco, CA'),
        
        dateRangeInput('dateRange',
                       label = 'Date Range',
                       start = min(flights$FL_DATE),
                       end = max(flights$FL_DATE)),
        
        selectInput('early_time', 
                    label = 'Departure Time (earliest)', 
                    choices = times, 
                    selected = '00:00'),
        
        selectInput('late_time', 
                    label = 'Departure Time (latest)', 
                    choices = times, 
                    selected = '24:00')
        
    ),
    
    mainPanel(
        tabsetPanel(type = 'tabs',
                    tabPanel('Flights', plotOutput('countPlot')),
                    tabPanel('Delays', plotOutput('delayPlot')),
                    tabPanel('Reason for Delay', plotOutput('typePlot')),
                    tabPanel('Cancellations', plotOutput('cancelPlot'))
        ),
        
        plotOutput('mapPlot')
    )
))