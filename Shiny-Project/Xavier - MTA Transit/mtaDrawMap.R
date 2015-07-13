
###1. Websource: 
###http://web.mta.info/developers/developer-data-terms.html#data
###click on "Yes, I agree to these terms and conditions."


##1. Map buses and Subway
##a. Load the bus shapes in a single file for later modifications
# shapesbus = read.csv("data/shapesbus.txt")
# shapesbus = mutate(shapesbus,origin='shapesbus')
# shapesmanhattan = read.csv("data/shapesmanhattan.txt")
# shapesmanhattan = mutate(shapesmanhattan,origin='shapesmanhattan')
# shapesbrooklyn = read.csv("data/shapesbrooklyn.txt")
# shapesbrooklyn = mutate(shapesbrooklyn,origin='shapesbrooklyn')
# shapesqueens = read.csv("data/shapesqueens.txt")
# shapesqueens = mutate(shapesqueens,origin='shapesqueens')
# shapesbronx = read.csv("data/shapesbronx.txt")
# shapesbronx = mutate(shapesbronx,origin='shapesbronx')
# shapesstatenisland = read.csv("data/shapesstatenisland.txt")
# shapesstatenisland = mutate(shapesstatenisland,origin='shapesstatenisland')
# shapes=rbind(shapesbus,shapesmanhattan,shapesbrooklyn,shapesqueens,shapesbronx,shapesstatenisland)
# write.table(shapes, file = "data/shapesbus.csv", sep = ",", col.names = NA,qmethod = "double")
allshapesbuses = read.table("data/shapesbus.csv", header = TRUE, sep = ",", row.names = 1)

###2. source: New York City Transit Subway - Updated June 16, 2015
#   shapessubway = read.csv("data/shapessubway.txt")
#  

drawmap <- function(){
  
  library(ggplot2)
  library(dplyr)
  
  subways=c(1:7,"A","B","C","D","E","F","G","J","L","M","N","Q","R")
  shapesbuses = allshapesbuses #filter(allshapesbuses, origin %in% c('shapesmanhattan','shapesbrooklyn','shapesbronx'))
  

  
 
  #   ### capture colors of the subway lines:
  routes = read.csv("data/routes.txt")
  #   stops = read.csv("data/stops.txt")
  #   
  #   ###colors associated with lines + change 'GS' for 'S'
  #   ### add # in front forcolor HEX
  routes002 = select(routes,route_id,route_color) %>% 
    mutate(route_color = paste0("#", route_color))
  #   routes002
  #   
  #   
  #   ###subway stops :parent_station==''
  #   stops002 = filter(stops,parent_station=='')
  #   stops003 = mutate(stops002,route_id = substr(stop_id,1,1))
  #   shapessubway002 = mutate(shapessubway,
  #                            route_id=substr(shape_id,1,1))
  #   shapessubway003= inner_join(shapessubway002,
  #                               routes002,by='route_id')
  #   write.table(shapessubway003, file = "data/shapessubway.csv", sep = ",", col.names = NA,qmethod = "double")
  shapessubway = read.table("data/shapessubway.csv", header = TRUE, sep = ",", row.names = 1)
  
  
  
  shapessubwaytodraw = filter(shapessubway,
                              route_id %in% subways)
  
  routes003 = filter(routes002,
                     route_id %in% subways)
  #   stops005 = filter(stops003,
  #                     route_id %in% c(1))
  
  
  
  graph002 = ggplot() +
    geom_path(data=shapesbuses,
              aes(shape_pt_lon, 
                  shape_pt_lat, 
                  group=shape_id),
              color='white',
              size=.1,
              alpha=.1)+
    geom_path(data=shapessubwaytodraw,
              aes(shape_pt_lon, 
                  shape_pt_lat, 
                  group=shape_id,
                  color=route_id
              ),
              size=1) +
    scale_color_manual(name="Subway \n Lines",values=routes003$route_color)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    theme(panel.background = element_rect(fill = "black"),
          plot.background = element_rect(fill = "black"),
          title = element_text(hjust=1, colour="white", size = 9),
          axis.title.x = element_text(hjust=0,colour="white", size = 8),
          legend.title = element_text(colour="black",size=8),
          legend.text = element_text(colour="black", size = 8),
          legend.key= element_rect(fill="black"))+
    coord_cartesian()  +
    coord_fixed()+
    xlab(sprintf("Generated with R Studio / Source: mta.info API - Static Data Feeds")) +
    ylab("") +
    ggtitle("New York public transport system\nBuses and Subways")
  #graph002
  return(graph002)
  
}