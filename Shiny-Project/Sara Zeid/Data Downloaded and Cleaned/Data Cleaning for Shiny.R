#DATA FROM:
# http://data.worldbank.org/indicator/SI.POV.GINI
# http://data.worldbank.org/indicator/SP.POP.TOTL
# http://data.worldbank.org/indicator/SP.POP.GROW
# http://data.worldbank.org/indicator/NY.GDP.PCAP.CD
# http://data.worldbank.org/about/country-and-lending-groups

library(reshape2)
library(plyr)
library(openxlsx)
library(ggplot2)

#GDP PER CAPITA DATA PREP (WORLD BANK)

gdpcap <- read.csv("gdppcap.csv", header = T, stringsAsFactors = F, skip = 4, check.names=F)

gdpcap2 <- melt(gdpcap)

gdpcap2 <- rename(gdpcap2, c("variable" = "year", "value" = "gdpcap"))

gdpcap2 <- gdpcap2[-c(3:5)]

#POPULATION GROWTH DATA PREP (WORLD BANK)

popg <- read.csv("popgrowth.csv", header = T, stringsAsFactors = F, skip = 4, check.names=F)

popg2 <- melt(popg)

popg2 <- rename(popg2, c("variable" = "year", "value" = "popgrowth"))

popg2 <- popg2[-c(3:5)]

popu <- read.csv("totalpop.csv", header = T, stringsAsFactors = F, skip = 4, check.names=F)

popu2 <- melt(popu)

popu2 <- rename(popu2, c("variable" = "year", "value" = "population"))

popu2 <- popu2[-c(3:5)]

#WORLD BANK GROUPING VARIABLES: REGION AND INCOME GROUP

groupingvar <- read.xlsx("CLASS.xlsx", startRow = 5, colNames = T, cols = c(2:7), rows = 5:221)

groupingvar <- rename(groupingvar, c("Economy" = "Country Name", "Code" = "Country Code"))

#MERGE ALL: GDP PER CAPITA, POPULATION GROWTH, GROUPING VARIABLES

all <- merge(gdpcap2, popg2, by=c("Country Name", "Country Code", "year"))

all1 <- merge(all, popu2, by=c("Country Name", "Country Code", "year"))

all2 <- merge(all1, groupingvar, by=c("Country Name", "Country Code"))

all2$year <- as.integer(as.character(all2$year))

all2$'Country Name' <- as.factor(all2$'Country Name')

#GROUPING COUNTRIES BY REGION AND INCOME GROUP

region <- ddply(all2, c("Region", "year"), summarise, gdpavg=mean(gdpcap, na.rm=TRUE), 
                popavg=mean(popgrowth, na.rm=TRUE), sumpop=sum(population, na.rm=TRUE))

income <- ddply(all2, c("Income.group", "year"), summarise, gdpavg=mean(gdpcap, na.rm=TRUE), 
                popavg=mean(popgrowth, na.rm=TRUE), sumpop=sum(population, na.rm=TRUE))

saveRDS(region, "region.RDS")
saveRDS(income, "income.RDS")

#PRELIMINARY VISUAL EXPLORATION

#region & size gdpavg

ggplot(region, aes(x = year, y = popavg, size = gdpavg, color=Region)) + 
  geom_point()+ylim(0, 4.5)+scale_size_continuous(range = c(2,12))

#region & size popavg

ggplot(region, aes(x = year, y = gdpavg, size = popavg, color=Region)) + 
  geom_point()+scale_size_continuous(range = c(2,6))

#income group & size gdpavg

ggplot(income, aes(x = year, y = popavg, size = gdpavg, color=Income.group)) + 
  geom_point()+ylim(0, 4.5)+scale_size_continuous(range = c(2,12))

#income group & popavg

ggplot(income, aes(x = year, y = gdpavg, size = popavg, color=Income.group)) + 
  geom_point()+scale_size_continuous(range = c(2,6))

#Without North America, Europe, High Income (both OECD and nonOECD)

pregion <- all2[all2$Region==c("South Asia", "Middle East & North Africa", 
                                  "East Asia & Pacific", "Sub-Saharan Africa", 
                                  "Latin America & Caribbean") & 
                     all2$Income.group==c("Low income", "Lower middle income", 
                                          "Upper middle income"),]

devreg <- ddply(pregion, c("Region", "year"), summarise, 
                   gdpavg=mean(gdpcap, na.rm=TRUE), 
                   popavg=mean(popgrowth, na.rm=TRUE),
                sumpop=sum(population, na.rm=TRUE))

devinc <- ddply(pregion, c("Income.group", "year"), summarise, 
                   gdpavg=mean(gdpcap, na.rm=TRUE), 
                   popavg=mean(popgrowth, na.rm=TRUE),
                sumpop=sum(population, na.rm=TRUE))

#region & size gdpavg

ggplot(devreg, aes(x = year, y = popavg, size = gdpavg, color=Region)) + 
  geom_point()+ylim(0, 4.5)+scale_size_continuous(range = c(2,12))

#region & size popavg

ggplot(devreg, aes(x = year, y = gdpavg, size = popavg, color=Region)) + 
  geom_point()+scale_size_continuous(range = c(2,6))

#income group & size gdpavg

ggplot(devinc, aes(x = year, y = popavg, size = gdpavg, color=Income.group)) + 
  geom_point()+ylim(0, 4.5)+scale_size_continuous(range = c(2,12))

#income group & popavg

ggplot(devinc, aes(x = year, y = gdpavg, size = popavg, color=Income.group)) + 
  geom_point()+scale_size_continuous(range = c(2,6))

#ADDING COUNTRIES FOR WHICH THERE'S A GINI COEF 2002-2012 TO EXAMINE THE
#RELATIONSHIP BETWEEN GDP PER CAPITA, POPULATION, AND INEQuALIty

gini <- read.csv("gini.csv", header = T, stringsAsFactors = F, skip = 4, check.names=F)
gini2 <- gini[,colSums(is.na(gini))<nrow(gini)]
gini3 <- gini2[-c(2, 3:21)]
gini4 <- gini3[! rowSums(is.na(gini3)) >3  , ]
gini5 <- melt(gini4)
gini5 <- rename(gini5, c("variable" = "year", "value" = "gini"))
ginico <- merge(all2, gini5, by=c("Country Name", "year"))
ginico <- ginico[-c(3)]
names(ginico)[1] <- "Country"
ginico <- ginico[,c(1,6,7,2,3,4,5,8)]

ggplot(ginico, aes(x = year, y = gini, size = gdpcap, color=ginico$'Country Name')) + 
  geom_point() + scale_size_continuous(range = c(2,6))

saveRDS(ginico, "gini.RDS")

#googleVis suggestion!

all2 <- all2[-2]

blah <- gvisMotionChart(all2, idvar = "Country Name", timevar = "year", xvar = "gdpcap",
                        yvar = "popgrowth", colorvar = "Income.group", sizevar = "population",
                        options = list(showChartButtons=TRUE))
plot(blah)

saveRDS(all2, "regionandincome.RDS")


#FOR ADDING SHINY TABPANEL WITH WORLD BANK GROUPING INFO:

groupingvar2 <- read.xlsx("CLASS.xlsx", startRow = 5, colNames = T, cols = c(2:7), rows = 5:221)

groupingvar2 <- plyr::rename(groupingvar2, c("Economy" = "Country Name", "Code" = "Country Code", 
                                           "Income.group" = "Income Group"))
groupingvar2 <- groupingvar2[-2]

saveRDS(groupingvar2, "grouping.RDS")




