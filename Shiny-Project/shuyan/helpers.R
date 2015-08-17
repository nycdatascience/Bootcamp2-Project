library(curl)
library(jsonlite)
library(RSQLite)
library(DBI)
library(dplyr)

retrieveEvent <- function(url) {
    # raw data from NYT EVENT LISTINGS API
    event_raw <- fromJSON(txt = url)$results
    # NYC: 40.7127° N, 74.0059° W
    if(length(event_raw)==0) {
        return(NULL)
    }
    picks <- as.numeric(event_raw$geocode_latitude) > latRange[1] & 
        as.numeric(event_raw$geocode_latitude) < latRange[2] &
        as.numeric(event_raw$geocode_longitude) > lngRange[1] &
        as.numeric(event_raw$geocode_longitude) < lngRange[2]
    event_raw <- event_raw[picks, ]
    if(length(event_raw)==0) {
        return(NULL)
    }
    # retrive column from dataframe, return NA vector if not found
    getCol <- function(column) {
        if(column %in% colnames(event_raw)) {
            return(event_raw[, column])
        } else {
            return(rep(NA, nrow(event_raw)))
        }
    }
    # select features from raw data
    events <- data.frame(event_id          = getCol("event_id"),
                         event_schedule_id = getCol("event_schedule_id"),
                         event_name        = apply(event_raw, 1, function(x) gsub("\\s+$", "", 
                                                                                  gsub("[‘’(\r)(\n)]", "", 
                                                                                       gsub(paste0("^", x["venue_name"],": "), 
                                                                                            "", x["event_name"])))),
                         event_detail_url  = getCol("event_detail_url"),
                         venue_name        = getCol("venue_name"),
                         venue_detail_url  = getCol("venue_detail_url"),
                         geocode_latitude  = getCol("geocode_latitude"),
                         geocode_longitude = getCol("geocode_longitude"),
                         borough           = getCol("borough"),
                         neighborhood      = getCol("neighborhood"),
                         street_address    = getCol("street_address"),
                         city              = getCol("city"),
                         state             = getCol("state"),
                         category          = getCol("category"),
                         recur_days        = sapply(getCol("recur_days"), function(x) paste0(x, collapse=" ")),
                         times_pick        = getCol("times_pick"),
                         kid_friendly      = getCol("kid_friendly"),
                         free              = getCol("free")
    )
    return(events)
}


formatEvent <- function(event) {
    # check empty event
    if(length(event)) {
        # get event info
        event_temp <- data.frame(event_name = event$event_name, event_detail_url = event$event_detail_url)
        # combine event_name and event_url
        event_temp$event_name <- apply(event_temp, 1, 
                                       function(x) paste0("<a href=\"", 
                                                          x["event_detail_url"], "\" target=\"_blank\">", 
                                                          x["event_name"], "</a>"))
        # get venue info
        venue <- unique(event[,c("venue_name", "venue_detail_url",
                                 "geocode_latitude", "geocode_longitude")])
        
        venue$LatLong <- paste(venue$geocode_latitude, venue$geocode_longitude, sep=":")
        venue$venue_name <- apply(venue, 1, function(x) 
            ifelse(is.na(x["venue_detail_url"]), 
                   x["venue_name"], 
                   paste0("<a href=\"", 
                          x["venue_detail_url"], "\" target=\"_blank\">", x["venue_name"], "</a>")))
        # add events to venue
        venue$event_name <- apply(venue, 1,
                                  function(x) paste(event_temp[event$geocode_latitude==x["geocode_latitude"] &
                                                              event$geocode_longitude==x["geocode_longitude"],]$event_name,
                                                    collapse="<BR>"))
        # generate output info
        venue$info <- paste(paste0("<strong>", venue$venue_name, ":</strong>"), venue$event_name, sep="<br>")
        venue$info <- sapply(venue$info, function(x) gsub("<strong>NA:</strong><br>", "", x))
        return(venue)
    } else {
        return(NULL)
#         return(data.frame(LatLong="New York, NY", 
#                           info="<strong>Oops, no events were found!</strong>"))
    }
}


fromDB <- function(dbPath, tbName) {
    con <- dbConnect(RSQLite::SQLite(), dbPath)
    # retrive data from database
    dataInDB <- dbReadTable(con, tbName)
    dbDisconnect(con)
    print(paste0(nrow(dataInDB), " rows retrieved from ", tbName))
    return(dataInDB)
}

toDB <- function(dbPath, tbName, dataToWrite) {
    # check empty data
    if(length(dataToWrite)) {
        con <- dbConnect(RSQLite::SQLite(), dbPath)
        # check data in database
        if(dbExistsTable(con, tbName)) {
            dataInDB <- dbReadTable(con, tbName)
            head
            picks <- !(dataToWrite$event_id %in% dataInDB$event_id &
                           dataToWrite$event_schedule_id %in% dataInDB$event_schedule_id)
            dataToWrite <- dataToWrite[picks,]
        }
        # write set difference to database
        if(nrow(dataToWrite)) {
            print(paste0(nrow(dataToWrite), " rows write to ", tbName))
            print(dbWriteTable(con, tbName, dataToWrite, row.names = FALSE, append=TRUE))
        } else {
            print("DB not affected")
        }
        dbDisconnect(con)
    }
}


dayFreq <- function(events) {
    days <- data.frame(
        "Sun" = grepl("sun", events$recur_days),
        "Mon" = grepl("mon", events$recur_days),
        "Tue" = grepl("tue", events$recur_days),
        "Wed" = grepl("wed", events$recur_days),
        "Thu" = grepl("thu", events$recur_days),
        "Fri" = grepl("fri", events$recur_days),
        "Sat" = grepl("sat", events$recur_days)
    )
    print("day freqency")
    return(days)
}

eventByDay <- function(events, days) {
    event.day <- tbl_df(data.frame(events[,c("neighborhood","category")], days)) %>%
        gather(day, value, -neighborhood, -category) %>% 
        filter(value) %>% 
        select(neighborhood, category, day)
    return(event.day)
}