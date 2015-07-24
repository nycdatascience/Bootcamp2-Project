# Pulling in raw data and creating data.frames for each category:
# outlays, receipts and budget authority.

r_raw <- read.csv('data/receipts.csv', colClasses='character')
r_nums <- as.data.frame(sapply(r_raw[13:72], FUN = function(x) as.numeric(gsub(",", "", x))*1000))
receipts <- cbind(r_raw[1:12], r_nums)

r_years = grep('^X[1-2][0-9][0-9][0-9]',names(receipts))
r_indices = grep('.name$|.Budget$',names(receipts))

o_raw <- read.csv('data/outlays.csv', colClasses='character')
o_nums <- as.data.frame(sapply(o_raw[13:72], FUN = function(x) as.numeric(gsub(",", "", x))*1000))
outlays <- cbind(o_raw[1:12], o_nums)

o_years = grep('^X[1-2][0-9][0-9][0-9]',names(outlays))
o_indices = grep('.Name$|.Budget$|.split$|ory$',names(outlays))

b_raw <- read.csv('data/budauth.csv', colClasses='character')
b_nums <- as.data.frame(sapply(b_raw[12:57], FUN = function(x) as.numeric(gsub(",", "", x))*1000))
budauth <- cbind(b_raw[1:11], b_nums)

b_years = grep('^X[1-2][0-9][0-9][0-9]',names(budauth))
b_indices = grep('.Name|.Budget|.Title|.Category',names(budauth))

# Adjusting for inflation so that each year is shown in 2015 USD amounts.
i_rate = read.csv('data/inflation.csv', colClasses='numeric')
i_rate$add1 = i_rate$Inflation.Rate + 1
mult = function(x) {
  for(i in 1:(length(x)-1)) {
    x[i+1] = x[i+1]*x[i]
  }
  return(x)
}
i_rate$adjuster = mult(i_rate$add1)
new = data.frame(c(2020,2019,2018,2017,2016),c(0,0,0,0,0), c(1,1,1,1,1), c(1,1,1,1,1))
names(new) = names(i_rate)
i_rate = rbind(new,i_rate)