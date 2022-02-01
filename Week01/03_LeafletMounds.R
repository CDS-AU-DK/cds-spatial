###   PLOTTING IN LEAFLET USING BULGARIAN MOUND DATA

# packages

# install.packages("tidyverse")
# install.packages("leaflet")
# install.packages("htmltools")

# load libraries

suppressMessages({
  library(tidyverse)
  library(sf)
  library(htmltab)
})

getwd()


### ELENOVO burial mounds: prepare data 
# Read data from where you downloaded it. Adela,look in: D:/Adela/Professional/Projects/MQNS/Data/"
mounds <- read_csv("data/ElenovoMounds_cleaned.csv")


# Transform dataframe into a spatial feature and project to Web Mercator 
# Leaflet basemapes here are 3D
mounds <- st_as_sf(mounds, coords = c("Longitude", "Latitude"),  crs = 4326)
st_crs(mounds)
mounds


# Plot the mounds

plot(mounds$geometry, pch = 2, cex = sqrt(mounds$HeightMax))


# Plot mounds in Leaflet

library(leaflet)

moundmap <- leaflet() %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldTopoMap", group = "Topo") %>%
  addProviderTiles("Esri.WorldImagery", group = "ESRI Aerial") %>%
  addCircleMarkers(data=mounds, radius = mounds$HeightMax*1.5, 
                   opacity = 0.5, color= "black", stroke = TRUE,
                   fillOpacity = 0.5, weight=2, fillColor = "yellow",
                   popup = paste0("MoundID: ", mounds$identifier,
                                  "<br> Height: ", mounds$HeightMax,
                                  "<br> Condition: ", mounds$Condition,
                                  "<br> Last Damage: ", mounds$MostRecentDamageWithin)) %>%
  addLayersControl(
    baseGroups = c("Topo","ESRI Aerial"),
    overlayGroups = c("Mounds"),
    options = layersControlOptions(collapsed = T))

moundmap

# Mounds with Icon
MoundIcon <- makeIcon(iconUrl = "data/Mound.png", iconWidth = 20, iconHeight = 20)

iconmap <- leaflet() %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldTopoMap", group = "Topo") %>%
  addProviderTiles("Esri.WorldImagery", group = "ESRI Aerial") %>%
  addMarkers(data=mounds, group="Mounds",
             icon = MoundIcon,  
             popup = paste0("MoundID: ", mounds$identifier,
                            "<br> Height: ", mounds$HeightMax,
                            "<br> Condition: ", mounds$Condition,
                            "<br> Last Damage: ", mounds$MostRecentDamageWithin)) %>%
  
  addLayersControl(
    baseGroups = c("Topo","ESRI Aerial"),
    overlayGroups = c("Mounds"),
    options = layersControlOptions(collapsed = T))

iconmap

# Print a html
# use saveWidget() from library htmlwidgets to save a (standalone) interactive map in the current directory.

library(htmlwidgets)
saveWidget(moundmap, "moundmap.html", selfcontained = TRUE)
saveWidget(iconmap, "iconmap.html", selfcontained = TRUE)