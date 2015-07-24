
shinyUI(fluidPage(
  
  titlePanel('The US Federal Budget'),
  
  tabsetPanel(
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