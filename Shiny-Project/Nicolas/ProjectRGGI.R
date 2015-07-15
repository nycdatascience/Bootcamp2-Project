#First we import the 2 files
#Source: http://www.epa.gov/ampd/
emidata = read.csv("Data/emission_07-03-2015.csv")
facildata = read.csv("Data/facility_07-03-2015.csv")
library(dplyr)
emidata = tbl_df(emidata)
facildata = tbl_df(facildata)
#remove all doubles by using distinct ORIS
facildata = facildata %>% distinct(Facility.ID..ORISPL.)
#Then we agregate them in 1 table
sumdata=left_join(emidata,facildata,by = c("Facility.ID..ORISPL."))
#Lets clean this table
sumdata=mutate(sumdata, Period = as.Date(paste(sumdata$Year.x, sumdata$Month, 1, sep = "-")))
sumdata=select(sumdata,-c(Month,Year.x,Year.y,X.y,State.y,Facility.Name.y))
sumdata=rename(sumdata,State=State.x,Facility.Name=Facility.Name.x,Facility.ORIS.ID=Facility.ID..ORISPL.,
               SO2.Tons = SO2..tons.,NOx.Tons = NOx..tons.,CO2.Short.Tons = CO2..short.tons.,
               GrossLoad.MWh=Gross.Load..MW.h.,Representative.Primary=Representative..Primary.,
               FuelType.Primary=Fuel.Type..Primary.)
#Lets add an effciency metric of the plant
sumdata$Efficiency.CO2sTons.MWh = sumdata$CO2.Short.Tons/sumdata$GrossLoad.MWh

sumdata=filter(sumdata,Period< "2015-04-01")
sumdata= filter(sumdata,is.finite(Efficiency.CO2sTons.MWh))
sumdata= filter(sumdata,Efficiency.CO2sTons.MWh<10*mean(Efficiency.CO2sTons.MWh))

sumdata =within(sumdata,{
  Efficiency.CO2sTons.MWh=ifelse(GrossLoad.MWh<5000,0,Efficiency.CO2sTons.MWh)
})

save(sumdata,file="sumdata.RData")
write.csv(sumdata, file="sumdata.csv")

groupeto1=group_by(sumdata,Facility.Name,FuelType.Primary)
sumdatasimpl=summarise(groupeto1,SO2.Tons=mean(SO2.Tons,na.rm=T),CO2.Short.Tons=mean(CO2.Short.Tons,na.rm=T),NOx.Tons=mean(NOx.Tons,na.rm=T),GrossLoad.MWh=sum(GrossLoad.MWh,na.rm=T),NetGen.MWh=sum(NetGen.MWh,na.rm=T),Facility.ORIS.ID=mean(Facility.ORIS.ID),Facility.Latitude=mean(Facility.Latitude),Facility.Longitude=mean(Facility.Longitude))
sumdatasimpl=filter(sumdatasimpl,Facility.Longitude>-80)
sumdatasimpl[sumdatasimpl$GrossLoad.MWh==0,6]=NA

save(sumdatasimpl,file="sumdatasimpl.RData")
write.csv(sumdatasimpl, file="sumdatasimpl.csv")


#----2nd data set

library(openxlsx)
EIA923 = read.xlsx("Data/EIA923.xlsx",startRow=6,colNames = TRUE)
EIA923 = tbl_df(EIA923)

EIA923$Netgen.January = as.numeric(EIA923$Netgen.January)
EIA923$Netgen.February = as.numeric(EIA923$Netgen.February)
EIA923$Netgen.March = as.numeric(EIA923$Netgen.March)

byPlant = group_by(EIA923,Plant.Id)

EIA15 = summarise(byPlant,NetGen.Jan15=sum(Netgen.January,na.rm=TRUE))
EIA$NetGen.Feb15 = summarise(byPlant,NetGen.Feb15=sum(Netgen.February,na.rm=TRUE))$NetGen.Feb15
EIA$NetGen.Mar15 = summarise(byPlant,NetGen.Mar15=sum(Netgen.March,na.rm=TRUE))$NetGen.Mar15


