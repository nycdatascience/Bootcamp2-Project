library(dplyr)
library(rgdal)
library(RSQLite)
result = read.csv('data/result.csv')

# listings <- read.csv('data/listings.csv')
# listings2 <- tbl_df(read.csv('data/listings_2.csv'))
# 
# reviews <- read.csv('data/reviews.csv')
# reviews2 <- read.csv('data/reviewsdetail.csv')
# 
# neighbourhoods <- read.csv('data/neighbourhoods.csv')
# 
# geo <- readOGR(dsn='data/neighbourhoods.geojson', layer="OGRGeoJSON")
# 
# calendar <- read.csv('data/calendar.csv')
# 
# calendar <- tbl_df(calendar)
# 
# sum(calendar$available=='t')
# 
# 
# temp <- group_by(calendar, listing_id) %>%
#   summarise(n=n())
# 
# 
con <- dbConnect(RSQLite::SQLite(), 'Airbnb.db')
apartment <- dbReadTable(con, 'listing')

#dbDisconnect(con)
# 
# temp <- group_by(reviews2, listing_id) %>% summarise(count=n())


