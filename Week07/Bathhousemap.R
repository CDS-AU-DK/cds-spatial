###############################################
#
#   Map of Copenhagen baths 
#   Aarhus University 2021
#   Adela Sobotkova and Magnus Lindholm Nielsen
#
###############################################

# Activate libraries
library(leaflet)
library(tidyverse)
library(htmltools)
library(googlesheets4)


# Bring in a choice of Esri background layers  
l_cp <- leaflet() %>%   # assign the base location to an object
  setView(12.56553, 55.675946, zoom = 11)
#l_cp %>% addTiles()

esri <- grep("^Esri", providers, value = TRUE)
for (provider in esri) {
  l_cp <- l_cp %>% addProviderTiles(provider, group = provider)
}


# Create the map
MapCPH <- l_cp %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }")%>%
  addControl("", position = "topright")

MapCPH

# test adding points
MapCPH %>% addAwesomeMarkers(lng = c(12.34, 12.23, 12.11),
                            lat = c(55.82, 55.63, 55.49), 
                            popup = c("Mary", "Magnus", "Monty"))



#####################################################
#
# Task 2: Bring in bathhouse points for Copenhagen

# Load data from Googlesheet (deauthorize your connection if read_sheet gives you trouble)
baths <- read_sheet("https://docs.google.com/spreadsheets/d/15i17dqdsRYv6tdboZIlxTmhdcaN-JtgySMXIXwb5WfE/edit#gid=0",
                    col_types = "ccnnncnnnc")

# Prepare a color palette to reflect spatial precision of points
# baths$Quality <- factor(baths$Quality) #factpal no longer needs a factor
glimpse(factor(baths$Quality))  # check the Quality values
factpal <- colorNumeric(c("navy", "red", "grey"), 1:3) # prepare scale
factpal(c(1,1,2)) # test the scale works

# Read the bath coordinates and names into map
Bathsmap <- MapCPH %>% addCircleMarkers(lng=baths$Longitude,
                           lat=baths$Latitude,
                           radius=baths$Quality*3,
                           color = factpal(baths$Quality),
                           popup = paste0("Name: ", baths$BathhouseName,
                                          "<br> Notes: ", baths$Notes))
Bathsmap
Bathsmap %>% addPolygons(data=suburbs)

# Save map as a html document (optional, replacement of pushing the export button)
# only works in root
library(htmlwidgets)
saveWidget(Bathsmap, "Bathhousemap.html", selfcontained = TRUE)

#############################################################
#  Part II - Compare OSM data with present dataset
#############################################################
# Convert data points into a grid using the function defined below

pt_in_grid <- function(feat, adm, cellsize = 1000){
  grid <- st_make_grid(x = adm, cellsize = cellsize, what = "polygons")
  . <- st_intersects(grid, adm)
  grid <- grid[sapply(X = ., FUN = length)>0]
  . <- st_intersects(grid, feat)
  grid <- st_sf(n = sapply(X = ., FUN = length), grid)
  return(grid)
}


library(leaflet)
gr_osm <- pt_in_grid(baths_osm,st_transform(suburbs,32632),500)
gr_his <- pt_in_grid(hist_baths,st_transform(suburbs,32632),500)
plot(gr_osm)
plot(gr_his)

grid <- gr_osm %>% rename(osm=n) %>% 
  mutate(history = gr_his$n) %>% 
  filter(history==0,osm==0) %>%
  mutate(missing =  pmax(history - osm,0))

plot(grid)
which(grid$missing==0)
which(grid$missing>0)
which(is.na(grid$missing))


bks = c(0,1,2,3,4,5,6,7)
pal <- colorNumeric(
  palette = "Greens",
  domain = gr_osm$n)
color.scale <- colorBin(pal, domain = range(bks), bins=bks)

leaflet(gr_osm%>% 
          st_transform(4326) %>% 
          filter(!is.na(n))) %>% 
  addProviderTiles(providers$Stamen.TonerLite) %>% 
  addPolygons(fillColor = ~pal(gr_osm$n), 
              stroke = FALSE, 
              fillOpacity = 0.7) # %>% 
  # addLegend(colors = ~pal(bks), 
  #           #labels = round(bks[1:(length(bks)-1)]*10)/10,
  #           title = "# net difference between</br> bathrooms 
  #           in </br>historical records and OSM")