----
library(openxlsx)
EIA923 = read.xlsx("Data/EIA923_2015.xlsx",startRow=6,colNames = TRUE)

View(EIA923)

EIA923 = tbl_df(EIA923)
EIA923$Netgen.January = as.numeric(EIA923$Netgen.January)
EIA923$Netgen.February = as.numeric(EIA923$Netgen.February)
EIA923$Netgen.March = as.numeric(EIA923$Netgen.March)
EIA923$Netgen_Apr = as.numeric(EIA923$Netgen_Apr)
EIA923$Netgen_May = as.numeric(EIA923$Netgen_May)
EIA923$Netgen_Jun = as.numeric(EIA923$Netgen_Jun)
EIA923$Netgen_Jul = as.numeric(EIA923$Netgen_Jul)
EIA923$Netgen_Aug = as.numeric(EIA923$Netgen_Aug)
EIA923$Netgen_Sep = as.numeric(EIA923$Netgen_Sep)
EIA923$Netgen_Oct = as.numeric(EIA923$Netgen_Oct)
EIA923$Netgen_Nov = as.numeric(EIA923$Netgen_Nov)
EIA923$Netgen_Dec = as.numeric(EIA923$Netgen_Dec)



byPlant = group_by(EIA923,Plant.Id)

EIA15 = summarise(byPlant,NetGen.Jan15=sum(Netgen.January,na.rm=TRUE))
EIA15$NetGen.Feb15 = summarise(byPlant,NetGen.Feb15=sum(Netgen.February,na.rm=TRUE))$NetGen.Feb15
EIA15$NetGen.Mar15 = summarise(byPlant,NetGen.Mar15=sum(Netgen.March,na.rm=TRUE))$NetGen.Mar15
EIA15$NetGen.Apr15 = summarise(byPlant,NetGen.Apr15=sum(Netgen_Apr,na.rm=TRUE))$NetGen.Apr15
EIA15$NetGen.May15 = summarise(byPlant,NetGen.May15=sum(Netgen_May,na.rm=TRUE))$NetGen.May15
EIA15$NetGen.Jun15 = summarise(byPlant,NetGen.Jun15=sum(Netgen_Jun,na.rm=TRUE))$NetGen.Jun15
EIA15$NetGen.Jul15 = summarise(byPlant,NetGen.Jul15=sum(Netgen_Jul,na.rm=TRUE))$NetGen.Jul15
EIA15$NetGen.Aug15 = summarise(byPlant,NetGen.Aug15=sum(Netgen_Aug,na.rm=TRUE))$NetGen.Aug15
EIA15$NetGen.Sep15 = summarise(byPlant,NetGen.Sep15=sum(Netgen_Sep,na.rm=TRUE))$NetGen.Sep15
EIA15$NetGen.Oct15 = summarise(byPlant,NetGen.Oct15=sum(Netgen_Oct,na.rm=TRUE))$NetGen.Oct15
EIA15$NetGen.Nov15 = summarise(byPlant,NetGen.Nov15=sum(Netgen_Nov,na.rm=TRUE))$NetGen.Nov15
EIA15$NetGen.Dec15 = summarise(byPlant,NetGen.Dec15=sum(Netgen_Dec,na.rm=TRUE))$NetGen.Dec15

write.csv(EIA15, file="EIA15.csv")

----
  
EIA923 = read.xlsx("Data/EIA923_2009.xlsx",startRow=7,colNames = TRUE)

View(EIA923)

