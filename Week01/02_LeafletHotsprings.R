###   PLOTTING IN LEAFLET USING ONLINE DATA FROM CA


###   Example from UC Davis RUser group
###   https://ryanpeek.github.io/2017-08-03-converting-XY-data-with-sf-package/
  
# Packages
  
# install.packages("htmltools")
# install.packages("leaflet")

# Load libraries
suppressMessages({
  library(tidyverse)
  library(sf)
  library(htmltab)
})

# Download data
url <- "http://www.hotspringsdirectory.com/usa/ca/gps-usa-ca.html"
springs <- htmltab(url, which=1, header = 1,
              colNames = c("STATE","LAT","LONG","SpringName","Temp_F", "Temp_C", "AREA", "USGS_quad") )  # get the data


# Convert Lat/Long columns to numeric:

sapply(springs, class)  # dataframe is  of character class now
cols.num<- c("LAT","LONG", "Temp_F", "Temp_C")  # select columns which need to be numeric
springs[cols.num]<-sapply(springs[cols.num], as.numeric)  
# beware that some NA's will appear where there are no temperatures available

head(springs$LONG)
springs$LONG<-springs$LONG*(-1)   # sanity check given the western hemisphere
head(springs)

# The chunk above does the following:
#   
# Function from the htmltab package goes and grabs the first table on the page, 
# parses it out into a dataframe, and adds custom column names. 
# We should have 303 rows and 8 columns of data, including the temperature in °F and °C.
# Then identify the column classes and select columns we want to convert to numeric.
# Apply those changes to those columns using sapply
# Make sure our longitude is negative, so that these plot in the right hemisphere. :)




# Make the UTM cols spatial (X/Easting/lon, Y/Northing/lat)
springs.SP <- st_as_sf(springs, coords = c("LONG", "LAT"), crs = 4326)
st_crs(springs.SP)


# to project the file to UTM 10N
st_crs(32610)
springs.SP <- st_transform(springs.SP, crs=32610) # but tiles in Leaflet use Web Mercator 4326

# To get projected coordinates (Northing&Easting) and feed them back into the csv
springs.SP$utm_E <- st_coordinates(springs.SP)[,1]
springs.SP$utm_N <- st_coordinates(springs.SP)[,2]
st_coordinates(springs.SP)

# Coerce back to data.frame:
#springs.SP<-st_set_geometry(springs.SP, NULL)

plot(springs.SP$geometry)


## PLOTTING in Leaflet

# Reproject into Web Mercator for display in Leaflet
springs.SP <- st_transform(springs.SP, crs=4326) # Base imagery is 3D


library(leaflet)

springsmap <- leaflet() %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldTopoMap", group = "Topo") %>%
  addProviderTiles("Esri.WorldImagery", group = "ESRI Aerial") %>%
  addCircleMarkers(data=springs.SP, group="Hot Springs", radius = 4, opacity=1, fill = "darkblue",stroke=TRUE,
                   fillOpacity = 0.75, weight=2, fillColor = "yellow",
                   popup = paste0("Spring Name: ", springs.SP$SpringName,
                                  "<br> Temp_F: ", springs.SP$Temp_F,
                                  "<br> Area: ", springs.SP$AREA)) %>%
  addLayersControl(
    baseGroups = c("Topo","ESRI Aerial", "Night"),
    overlayGroups = c("Hot SPrings"),
    options = layersControlOptions(collapsed = T))

springsmap
