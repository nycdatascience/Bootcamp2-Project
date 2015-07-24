#if (!exists(".inflation")) {
#  .inflation <- getSymbols('CPIAUCNS', src = 'FRED', 
 #    auto.assign = FALSE)
#}  

# adjusts yahoo finance data with the monthly consumer price index 
# values provided by the Federal Reserve of St. Louis
# historical prices are returned in present values


#Add better return = function( proforli, strategy, fee.....)
#Add Stop rule by time and percentage, Add momentum indicator(MACD and ADX),
#consider other range ATR





adjust <- function(data) {

      latestcpi <- last(.inflation)[[1]]
      inf.latest <- time(last(.inflation))
      months <- split(data)               
      
      adjust_month <- function(month) {               
        date <- substr(min(time(month[1]), inf.latest), 1, 7)
        coredata(month) * latestcpi / .inflation[date][[1]]
      }
      
      adjs <- lapply(months, adjust_month)
      adj <- do.call("rbind", adjs)
      axts <- xts(adj, order.by = time(data))
      axts[, 5] <- Vo(data)
      axts
}

log_convert <- function(dataF, symb){
  eval(parse(text = paste0('volume=dataF$',symb, '.Volume')))
  volume =as.matrix(volume)
  volume =as.xts(volume)
  dataF =  apply(dataF,2, log)
  dataF =  as.xts(dataF)
  dataF = merge(dataF[ , -which(names(dataF) %in% paste0(symb, '.Volume'))], volume)
}


