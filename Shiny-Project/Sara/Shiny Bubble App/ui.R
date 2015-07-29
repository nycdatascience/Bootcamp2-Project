shinyUI(fluidPage(
  titlePanel("Total Population, Population Growth, GDP per Capita, and Gini Coefficient"),
    sidebarPanel(
      conditionalPanel(
        'input.stuff === "Region"',
        helpText("Explore the relationship between population, population growth 
                 and gdp per capita by World Bank Regions. Brush over points for datatable output."),
        selectInput('yax', 'Y-axis Variable', 
                    choices=c("Average GDP per Capita (Current $US)", "Average Population Growth (%)", "Total Population")),
        selectInput('bub', 'Bubble Size Variable', 
                    choices=c("Average GDP per Capita (Current $US)", "Average Population Growth (%)", "Total Population")),
        checkboxGroupInput('Region', 'Region', choices=(c('All', c(unique(region$Region)))),
                           selected = 'All'),
        sliderInput('year', 'Year', min = min(region$year), max = max(region$year), 
                    value = c(min(region$year),max(region$year)), sep = "", step=1)
        ),  # End of Conditional Panel
      
      conditionalPanel(
        'input.stuff === "Income Group"',
        helpText("Explore the relationship between population, population growth 
                 and gdp per capita by World Bank Income Groups. Brush over points for datatable output."),
        selectInput('yax2', 'Y-axis Variable', 
                    choices=c("Average GDP per Capita (Current $US)", "Average Population Growth (%)", "Total Population")),
        selectInput('bub2', 'Bubble Size Variable', 
                    choices=c("Average GDP per Capita (Current $US)", "Average Population Growth (%)", "Total Population")),
        checkboxGroupInput('Income', 'Income Group', choices=(c('All', c(unique(income$Income.group)))),
                           selected = 'All'),
        sliderInput('year2', 'Year', min = min(income$year), max = max(income$year), 
                    value = c(min(income$year),max(income$year)), sep = "", step=1)
        ),  # End of Conditional Panel
      
      conditionalPanel(
        'input.stuff === "Income Inequality"',
        helpText("Explore the relationship between population, population growth, 
                 gdp per capita, and income inequality by countries for which there's
                 a gini coefficient for most years 2002-2012. Brush over points for datatable output."),
        selectInput('yax3', 'Y-axis Variable', 
                    choices=c("GDP per Capita (Current $US)", "Population Growth (%)", "Total Population", "Gini Coefficient")),
        selectInput('bub3', 'Bubble Size Variable', 
                    choices=c("GDP per Capita (Current $US)", "Population Growth (%)", "Total Population", "Gini Coefficient")),
        selectInput('country', 'Country', choices=(c('All', c(unique(as.character(gini$Country))))),
                    selected = 'All'),
        sliderInput('year3', 'Year', min = round(min(gini$year), 0), max = round(max(gini$year), 0), 
                    value = c(round(min(gini$year), 0), round(max(gini$year), 0)), round= T, sep = "", step=1)
        ),
      
      conditionalPanel(
        'input.stuff === "Inspiration and Bubbles In Motion"',
        includeMarkdown("inspiration.md")
      ),
      
      conditionalPanel(
        'input.stuff === "Data Source, Classification and Definitions"',
        includeMarkdown("sourceclassdef.md")
      )
      
), # End of Sidebar Panel
    
    mainPanel(
      tabsetPanel(
        id = 'stuff',
        tabPanel('Region', plotOutput("gdppop", brush = "plot_brush")),
        tabPanel('Income Group', plotOutput("gdppopincome", brush = "plot_brush2")),
        tabPanel('Income Inequality', plotOutput("incomeineq", brush = "plot_brush3")),
        tabPanel('Inspiration and Bubbles In Motion', htmlOutput("motionchart"), br(), 
                 helpText("Adjust the speed of motion next to play button. Select x-axis, y-axis and 
                          size variable. Select log or lin for x or y-axis variable. And hover over 
                          bubble for more information about each country."), br(), 
                 htmlOutput("motionchartgini")),
        tabPanel('Data Source, Classification and Definitions', dataTableOutput("Grouping"))
        ),
      
      conditionalPanel(
        'input.stuff === "Region"',
        dataTableOutput("table")),
      
      conditionalPanel(
        'input.stuff === "Income Group"',
        dataTableOutput("table2")),
      
      conditionalPanel(
        'input.stuff === "Income Inequality"',
        dataTableOutput("table3"))
    
      ) # End of mainPanel
) # End of fluidPage
    )  # End of shinyUI

