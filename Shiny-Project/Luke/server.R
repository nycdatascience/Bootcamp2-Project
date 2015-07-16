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
    
    ss= input$stop_trig
    
    strategy = BB_Strategy_Generate(data, input$BB_win,
                      input$sd, day_stop = input$stop_day, processed= input$processed,
                      modi_macd= input$modi_macd, macd_fast=input$macd_fast,
                      macd_slow=input$macd_slow, macd_signal= input$macd_signal,
                      stop_trig = ss)
    
    result$data    = data
    result$strategy= strategy
    return(result)
  })

 #xom = getSymbols('XOM',src="yahoo",from=as.Date('2015-01-01'),to=as.Date('2015-07-01'),auto.assign = FALSE)  
  
  output$plot <- renderPlot({#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    data  = dataInput()$data
    strategy= dataInput()$strategy
    #if(input$log){data = log_convert(data, input$symb)}
    args <-    switch(input$plot_select,
                    "1" = ", theme = chartTheme('white'), type = 'line', TA=NULL)",
                    "2" = ", theme = chartTheme('white'), TA=NULL)"
                    )
    plot_func <-switch(input$plot_select,
                    #"1" = "chartSeries(data[ , which(names(data) %in% paste0(input$symb, '.Adjusted'))]",
                    "1" = "chartSeries(data, name=input$symb",
                    
                    "2" = "chartSeries(data, name=input$symb"
                    )
    
    eval(parse(text = paste0(plot_func, args)))
#####################################################################################  
    if(input$addVo) show(addVo())
    if(input$addBB){
      show(addBBands(n=input$BB_win, sd= input$sd))
    }

    ###DO WE NEED 'SHOW' HERE?
    if(input$processed){ 
#     ss= input$stop_trig
#     if(ss==0) ss=NA;
#     BB_Strategy_Sketch(data, input$BB_win,input$sd, day_stop = input$stop_day, processed= input$processed,modi_macd= input$modi_macd, macd_fast=input$macd_fast,macd_slow=input$macd_slow, macd_signal= input$macd_signal,stop_trig = ss)
      strategy$Dn
      strategy$Dn[which(strategy$Dn==0)]=NA
      if( length(strategy$Dn[which(!is.na(strategy$Dn))] ) !=0 ){
        show(
          addPoints(  y=as.vector(strategy$Dn[which(!is.na(strategy$Dn))]),
                      x=which( !is.na(strategy$Dn)), pch='B', col='red'))}
      strategy$Up[which(strategy$Up==0)]=NA
      if( length(strategy$Up[which(!is.na(strategy$Up))] ) !=0 ){
        show(
          addPoints(  y=as.vector(strategy$Up[which(!is.na(strategy$Up))]), 
                      x=which( !is.na(strategy$Up)), pch='S', col='blue'))}
    }

    if(input$processed){
      lll = length( index(strategy) )
      ll  = lll-1
      M =cbind(as.vector(strategy[,4][-lll]), as.vector(strategy$holding[-1]), as.vector(strategy$holding[-lll]))
      M[,2]= M[,1]*M[,2]; M[,3]= M[,1]*M[,3]
      B= M[,2]; B= B[-ll]; B= c(0, B); M[,2]= B
      
      M[which(M[,2]==0),2]=NA; M[which(M[,3]==0),3]=NA
      
      M[,1]= (M[,3]-M[,2]) / M[,2]
      B= M[,1]; B[which(is.na(B))]=0; M[,1]=B;d_ret=c(0, M[,1])+1
      c_rst = rep(1, lll); for(i in 2: lll){c_rst[i]= c_rst[i-1]*d_ret[i]}
      strategy$d_ret= xts(d_ret, order.by= index(strategy))
      strategy$result= xts(c_rst, order.by= index(strategy))
      show(addTA(strategy$result, legend='Cumulative Return: ')) 
    }
           
        #(data, n=input$BB_win, sd= input$sd, 
         #       day_stop = input$stop_day, modi_macd= input$modi_macd, 
          #      macd_thres_low=input$macd_thres_low, macd_thres_high=input$macd_thres_high) }
     if(input$addMACD){
       if(input$macd_fast < input$macd_signal | input$macd_signal <  input$macd_slow)
         addMACD(fast=input$macd_fast, slow=input$macd_slow, signal= input$macd_signal)
       else print('Invalid Parameter')
    }
  })
})