BB_Strategy_Generate<- function(dataXts, n=14, sd=2, day_stop=30, processed=FALSE
            , modi_macd = FALSE, macd_fast=12, macd_slow=26, macd_signal=9, stop_trig=0){
  if(stop_trig==0) stop_trig=NA
  #####################Generating order from signal, Unfortunately, I need to copy 
  #####################them to each different process. This part is for 
  #####################nonprocessing
  
  if(!processed){
  HLC= dataXts[,2:4]
  tmp =merge(dataXts, BBands(HLC, n=n, sd=sd)$pctB <=0)
  tmp$pctB = tmp$pctB * tmp[,4]
  colnames(tmp)[7]='Dn'
  tmp$Dn[which(is.na(tmp$Dn))]=0
  tmp =merge(tmp, BBands(HLC, n=n, sd=sd)$pctB >=1)
  tmp$pctB = tmp$pctB * tmp[,4]
  colnames(tmp)[8]='Up'
  tmp$Up[which(is.na(tmp$Up))]=0
  }
  #########################################################################
  
  
  if(processed){ 
    if( is.na(stop_trig)&(!modi_macd)   ){ 
      HLC= dataXts[,2:4]
      tmp =merge(dataXts, BBands(HLC, n=n, sd=sd)$pctB <=0)
      tmp$pctB = tmp$pctB * tmp[,4]
      colnames(tmp)[7]='Dn'
      tmp$Dn[which(is.na(tmp$Dn))]=0
      tmp =merge(tmp, BBands(HLC, n=n, sd=sd)$pctB >=1)
      tmp$pctB = tmp$pctB * tmp[,4]
      colnames(tmp)[8]='Up'
      tmp$Up[which(is.na(tmp$Up))]=0
    
      days    = 0; tmp$holding[[1]] = FALSE
      ll = length(index(tmp))
      
      for(i in 1:ll){
        if( !(tmp$holding[[i]])  ){
          if(i<ll) tmp$holding[[i+1]] = (tmp$Dn[[i]]>0 )#|tmp$holding[i]
          tmp$Up[[i]] = 0}
        else if(days < day_stop){
          tmp$Dn[[i]]=0
          if(i<ll){
            tmp$holding[[i+1]] =   !(tmp$Up[[i]]>0) #|tmp$holding[[i]]????
            days= (days+ 1)*tmp$holding[[i+1]]
          }
        }
        else{
          tmp$Dn[[i]]=0
          tmp$Up[[i]]= tmp[[i,4]]
          if(i< ll) tmp$holding[[i+1]]=FALSE
          days=0
        }
      }
   }#end of without macd
#    else if(modi_macd &  is.na(stop_trig)){
# 
#      tmp$Up[1:35]=0
#      tmp$Dn[1:35]=0
#      tmp$holding[[35]]=FALSE
#      macd = MACD(dataXts[,4])
#      macd$hist = macd$macd - macd$signal
#      macd$hist[which(  is.na( macd$hist  )   )]=0
#      for(i in 35:ll){
#        if(  !(tmp$holding[[i]])   ){
#          buy = tmp$Dn[[i]] & (macd$hist[[i]]>=macd_thres_high)#     >=abs(macd_thres))
#          tmp$Up[[i]]= 0
#          tmp$Dn[[i]]= tmp$Dn[[i]]*as.numeric(buy)
#          if(i<ll){tmp$holding[[i+1]]= buy; days= (days+1)*as.numeric(buy)}
#        }
#        else if(days>= day_stop){
#          tmp$Dn[[i]]=0
#          tmp$Up[[i]]= tmp[[i,4]]
#          days =  0
#          if(i< ll) tmp$holding[[i+1]]=FALSE
#        }
#        else if( days< day_stop ){
#          tmp$Dn[[i]]=0
#          sell = tmp$Up[[i]]
#          sell = sell | (macd$hist[[i]]<=macd_thres_low)
#          tmp$Up[[i]] = tmp[i,4]*as.numeric(  sell )
#          if(i<ll){ tmp$holding[[i+1]] = (!sell); days= (days+1)*as.numeric(!sell) }
#        }
#        else{
#          tmp$Dn[[i]]=0
#          tmp$Up[[i]]= tmp[i,4]
#          if(i<ll){days=0; cost=0; tmp$holding[[i+1]]=FALSE }
#        }
#      }
#    }
   else if( is.na(stop_trig) & modi_macd ){ stop("Please specify Stop Sell Trigger for modifying the order by MACD")}
   else if(   !(is.na(stop_trig)) & !modi_macd     ){#GET RID OF MACD HERE!!!!!!!!
     
     HLC= dataXts[,2:4]
     tmp =merge(dataXts, BBands(HLC, n=n, sd=sd)$pctB <=0)
     tmp$pctB = tmp$pctB * tmp[,4]
     colnames(tmp)[7]='Dn'
     tmp$Dn[which(is.na(tmp$Dn))]=0
     tmp =merge(tmp, BBands(HLC, n=n, sd=sd)$pctB >=1)
     tmp$pctB = tmp$pctB * tmp[,4]
     colnames(tmp)[8]='Up'
     tmp$Up[which(is.na(tmp$Up))]=0
     
     cost  = tmp$Dn[[1]]
     days    = 0; tmp$holding[[1]] = FALSE
     ll = length(index(tmp))
     
     for(i in 1: ll){
       if(   !(tmp$holding[[i]])   ){
         tmp$Up[[i]]=0
         buy =   (tmp$Dn[[i]]>0)
         if(buy){ cost= tmp[[i,4]]; days=days+1; if(i<ll){tmp$holding[[i+1]]=TRUE}}
         else{tmp$Dn[[i]]=0; if(i<ll){tmp$holding[[i+1]]=FALSE}}
       }
       else if(days < day_stop){
         tmp$Dn[[i]]=0
         sell = (tmp$Up[[i]]>0) | ((tmp[i,4]-cost)/cost < (-stop_trig))
         tmp$Up[[i]]=tmp[i,4]*as.numeric(sell)
         if(i<ll){ 
           tmp$holding[[i+1]]= !sell
           days= (days+1)*as.numeric(!sell)
           cost =  max(tmp[[i,4]],cost) *as.numeric(!sell)
         }
       }
       else if(days >= day_stop){
         tmp$Dn[[i]]=0
         tmp$Up[[i]]=tmp[[i,4]]
         days=0;cost=0
         if(i<ll) tmp$holding[[i+1]]=FALSE
       }
     }
   }
   else if(   !(is.na(stop_trig)) & modi_macd       ){ #WITH MACD HERE!!!!!!!!!!!!!!!!!!!!!!!!!!
     
     days    = 0 
     macd = MACD(dataXts[,4], nFast=macd_fast, nSlow=macd_slow, nSig=macd_signal)
     macd$hist = macd$macd - macd$signal
     macd$hist[which(  is.na( macd$hist  )   )]=0
     macd = macd_idx(macd$hist)
     
     HLC= dataXts[,2:4]
     tmp =merge(dataXts, BBands(HLC, n=n, sd=sd)$pctB)
     ll = length(index(tmp))
     tmp$pctB[which(is.na(tmp$pctB))]=0.5
     tmp$Up=0; tmp$Dn= 0
     cost  = tmp$Dn[[1]]
     tmp$holding[[1]]= FALSE

#################################################################     
     #tmp$macd= macd
#################################################################



     for(i in 1: ll){
       if(   !(tmp$holding[[i]])   ){
         tmp$Up[[i]]=0
         buy =   sig2Buy(tmp$pctB[[i]], macd[[i]])
         if(buy){ tmp$Dn[[i]]=tmp[[i,4]]; cost= tmp[[i,4]]; days=days+1
                  if(i<ll){tmp$holding[[i+1]]=TRUE}}
         else{tmp$Dn[[i]]=0; if(i<ll){tmp$holding[[i+1]]=FALSE}}
       }
       else if(days < day_stop){
         tmp$Dn[[i]]=0
         ss= -sig2Stop(macd[[i]],stop_trig)
         sell = sig2Sell(tmp$pctB[[i]], macd[[i]]) | ((tmp[[i,4]]-cost)/cost < ss)
         if(sell){;tmp$Up[[i]]= tmp[[i,4]]; days=0; cost=0;}
         else {
           tmp$Up[[i]]=0;days=days+1; cost=max(tmp[[i,4]], cost)
         }
         if(i<ll) {tmp$holding[[i+1]]= !sell;}
       }
       else if(days >= day_stop){
         tmp$Dn[[i]]=0
         tmp$Up[[i]]=tmp[[i,4]]
         days=0;cost=0
         if(i<ll) tmp$holding[[i+1]]=FALSE
       }
       tmp$ss[[i]] = -sig2Stop(macd[[i]],stop_trig)
     }
   }
  }#end of "if processed"
  return(tmp)
}
##############Function used in generating order##########################
cut_off= function(num){
  max(min(num, 1), -1)
}
macd_idx=function(MACD){
  A =apply(MACD, 1, cut_off)
  A =xts(A, order.by= index(MACD) )
  colnames(A)='hist'
  return(A)
}
sig2Buy= function(pctB, macd_id){ #pctB and macd_id are NUMBERS!!!!!!!!
  return(pctB < macd_id*0.3)
}
sig2Sell= function(pctB, macd_id){#pctB and macd_id are NUMBERS!!!!!!!!
  thres = 1 + macd_id*0.3
  return(pctB > thres)
}
sig2Stop= function(macd_id, stop_thres){#All Numbers!!1
  return((stop_thres/0.02)*(0.02*macd_id+0.03)*(2^macd_id))
  #return(macd_id*0.015+0.02)
}
#########################################################################

