BB_Strategy_Generate<- function(dataXts, n=14, sd=2, day_stop=30, processed=FALSE
        , modi_macd = FALSE, macd_fast=12, macd_slow=26, macd_signal=9, stop_trig=0, stop_profit=TRUE){
  
  ##################Checking Valindility#############################################
  if(day_stop<=0){stop("The maximum holding days has to be positive")}
  if(modi_macd & stop_trig == 0){stop("Specify stop sell trig for modifying with MACD")}
  if(stop_trig==0){stop_trig = NA}
  ###################################################################################

  HLC= dataXts[,6]
  process = merge( HLC, BBands(HLC,n=n, sd=sd)$pctB)
  tmp = MACD(HLC[,1], nFast=macd_fast, nSlow=macd_slow, nSig=macd_signal); 
  tmp$hist = tmp$macd - tmp$signal;
  tmp$hist[which(  is.na( tmp$hist  )   )]=0; process$macd = macd_idx1(tmp$hist)
  if(!modi_macd){process$macd= NA}
  process$Buy=0
  process$Sell=0
  
  if(processed & modi_macd){
    start = max((macd_slow + macd_signal-1), n)
  }
  else if(processed) start= n
  else start = 1
  end   = length(index(process))
  
  process$holding= FALSE
  cost = process[[start,1]]
  days = 0
  for(i in start: end){
    pctB = process$pctB[[i]]
    macd_id= process$macd[[i]]
    if(!process$holding[[i]]){
      Sell = FALSE;
      Buy  = sig2Buy1(pctB, macd_id)
      ############pctB is NA at the begginning; 
      ##Same thing doesn't need in Sell because no holding before Buy == TRUE!!!!
      if(is.na(Buy)){Buy=FALSE}
      ############
      if(Buy){
        cost = process[[i,1]]; days= days+1; process$Buy[[i]]= process[[i,1]]
        if(i<end){process$holding[[i+1]]=TRUE}
      }
    }
    else{
     Buy =FALSE;
     Sell_bb = sig2Sell1(pctB, macd_id)
     current = process[[i,1]]
     Sell_stop= sig2Stop(current=current, cost=cost, stop_trig=stop_trig, macd_id= macd_id, days=days, day_stop=day_stop)
     if(stop_profit){ Sell= Sell_bb | Sell_stop}
     else{Sell = Sell_stop}

     if(Sell){
       process$Sell[[i]]= process[[i,1]]; days=0; cost=0
     }
     else if(!Sell){
       days= days+1; cost= max(process[[i,1]], cost); if(i< end){  process$holding[[i+1]]=TRUE }
     }
    }
  }
  return(process)
}

############## Function used in generating order ##########################
cut_off1= function(num){
  max(min(num, 1), -1)
}
macd_idx1=function(MACD, modi_macd){
  A =apply(MACD, 1, cut_off1)
  A =xts(A, order.by= index(MACD) )
  colnames(A)='hist'
  return(A)
}
# With BB and MACD at a particular day, the following function generate buying signal
sig2Buy1= function(pctB, macd_id){
  if( is.na(macd_id ) ) {return(pctB < 0)}
  else {return(pctB < macd_id*0.3)}
}
# With BB and MACD at a particular day, the following function generate selling signal
sig2Sell1= function(pctB, macd_id){
  if( is.na(macd_id) ){return(pctB>1)}
  else {
    thres = 1 + macd_id*0.3
    return(pctB > thres)}
}
## combine all stopping rule
sig2Stop= function(current, cost, stop_trig, macd_id, days, day_stop){
  return(sig2Stop1(current, cost, stop_trig, macd_id) | sig2Stop2(days, day_stop))
}
## Stopping rule 1 ####
sig2Stop1=function(current, cost, stop_trig, macd_id){
  change = (current-cost)/cost
  if( is.na(stop_trig) ){ return(FALSE) }
  else if( is.na(macd_id) ){ss = -stop_trig }
  else { ss= -((stop_trig/0.02)*(0.02*macd_id+0.03)*(2^macd_id))}
  return( change < ss  )
}
## Stopping rule 2 ####
sig2Stop2=function(days, day_stop){
  return(days >= day_stop)
}