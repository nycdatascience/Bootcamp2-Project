library(dplyr)
library(treemap)
library(reshape2)
library(ggplot2)

shinyServer(function(input, output, session) {
  # Plotting treemap. Area and color both represent dollar amount.
  # Area is absolute dollar amount, as you can't have negative area.
  # Area column is added dynamically as needed.
  output$plotr <- renderPlot({
    total = format(sum(receipts[input$r_year]),big.mark=",",scientific=FALSE)
    receipts[paste0(input$r_year,'abs')] <- abs(receipts[input$r_year])
    treemap(receipts, 
            index = input$r_index, 
            vSize = paste0(input$r_year,'abs'), 
            vColor = input$r_year, 
            palette = 'RdYlGn',
            fontsize.label = c(16,12,10),
            type = 'value',
            title = paste('TOTAL $', total))
  })
  # Dynamic UI input for selecting subcategories to plot.====================
  observe({
    # Get appropriate list of subcategories based on chosen index.
    pane <- input$r_index[1]
    s_options <- list()
    s_options[[ paste(1:length(receipts[pane]))]] <- 
      unique(receipts[pane])
    
    # Select items to plot. Multi-select in ui.R allows more than 1 choice.
    updateSelectInput(session, "r_inSelect",
                      choices = s_options,
                      selected = sprintf(pane)
    )
    # Only create dataframe of values to plot if a selection has been made.
    if(!is.null(input$r_inSelect)) {
    data = as.data.frame(setNames(replicate(length(input$r_inSelect), 
                                            numeric(length(r_years)),
                                            simplify=F),
                                  input$r_inSelect))
    # Combine all selections into one dataframe
     for(i in 1:length(input$r_inSelect)) {
        data[i] = colSums(receipts[(receipts[ ,pane] == input$r_inSelect[i]), r_years])
     }
    # Adjust for inflation only if checkbox checked.
    finalInput <- reactive({
      if (!input$adjust) return(data)
      (data / head(i_rate$adjuster,length(r_years)))
    })
    data = finalInput()
    data = cbind(Years = names(receipts[r_years]),data)
    # Melt into long form in order to separate category by color.
    data = melt(data, id.vars = 'Years', variable.name = 'Category')
    output$plotr_yrs <- renderPlot({
        ggplot(data, aes(as.numeric(Years),value,colour=Category)) + 
        xlab('Years') + ylab('USD') +
        geom_line(size=3) +
        theme_bw() +
        theme(text = element_text(size = 16),
                        axis.text.x = element_text(angle=45)) +
        scale_x_discrete(
          breaks = seq(1,length(r_years),5), 
          labels = names(receipts[r_years[seq(1,length(r_years),5)]])
        )
        })
    }
  })

  output$ploto <- renderPlot({
    total = format(sum(receipts[input$o_year]),big.mark=",",scientific=FALSE)
    outlays[paste0(input$o_year,'abs')] <- abs(outlays[input$o_year])
    treemap(outlays, 
            index = input$o_index, 
            vSize = paste0(input$o_year,'abs'), 
            vColor = input$o_year, 
            palette = '-RdYlGn',
            fontsize.label = c(16,12,10),
            type = 'value',
            title = paste('TOTAL $', total))
  })
  observe({
    output$text2 <- renderText({
      print(input$current)
    })
    opane <- input$o_index[1]
    s_options <- list()
    s_options[[ paste(1:length(outlays[opane]))]] <- 
      unique(outlays[opane])
    
    updateSelectInput(session, "o_inSelect",
                      choices = s_options,
                      selected = sprintf(opane)
    )
    if(!is.null(input$o_inSelect)) {
      data = as.data.frame(setNames(replicate(length(input$o_inSelect), 
                                              numeric(length(o_years)),
                                              simplify=F),
                                    input$o_inSelect))
      for(i in 1:length(input$o_inSelect)) {
        data[i] = colSums(outlays[(outlays[ ,opane] == input$o_inSelect[i]), o_years])
      }
      finalInput <- reactive({
        if (!input$adjust) return(data)
        (data / head(i_rate$adjuster,length(o_years)))
      })
      data = finalInput()
      data = cbind(Years = names(outlays[o_years]),data)
      data = melt(data, id.vars = 'Years', variable.name = 'Category')
      output$ploto_yrs <- renderPlot({
        ggplot(data, aes(as.numeric(Years),value,colour=Category)) +
          xlab('Years') + ylab('USD') +
          geom_line(size=3) +
          theme_bw() +
          scale_x_discrete(
            breaks = seq(1,length(o_years),5), 
            labels = names(outlays[o_years[seq(1,length(o_years),5)]])
          )
      })
    }
  })
    
  output$plotb <- renderPlot({
  total = format(sum(receipts[input$b_year]),big.mark=",",scientific=FALSE)
  budauth[paste0(input$b_year,'abs')] <- abs(budauth[input$b_year])
    treemap(budauth, 
            index=input$b_index, 
            vSize=paste0(input$b_year,'abs'), 
            vColor=input$b_year, 
            palette = '-RdYlGn',
            fontsize.label = c(16,12,10),
            type='value',
            title = paste('TOTAL $', total))
  })
  observe({
    output$text3 <- renderText({
      print(input$current)
    })
    bpane <- input$b_index[1]
    s_options <- list()
    s_options[[ paste(1:length(budauth[bpane]))]] <- 
      unique(budauth[bpane])
    
    updateSelectInput(session, "b_inSelect",
                      choices = s_options,
                      selected = sprintf(bpane)
    )
    if(!is.null(input$b_inSelect)) {
      data = as.data.frame(setNames(replicate(length(input$b_inSelect), 
                                              numeric(length(b_years)),
                                              simplify=F),
                                    input$b_inSelect))
      for(i in 1:length(input$b_inSelect)) {
        data[i] = colSums(budauth[(budauth[ ,bpane] == input$b_inSelect[i]), b_years])
      }
      finalInput <- reactive({
        if (!input$adjust) return(data)
        (data / head(i_rate$adjuster,length(b_years)))
      })
      data = finalInput()
      data = cbind(Years = names(budauth[b_years]),data)
      data = melt(data, id.vars = 'Years', variable.name = 'Category')
      output$plotb_yrs <- renderPlot({
        ggplot(data, aes(as.numeric(Years),value,colour=Category)) + 
          xlab('Years') + ylab('USD') +
          geom_line(size=3) +
          theme_bw() +
          scale_x_discrete(
            breaks = seq(1,length(b_years),5), 
            labels = names(budauth[b_years[seq(1,length(b_years),5)]])
          )
      })
    }
})

})

