library(RSQLite)
library(DBI)
source("helpers.R")
library(dplyr)
library(tidyr)

dbPath <- "nytimes.db"
tbName <- "nytevent"

nyclatlng <- "40.7127,-74.0059"
latRange <- c(40.5, 40.9)
lngRange <- c(-74.2, -73.7)

api_key <- "api-key=4afa5e239fc8c4847a7f7fc0b537d285:2:72422982"
base_url <- "http://api.nytimes.com/svc/events/v2/listings.json?"

events <- fromDB(dbPath, tbName)
days <- dayFreq(events)

event.day <- eventByDay(events, days)
