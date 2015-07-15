library(dplyr)
library(treemap)
library(lazyeval)
library(RColorBrewer)
library(ggplot2)
library(reshape2)
library(extrafont)
# IMPROVEMENTS:
# 1. have receipts, outlays and budget authority in variable dependent
# on current tab chosen.
# 2. print $amounts with commas.
# 3. get rid of X in front of years
# 4. get to fit on one page.
# 6. add links to helper pages

shinyServer(function(input, output, session) {
  
  # Plotting treemap of receipts. (Area and Color) = $ amount.
  output$plotr <- renderPlot({
    total = format(sum(receipts[input$r_year]),big.mark=",",scientific=FALSE)
    treemap(receipts, 
            index = input$r_index, 
            vSize = input$r_year, 
            vColor = input$r_year, 
            palette = 'Greens',
            type = 'value',
            title = paste('TOTAL ', total))
  })
  # Dynamic UI input for selecting subcategories to plot.======
  observe({
    pane <- input$r_index[1]
    # Select input =============================================
    # Create a list of subcategories, where the name of the items
    # is the row and the values are the row contents.
    s_options <- list()
    s_options[[ paste(1:length(receipts[pane]))]] <- 
      unique(receipts[pane])
    
    # Select items. With multi-select, can chose > 1.============
    updateSelectInput(session, "r_inSelect",
                      #label = input$r_inSelect,
                      choices = s_options,
                      selected = sprintf(pane)
    )
    if(!is.null(input$r_inSelect)) {
    data = as.data.frame(setNames(replicate(length(input$r_inSelect), 
                                            numeric(length(r_years)),
                                            simplify=F),
                                  input$r_inSelect))
    ## Get each selection into one dataframe
     for(i in 1:length(input$r_inSelect)) {
        data[i] = colSums(receipts[(receipts[ ,pane] == input$r_inSelect[i]), r_years])
     }
    finalInput <- reactive({
      if (!input$adjust) return(data)
      (data / head(i_rate$adjuster,length(r_years)))
    })
    data = finalInput()
    data = cbind(Years = names(receipts[r_years]),data)
    ## Melt variable column names into one col along which to separate
    data = melt(data, id.vars = 'Years', variable.name = 'Category')
    output$plotr_yrs <- renderPlot({
        ggplot(data, aes(as.numeric(Years),value,colour=Category)) + 
        xlab('Years') + ylab('USD') +
        geom_line(size=3) +
        theme_bw() +
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
            type = 'value',
            title = paste('TOTAL ', total))
  })
  # Dynamic UI input for selecting subcategories to plot.======
  observe({
    opane <- input$o_index[1]
    # Select input =============================================
    # Create a list of subcategories, where the name of the items
    # is the row and the values are the row contents.
    s_options <- list()
    s_options[[ paste(1:length(outlays[opane]))]] <- 
      unique(outlays[opane])
    
    # Select items. With multi-select, can chose > 1.============
    updateSelectInput(session, "o_inSelect",
                      #label = input$o_inSelect,
                      choices = s_options,
                      selected = sprintf(opane)
    )
    if(!is.null(input$o_inSelect)) {
      data = as.data.frame(setNames(replicate(length(input$o_inSelect), 
                                              numeric(length(o_years)),
                                              simplify=F),
                                    input$o_inSelect))
      ## Get each selection into one dataframe
      for(i in 1:length(input$o_inSelect)) {
        data[i] = colSums(outlays[(outlays[ ,opane] == input$o_inSelect[i]), o_years])
      }
      finalInput <- reactive({
        if (!input$adjust) return(data)
        (data / head(i_rate$adjuster,length(o_years)))
      })
      data = finalInput()
      data = cbind(Years = names(outlays[o_years]),data)
      ## Melt variable column names into one col along which to separate
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
            type='value',
            title = paste('TOTAL', total))
  })
  # Dynamic UI input for selecting subcategories to plot.======
  observe({
    bpane <- input$b_index[1]
    # Select input =============================================
    # Create a list of subcategories, where the name of the items
    # is the row and the values are the row contents.
    s_options <- list()
    s_options[[ paste(1:length(budauth[bpane]))]] <- 
      unique(budauth[bpane])
    
    # Select items. With multi-select, can chose > 1.============
    updateSelectInput(session, "b_inSelect",
                      #label = input$b_inSelect,
                      choices = s_options,
                      selected = sprintf(bpane)
    )
    if(!is.null(input$b_inSelect)) {
      data = as.data.frame(setNames(replicate(length(input$b_inSelect), 
                                              numeric(length(b_years)),
                                              simplify=F),
                                    input$b_inSelect))
      ## Get each selection into one dataframe
      for(i in 1:length(input$b_inSelect)) {
        data[i] = colSums(budauth[(budauth[ ,bpane] == input$b_inSelect[i]), b_years])
      }
      finalInput <- reactive({
        if (!input$adjust) return(data)
        (data / head(i_rate$adjuster,length(b_years)))
      })
      data = finalInput()
      data = cbind(Years = names(budauth[b_years]),data)
      ## Melt variable column names into one col along which to separate
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

