
shinyUI(fluidPage(
  
  titlePanel('The US Federal Budget'),
  
  tabsetPanel(
    tabPanel('Introduction',
             fluidRow(
               br(),
               column(12,
                      img(src = "motivation.png",height=300,width=400)),
               column(12,
                      br(),
                      br(),
                      p('Motivation for this project comes from this site:',
                        a(href='http://www.usgovernmentspending.com/breakdown','usgovernmentspending.com'),
                        style = 'font-size:15pt;')
                      ),
               column(12,
                      p("Data was taken from the",
                        a(href='https://github.com/WhiteHouse/2016-budget-data', "White House GitHub"), 
                        "account in July 2015.",style = "font-size:15pt;")
                      ),
               column(12,
                      p('Inflation data came from',
                        a(href='http://www.multpl.com/inflation/table','US Inflation Rate per Year.'),
                        style = 'font-size:15pt;')
                      ),
               column(12,
                      p('Special thanks to',
                        'Ale, Andrew, Bryan, Jason, Luke, Shu and Xavier',
                        'for patience and wonderful advice.',
                        style = 'font-size:15pt;')),
               column(12,
                      p('Additional helpful websites',
                        br(),
                        a(href='https://www.nationalpriorities.org/budget-basics/federal-budget-101/spending/',
                          'Budget Basics'),
                        br(),
                        a(href='https://www.whitehouse.gov/omb','Office of Management and Budget')))
             )
    ),
    
    tabPanel('Receipts',
      fluidRow(
        column(2, offset = 1,
          selectInput('r_year',
                  label = 'Year', 
                  choices = names(receipts)[r_years])
              ),
        column(3,
          selectInput('r_index',
                  label = 'Index',
                  multiple = TRUE,
                  choices = names(receipts)[r_indices], 
                  selected = names(receipts)[r_indices][1])
              ),
        column(3,
               selectInput("r_inSelect", 
                           label = "Select panes",
                           multiple = TRUE,
                           choices = '') # has to be defined.
        ),
      submitButton('Submit')
              ),
      plotOutput('plotr'),
      checkboxInput('adjust', 
                    'Adjust below prices for inflation', value = FALSE),
      plotOutput('plotr_yrs')
    ),
    
    tabPanel('Outlays',
      fluidRow(
        column(2, offset = 1,
          selectInput('o_year',
                  label = 'Year',
                  choices = names(outlays)[o_years])
              ),
        column(3,
          selectInput('o_index',
                  label = 'Index',
                  multiple = TRUE,
                  choices = names(outlays)[o_indices],
                  selected = names(outlays)[o_indices][1])
              ),
        column(3,
               selectInput("o_inSelect", 
                  label = "Select panes",
                  multiple = TRUE,
                  choices = '') # has to be defined.
        ),
      submitButton('Submit')
           ),
    plotOutput('ploto'),
    checkboxInput('adjust', 
                  'Adjust below prices for inflation', value = FALSE),
    plotOutput('ploto_yrs')
    ),
    
    tabPanel('BudgetAuthority',
      fluidRow(
        column(2, offset = 1,
          selectInput('b_year',
            label = 'Year', 
            choices = names(budauth)[b_years])
                      ),
          column(3,
            selectInput('b_index',
              label = 'Index',
              multiple = TRUE,
              choices = names(budauth)[b_indices],
              selected = names(budauth)[b_indices][1])
                ),
          column(3,
               selectInput("b_inSelect", 
                           label = "Select panes",
                           multiple = TRUE,
                           choices = '') # has to be defined.
                ),
          submitButton('Submit')
             ),
      plotOutput('plotb'),
      checkboxInput('adjust', 
                    'Adjust below prices for inflation', value = FALSE),
      plotOutput('plotb_yrs')
    )
  ) 
))