BB_Strategy_Sketch <- function(dataXts, ...){ 
  tmp = BB_Strategy_Generate(dataXts, ...)
  tmp$Dn[which(tmp$Dn==0)]=NA
  if( length(tmp$Dn[which(!is.na(tmp$Dn))] ) !=0 ){
    show(
      addPoints(  y=as.vector(tmp$Dn[which(!is.na(tmp$Dn))]), x=which( !is.na(tmp$Dn)), pch='B', col='red')
      )}
  tmp$Up[which(tmp$Up==0)]=NA
  if( length(tmp$Up[which(!is.na(tmp$Up))] ) !=0 ){
    show(
      addPoints(  y=as.vector(tmp$Up[which(!is.na(tmp$Up))]), x=which( !is.na(tmp$Up)), pch='S', col='blue')
      )}
}






################Naive Return, should be good for strategy generaed by any indicator
BB_naive_return <- function(dataXts, ...){
  tmp = BB_Strategy_Generate(dataXts, processed= TRUE,  ...) 
  lll = length( index(tmp) )
  ll  = lll-1
  M =cbind(as.vector(tmp[,4][-lll]), as.vector(tmp$holding[-1]), as.vector(tmp$holding[-lll]))
  M[,2]= M[,1]*M[,2]; M[,3]= M[,1]*M[,3]
  B= M[,2]; B= B[-ll]; B= c(0, B); M[,2]= B
  M[which(M[,2]==0),2]=NA; M[which(M[,3]==0),3]=NA
  M[,1]= (M[,3]-M[,2]) / M[,2]
  B= M[,1]; B[which(is.na(B))]=0; M[,1]=B;d_ret=c(0, M[,1])+1
  result = rep(1, lll); for(i in 2: lll){result[i]= result[i-1]*d_ret[i]}
  tmp$result= xts(result, order.by= index(tmp))
  return(tmp)
}


