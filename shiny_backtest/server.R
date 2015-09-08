# server.R

library(quantmod)
source("helpers.R")

shinyServer(function(input, output) {
  
  dataInput <- reactive({
    result=list()
    data = getSymbols(input$symb, src = "yahoo", 
               from = input$dates[1],
               to = input$dates[2],
               auto.assign = FALSE)
    
    result$data    = data
    return(result)
  })  
  
  output$plot <- renderPlot({
    data  = dataInput()$data
    strategy = BB_Strategy_Generate(data, input$BB_win,
                        input$sd, day_stop = input$stop_day, processed= input$processed,
                        modi_macd= input$modi_macd, macd_fast=input$macd_fast,
                        macd_slow=input$macd_slow, macd_signal= input$macd_signal,
                        stop_trig = input$stop_trig, stop_profit=input$stop_profit)

    args <-    switch(input$plot_select,
                    "1" = ", theme = chartTheme('white'), type = 'line', TA=NULL)",
                    "2" = ", theme = chartTheme('white'), TA=NULL)"
                    )
    plot_func <-switch(input$plot_select,
                    "1" = "chartSeries(data[,6], name=input$symb",
                    
                    "2" = "chartSeries(data, name=input$symb"
                    )
    
    eval(parse(text = paste0(plot_func, args)))
#####################################################################################  
    if(input$addVo) show(addVo())
    if(input$addBB){
      show(addBBands(n=input$BB_win, sd= input$sd))
    }

    if(input$processed){ 
      #################Plot Transaction####################################
      strategy$Buy[which(strategy$Buy==0)]=NA
      if( length(strategy$Buy[which(!is.na(strategy$Buy))] ) !=0 ){
        show(
          addPoints(  y=as.vector(strategy$Buy[which(!is.na(strategy$Buy))]),
                      x=which( !is.na(strategy$Buy)), pch='B', col='red'))}
      strategy$Sell[which(strategy$Sell==0)]=NA
      if( length(strategy$Sell[which(!is.na(strategy$Sell))] ) !=0 ){
        show(
          addPoints(  y=as.vector(strategy$Sell[which(!is.na(strategy$Sell))]), 
                      x=which( !is.na(strategy$Sell)), pch='S', col='blue'))}
      #####################################################################
      
      #################Compute Cumulative Return###########################
      lll = length( index(strategy) )
      ll  = lll-1
      M =cbind(as.vector(strategy[,1][-lll]), as.vector(strategy$holding[-1]), as.vector(strategy$holding[-lll]))
      M[,2]= M[,1]*M[,2]; M[,3]= M[,1]*M[,3]
      B= M[,2]; B= B[-ll]; B= c(0, B); M[,2]= B
      M[which(M[,2]==0),2]=NA; M[which(M[,3]==0),3]=NA
      M[,1]= (M[,3]-M[,2]) / M[,2]
      B= M[,1]; B[which(is.na(B))]=0; M[,1]=B;d_ret=c(0, M[,1])+1
      c_rst = rep(1, lll); for(i in 2: lll){c_rst[i]= c_rst[i-1]*d_ret[i]}
      strategy$d_ret= xts(d_ret, order.by= index(strategy))
      strategy$result= xts(c_rst, order.by= index(strategy))
      #####################################################################
      
      #####################Plot Cumulative Return##########################
      a= strategy$result[[lll]]
      a= 100*(a-1)
      a= round(a,0)
      legend= paste('Cumulative Return: ', a, '%', sep='')
      show(addTA(strategy$result, legend= legend) )
    }
           
    
     if(input$addMACD){
       if(input$macd_fast < input$macd_signal | input$macd_signal <  input$macd_slow)###???
         addMACD(fast=input$macd_fast, slow=input$macd_slow, signal= input$macd_signal)
       else print('Invalid Parameter')####????
    }
  })
})


