library(dplyr)
library(ggplot2)
library(maps)
library(geosphere)

# load data set
flights = read.csv("flights.csv")

# join carrier names
carriers = read.csv("carriers.csv", col.names = c('UNIQUE_CARRIER', 'CARRIER_NAME'))
flights = inner_join(flights, carriers, by = "UNIQUE_CARRIER")

# join cancellation codes
cancellation = read.csv("cancellation.csv", col.names = c('CANCELLATION_CODE', 'CANCELLATION_DESC'))
flights = left_join(flights, cancellation, by = "CANCELLATION_CODE")

# change dates to correct format
flights$FL_DATE = as.Date(flights$FL_DATE)
temp = sprintf("%04d", flights$CRS_DEP_TIME)
flights$CRS_DEP_TIME = format(strptime(temp, format="%H%M"), format = "%H:%M")

# arrange data by top origins/destinations
top_origin = group_by(flights, ORIGIN_CITY_NAME) %>% summarise(count = n()) %>% arrange(desc(count))
top_dest = group_by(flights, DEST_CITY_NAME) %>% summarise(count = n()) %>% arrange(desc(count))
origin = as.data.frame(top_origin$ORIGIN_CITY_NAME[c(1:29, 31:45, 47:49)])
dest = as.data.frame(top_dest$DEST_CITY_NAME[c(1:29, 31:45, 47:49)])
colnames(origin) = 'CITY_NAME'; colnames(dest) = 'CITY_NAME'

# sort alphabetically
origin$CITY_NAME = sort(origin$CITY_NAME)
dest$CITY_NAME = sort(dest$CITY_NAME)

# load longitude/latitude coordinates and merge with origins/destinations
coordinates = read.csv('coordinates.csv')
origin = inner_join(origin, coordinates, by = 'CITY_NAME')
dest = inner_join(dest, coordinates, by = 'CITY_NAME')




# time selections to filter by departure time
times = c("00:00", "00:30", "01:00", "01:30", "02:00", "02:30",
          "03:00", "03:30", "04:00", "04:30", "05:00", "05:30",
          "06:00", "06:30", "07:00", "07:30", "08:00", "08:30",
          "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
          "12:00", "12:30", "13:00", "13:30", "14:00", "14:30",
          "15:00", "15:30", "16:00", "16:30", "17:00", "17:30",
          "18:00", "18:30", "19:00", "19:30", "20:00", "20:30",
          "21:00", "21:30", "22:00", "22:30", "23:00", "23:30",
          "24:00")

# map plotting function
map_plot = function(from, to){
    # get longitude/latitude at origin/destination
    lat_o <- origin$LAT[origin$CITY_NAME == from]
    long_o <- origin$LONG[origin$CITY_NAME == from]
    lat_d <- dest$LAT[origin$CITY_NAME == to]
    long_d <- dest$LONG[origin$CITY_NAME == to]
    
    # create map
    xlim = c(-125, -62.5)
    map('state', col = '#f2f2f2', fill = T, xlim = xlim, boundary = T, lty = 0)
    inter <- gcIntermediate(c(long_o, lat_o), c(long_d, lat_d), n=50, addStartEnd=TRUE)
    lines(inter, col = 'red', lwd = 2)
    text(long_o, lat_o, from, col = 'blue', adj = c(-0.1, 1.25))
    text(long_d, lat_d, to, col = 'blue', adj = c(-0.1, 1.25))
    points(long_d, lat_d, cex = 1.5)
    points(long_o, lat_o, cex = 1.5)
}