EIA923 = tbl_df(EIA923)
EIA923$NETGEN_JAN = as.numeric(EIA923$NETGEN_JAN)
EIA923$NETGEN_FEB = as.numeric(EIA923$NETGEN_FEB)
EIA923$NETGEN_MAR = as.numeric(EIA923$NETGEN_MAR)
EIA923$NETGEN_APR = as.numeric(EIA923$NETGEN_APR)
EIA923$NETGEN_MAY = as.numeric(EIA923$NETGEN_MAY)
EIA923$NETGEN_JUN = as.numeric(EIA923$NETGEN_JUN)
EIA923$NETGEN_JUL = as.numeric(EIA923$NETGEN_JUL)
EIA923$NETGEN_AUG = as.numeric(EIA923$NETGEN_AUG)
EIA923$NETGEN_SEP = as.numeric(EIA923$NETGEN_SEP)
EIA923$NETGEN_OCT = as.numeric(EIA923$NETGEN_OCT)
EIA923$NETGEN_NOV = as.numeric(EIA923$NETGEN_NOV)
EIA923$NETGEN_DEC = as.numeric(EIA923$NETGEN_DEC)



byPlant = group_by(EIA923,Plant.ID)

EIA09 = summarise(byPlant,NetGen.Jan09=sum(NETGEN_JAN,na.rm=TRUE))
EIA09$NetGen.Feb09 = summarise(byPlant,NetGen.Feb09=sum(NETGEN_FEB,na.rm=TRUE))$NetGen.Feb09
EIA09$NetGen.Mar09 = summarise(byPlant,NetGen.Mar09=sum(NETGEN_MAR,na.rm=TRUE))$NetGen.Mar09
EIA09$NetGen.Apr09 = summarise(byPlant,NetGen.Apr09=sum(NETGEN_APR,na.rm=TRUE))$NetGen.Apr09
EIA09$NetGen.May09 = summarise(byPlant,NetGen.May09=sum(NETGEN_MAY,na.rm=TRUE))$NetGen.May09
EIA09$NetGen.Jun09 = summarise(byPlant,NetGen.Jun09=sum(NETGEN_JUN,na.rm=TRUE))$NetGen.Jun09
EIA09$NetGen.Jul09 = summarise(byPlant,NetGen.Jul09=sum(NETGEN_JUL,na.rm=TRUE))$NetGen.Jul09
EIA09$NetGen.Aug09 = summarise(byPlant,NetGen.Aug09=sum(NETGEN_AUG,na.rm=TRUE))$NetGen.Aug09
EIA09$NetGen.Sep09 = summarise(byPlant,NetGen.Sep09=sum(NETGEN_SEP,na.rm=TRUE))$NetGen.Sep09
EIA09$NetGen.Oct09 = summarise(byPlant,NetGen.Oct09=sum(NETGEN_OCT,na.rm=TRUE))$NetGen.Oct09
EIA09$NetGen.Nov09 = summarise(byPlant,NetGen.Nov09=sum(NETGEN_NOV,na.rm=TRUE))$NetGen.Nov09
EIA09$NetGen.Dec09 = summarise(byPlant,NetGen.Dec09=sum(NETGEN_DEC,na.rm=TRUE))$NetGen.Dec09

EIA09=rename(EIA09,Plant.Id=Plant.ID)


write.csv(EIA10, file="EIA10.csv")

#----Add all EIA years together

EIA0910 = merge(EIA09,EIA10,by="Plant.Id",all=T)
EIA0911 = merge(EIA0910,EIA11,by="Plant.Id",all=T)
EIA0912 = merge(EIA0911,EIA12,by="Plant.Id",all=T)
EIA0913 = merge(EIA0912,EIA13,by="Plant.Id",all=T)
EIA0914 = merge(EIA0913,EIA14,by="Plant.Id",all=T)
EIA0915 = merge(EIA0914,EIA15,by="Plant.Id",all=T)


save(EIA0915,file="EIA0915.RData")
write.csv(toto, file="toto.csv")

#----Add coordinates of all power plants
require(xlsx)

plantdata = read.xlsx("Data/PowerPlants_Y2013.xlsx",startRow=2,colNames = TRUE)
plantdata
View(plantdata)
write.csv(plantdata, file="plantdata.csv")
