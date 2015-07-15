library(shiny)
ma = readRDS("data/final.RDS")
shinyUI(navbarPage("Interpreting Malpractice Lawsuits",
  tabPanel("By Payment",
      sidebarPanel(
        #helpText("Choose what happened to the patient"),      
        selectInput("outcome", "Choose what happened to the patient:",choices=c("All","Death","Unknown","Emotional Injury","Insignificant",
                                                  "Major Permanent Injury", "Major Temporary Injury",
                                                  "Minor Permanent Injury", "Minor Temporary Injury",
                                                  "Significant Permanent Injury","Quadriplegic Brain Damage Lifelong Care"
                                                  )),
        checkboxGroupInput('vars', 'Compare allegations against the professional:',
                           choices=levels(ma$allegation)[-(1:2)], selected = "Anesthesia Related"),
        hr(),
        helpText("Specify a range of total payment"),
        sliderInput("payrange",label = "Payment Range (millions):",min=0,max=30,value=c(0,1.5),step=0.5),
        submitButton("Update Density plot")
      ),
    mainPanel(h4("What is the distribution of malpractice payments?"),
            plotOutput("hist"),
            h4("Summary Statistics in millions of dollars:"),
            verbatimTextOutput("summary"))
            
    ),
  tabPanel("By Professional",
           sidebarPanel(helpText("Medical professionals get accused of malpractice quite often. Filter by patient outcome and allegation against the professional to get a better idea of which lawsuits occur most frequently."),   
             selectInput("outcome2", "Choose what happened to the patient:",choices=c("All Outcomes","Death","Unknown","Emotional Injury","Insignificant",
                                                                 "Major Permanent Injury", "Major Temporary Injury",
                                                                 "Minor Permanent Injury", "Minor Temporary Injury",
                                                                 "Significant Permanent Injury","Quadriplegic Brain Damage Lifelong Care"
             )),
              selectInput('vars2', 'Choose an allegation against the professional:',
                                  choices = c("All Allegations",levels(ma$allegation)[-(1:2)])),
             checkboxGroupInput('profs', 'Compare professions:',
                                choices=names(head(summary(ma$defendent),n=10)),selected="Allopathic Physician (MD)"),
             
             submitButton("Update Barplot")
             ),
      mainPanel(h4("Which medical professionals are found guilty of malpractice most often?"),
        plotOutput("profession"))
    ),
  tabPanel("By Patient",
           sidebarPanel(
             
             helpText("Malpractice is usually about what the professional did wrong, but certain types of 
                      patients may be more susceptible to conditions that require risky and or 
                      uncomfortable procedures."),
             selectInput('vars3', 'Choose the allegation against the defendent:',
                         choices = c("All Allegations",levels(ma$allegation)[-(1:2)])),
             selectInput("outcome3", "Choose what happened to the patient:",choices=c("All Outcomes","Death","Unknown","Emotional Injury","Insignificant",
                                                                                      "Major Permanent Injury", "Major Temporary Injury",
                                                                                      "Minor Permanent Injury", "Minor Temporary Injury",
                                                                                      "Significant Permanent Injury","Quadriplegic Brain Damage Lifelong Care"
             )),
             
             submitButton("Update Barplot")
           ),
           mainPanel(h4("Are certain types of patients more likely to sue than others?"),
                     plotOutput("patients"),
                     h4("Summary Statistics (Payments in millions of dollars) - "),
                     verbatimTextOutput("summary_pt")
           )
  ),
  tabPanel("Closing thoughts",
           img(src="http://www.conservativecartoons.com/2004/flawlessly.gif",width = "50%",height = 'auto'),
           p("The distribution of malpractice payouts seems to imply a more complex structure within the data based on allegation. Many of them share similar secondary and or tertiary peaks in total payout."),

              p("Doctors are the heroes of hospitals. They take almost all of the blame for failures, while shielding their students and nurses."),
             
             p("Women sue doctors more often than men, and are far more likely to sue due to 'insignificant' or 'emotional injury'. Malpractice lawyers must love them...")
           
           )
))