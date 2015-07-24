library(ggplot2)
library(dplyr)
library(shiny)
ma = readRDS("data/final.RDS")

ma$total_pay = ma$total_pay/(1e6)

result = ma$patient_outcome
shinyServer(
  function(input, output) {
#     output$imag1 = renderImage({
#       src="img/patient.gif"
#     })
    output$hist <- renderPlot({
      injury <<-  switch(input$outcome,
               "All" = ma,
               "Death" = ma[result == 'Death',],
               "Unknown" = ma[result == 'Cannot Be Determined from Available Records',],
               "Emotional Injury" = ma[result =='Emotional Injury Only',],
               "Insignificant" = ma[result =='Insignificant Injury',],
               "Major Permanent Injury" = ma[result =='Major Permanent Injury',], 
               "Major Temporary Injury" = ma[result =='Major Temporary Injury',],
               "Minor Permanent Injury" = ma[result =='Minor Permanent Injury',], 
               "Minor Temporary Injury" = ma[result =='Minor Temporary Injury',],
               "Significant Permanent Injury" = ma[result =='Significant Permanent Injury',],
               "Quadriplegic Brain Damage Lifelong Care" = ma[result =='Quadriplegic Brain Damage Lifelong Care',]       
               )
      payswitch <<- filter(injury, allegation %in% input$vars, total_pay<=input$payrange[2],total_pay>=input$payrange[1])
               
      qplot(total_pay, data = payswitch, geom = "density",color = allegation,xlab="Total Payment (millions of dollars)",main="Density of lawsuit payments by patient outcome") +
        coord_cartesian(xlim = c(input$payrange[1],input$payrange[2])) +
        scale_x_continuous(breaks=seq(0,input$payrange[2], input$payrange[2]/10))
    })

      output$summary = renderText({
        payswitch <<- filter(injury, allegation %in% input$vars, total_pay<=input$payrange[2],total_pay>=input$payrange[1])
        
        paste0(
          "Minimum: ", summary(payswitch$total_pay)[1],"\n",
            "Maximum: ", summary(payswitch$total_pay)[6],"\n",
            "Average: ", summary(payswitch$total_pay)[4],"\n",
            "1st Quantile: ", summary(payswitch$total_pay)[2],"\n",
            "Median: ", summary(payswitch$total_pay)[3],"\n",
            
            "3rd Quantile: ", summary(payswitch$total_pay)[5]                    )
         })
   output$profession = renderPlot({
     
     dat <<-  switch(input$outcome2,
                        "All Outcomes" = ma,
                        "Death" = ma[result == 'Death',],
                        "Unknown" = ma[result == 'Cannot Be Determined from Available Records',],
                        "Emotional Injury" = ma[result =='Emotional Injury Only',],
                        "Insignificant" = ma[result =='Insignificant Injury',],
                        "Major Permanent Injury" = ma[result =='Major Permanent Injury',], 
                        "Major Temporary Injury" = ma[result =='Major Temporary Injury',],
                        "Minor Permanent Injury" = ma[result =='Minor Permanent Injury',], 
                        "Minor Temporary Injury" = ma[result =='Minor Temporary Injury',],
                        "Significant Permanent Injury" = ma[result =='Significant Permanent Injury',],
                        "Quadriplegic Brain Damage Lifelong Care" = ma[result =='Quadriplegic Brain Damage Lifelong Care',]   
     )
     
     df2 <<-  switch(input$vars2,
                         "All Allegations" = dat,
                         "Anesthesia Related" = dat[dat$allegation == 'Anesthesia Related',],
                         "Behavioral Health Related" = dat[dat$allegation == 'Behavioral Health Related',],
                         "Diagnosis Related" = dat[dat$allegation == 'Diagnosis Related',],         
                         "Equipment/Product Related"  = dat[dat$allegation == 'Equipment/Product Related',],
                         "IV & Blood Products Related" = dat[dat$allegation == 'IV & Blood Products Related',],
                         "Medication Related" = dat[dat$allegation == 'Medication Related',],
                         "Monitoring Related" = dat[dat$allegation == 'Monitoring Related',],
                         "Obstetrics Related" = dat[dat$allegation == 'Obstetrics Related',],
                         "Other Miscellaneous" = dat[dat$allegation == 'Other Miscellaneous',],
                         "Surgery Related" = dat[dat$allegation == 'Surgery Related',],
                         "Treatment Related" = dat[dat$allegation == 'Treatment Related',])
     
    df2 = filter(df2,df2$defendent %in% input$profs)
     ggplot(data = df2, aes(x=defend_age, y= ..count..))+xlab('Defendent Age Group') + geom_bar(aes(fill=defendent)) +
       coord_flip()
      # scale_color_gradient2(df$defendent,low='white',high = 'red')
   })
   output$patients = renderPlot({
     
     dat_pat <<-  switch(input$outcome3,
                     "All Outcomes" = ma,
                     "Death" = ma[result == 'Death',],
                     "Unknown" = ma[result == 'Cannot Be Determined from Available Records',],
                     "Emotional Injury" = ma[result =='Emotional Injury Only',],
                     "Insignificant" = ma[result =='Insignificant Injury',],
                     "Major Permanent Injury" = ma[result =='Major Permanent Injury',], 
                     "Major Temporary Injury" = ma[result =='Major Temporary Injury',],
                     "Minor Permanent Injury" = ma[result =='Minor Permanent Injury',], 
                     "Minor Temporary Injury" = ma[result =='Minor Temporary Injury',],
                     "Significant Permanent Injury" = ma[result =='Significant Permanent Injury',],
                     "Quadriplegic Brain Damage Lifelong Care" = ma[result =='Quadriplegic Brain Damage Lifelong Care',]   
     )
     
     df3 <<-  switch(input$vars3,
                     "All Allegations" = dat_pat,
                     "Anesthesia Related" = dat_pat[dat_pat$allegation == 'Anesthesia Related',],
                     "Behavioral Health Related" = dat_pat[dat_pat$allegation == 'Behavioral Health Related',],
                     "Diagnosis Related" = dat_pat[dat_pat$allegation == 'Diagnosis Related',],         
                     "Equipment/Product Related"  = dat_pat[dat_pat$allegation == 'Equipment/Product Related',],
                     "IV & Blood Products Related" = dat_pat[dat_pat$allegation == 'IV & Blood Products Related',],
                     "Medication Related" = dat_pat[dat_pat$allegation == 'Medication Related',],
                     "Monitoring Related" = dat_pat[dat_pat$allegation == 'Monitoring Related',],
                     "Obstetrics Related" = dat_pat[dat_pat$allegation == 'Obstetrics Related',],
                     "Other Miscellaneous" = dat_pat[dat_pat$allegation == 'Other Miscellaneous',],
                     "Surgery Related" = dat_pat[dat_pat$allegation == 'Surgery Related',],
                     "Treatment Related" = dat_pat[dat_pat$allegation == 'Treatment Related',])
     levels(df3$pt_age)[1]="Fetus"
     levels(df3$pt_age)[2]="Under 1 year"
     mads <<- filter(df3,df3$ptgender %in% c("F","M"),df3$pt_age %in% levels(df3$pt_age))
     g = ggplot(data = mads, aes(x=pt_age, y= ..count..))+xlab('Patient Age Group') + geom_bar(aes(fill=ptgender),position='dodge') +
       coord_flip()
     
   
   output$summary_pt = renderText({
     #mads <<- filter(df3,df3$ptgender %in% c("F","M"),df3$pt_age %in% levels(df3$pt_age))
     
     male = mads[mads$ptgender=="M",]
     female = mads[mads$ptgender=='F',]
     paste0("Male:",'\n',
            'Total Count: ', toString(dim(male)[1]),'\n',
            'Average payment: ',toString(summary(male$total_pay)[4]),'\n',
            'Median payment: ',toString(summary(male$total_pay)[3]),'\n','\n',
            "Female:",'\n',
            'Total Count: ', toString(dim(female)[1]),'\n',
            'Average payment: ',toString(summary(female$total_pay)[4]),'\n',
            'Median payment: ',toString(summary(female$total_pay)[3]),'\n'
     )})
   g
   })
  }
)