BB_return_sketch <- function(dataXts,...){
  tmp = BB_naive_return(dataXts,...)
  show(addTA(tmp$Result))
}



# library('quantmod')
# setwd('~/Desktop/BootCamp/My_App/proj2')
# data = getSymbols('XOM',src="yahoo",from=as.Date('2012-01-01'),to=as.Date('2015-07-01'),auto.assign = FALSE)  
#pro= TRUE
#m1=TRUE
#m2=12
#m3=26
#m4=9
#st=0.02
#ds=90
#tmp = BB_Strategy_Generate(data, n=14, sd=2, day_stop=ds, processed=pro, stop_trig=st,
 #                   modi_macd = m1, macd_fast=m2, macd_slow=m3, macd_signal=m4)
#source('test.R')
#tmp1 = BB_Strategy_Generate1(data, n=14, sd=2, day_stop=ds, processed=pro, stop_trig=st,
 #                          modi_macd = m1, macd_fast=m2, macd_slow=m3, macd_signal=m4)
#macd = MACD(data[,4])
#macd$hist = macd$macd - macd$signal
#macd$hist[which(  is.na( macd$hist  )   )]=0
#tmpp = BB_Strategy_Generate(data, n=14, sd=2, day_stop=40, processed=FALSE, modi_macd = FALSE, stop_trig=NA)
#print(cbind(tmpp$Dn, tmp$Dn, tmp$Up,tmpp$Up, tmp$holding))
#trade = cbind(tmp[,4], tmp$pctB, tmp$Up, tmp$Dn, tmp$holding, tmp$macd)
#chartSeries(data, theme= chartTheme('white'), TA=NULL, type='line')
#BB_Strategy_Sketch(data, n=14, sd=2, day_stop=ds, processed=pro, stop_trig=st,
#modi_macd = m1, macd_fast=m2, macd_slow=m3, macd_signal=m4)

#chartSeries(data, theme= chartTheme('white'), TA=NULL, type='line')
#tmp1$Buy[which(tmp1$Buy==0)]=NA
#if( length(tmp1$Buy[which(!is.na(tmp1$Buy))] ) !=0 ){
#  show(
#    addPoints(  y=as.vector(tmp1$Buy[which(!is.na(tmp1$Buy))]), x=which( !is.na(tmp1$Buy)), pch='B', col='red')
#  )}
#tmp1$Sell[which(tmp1$Sell==0)]=NA
#if( length(tmp1$Sell[which(!is.na(tmp1$Sell))] ) !=0 ){
#  show(
#    addPoints(  y=as.vector(tmp1$Sell[which(!is.na(tmp1$Sell))]), x=which( !is.na(tmp1$Sell)), pch='S', col='blue')
#  )}

#BB_return_sketch(data, n=14, sd=2, day_stop=ds, stop_trig=st, 
 #               modi_macd = m1, macd_fast=m2, macd_slow=m3, macd_signal=m4)
#show(addMACD(fast=m2, slow=m3, signal=m4))
#summary(tmp$pctB)