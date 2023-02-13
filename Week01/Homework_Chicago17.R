## CHICAGO HOMICIDES

# Load necessary libraries
library(tidyverse)
library(leaflet)


# Load some data the from Chicago data portal
# https://data.cityofchicago.org/Public-Safety/Crimes-2017/d62x-nvdr
crimes <- read_csv("data/ChicagoCrimes2017.csv")
glimpse(crimes)

# What's in Primary Type?
unique(crimes$`Primary Type`) # too many options for mapping

# Get 6 top crimes
crime <- crimes %>% 
  group_by(`Primary Type`) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  slice(1:6) %>% 
  pull(`Primary Type`)

# Filter data by 6 top crimes or by stuff you are interested in 
crime6 <- crimes%>% 
  filter(`Primary Type`%in% crime) %>% 
  filter(!is.na(Latitude))

crimeCH <- crimes %>%
    filter(`Primary Type` %in% c("HOMICIDE","SEX OFFENSE", "NARCOTICS", "MOTOR VEHICLE THEFT", "ARSON", "LIQUOR LAW VIOLATION")) %>% 
    filter(!is.na(Latitude))

crime6 %>% 
  group_by(`Primary Type`) %>% 
  tally()

crimeCH %>% 
  group_by(`Primary Type`) %>% 
  tally()


################### Colored markers
library(lubridate)
library(hms)
crime6 <- crime6 %>%
  mutate(time = as_hms(mdy_hms(Date))) %>% 
  mutate(hour = hour(time))

# 1 Create a palette that maps different crime times to colors
# does time work?
ifelse(crime6$hour > 1 & crime6$hour < 12, TRUE, FALSE)

summary(crime6$hour)

getColor <- function(crime6) {
  sapply(crime6$time, function(time) {
    if(time > 00:01:00 & time < 12:00:00) {
      "green"
    } else if(time > 12:00:01 & time < 24:00:00) {
      "orange"
    } else {
      "red"
    } })
}

getColor <- function(crime6) {
  sapply(crime6$hour, function(hour) {
    if(hour > 1 & hour < 12) {
      "green"
    } else if(hour > 12 & hour < 24) {
      "orange"
    } else {
      "red"
    } })
}

icons <- awesomeIcons(
  icon = 'ios-close',
  iconColor = 'black',
  library = 'ion',
  markerColor = getColor(crime6)
)

leaflet(homicides) %>% addTiles() %>%
  addAwesomeMarkers(icon = icons, label = ~Date)


# 2 Create a palette that maps factor levels to colors

pal <- colorFactor(c("navy", "red", "orange", "yellow", "pink","brown"), domain = crime)

crime6 %>% 
  slice(1:1000) %>% 
  leaflet() %>%
  addTiles() %>%
  addCircleMarkers(
    color = ~pal(crime6$`Primary Type`),
    stroke = FALSE, fillOpacity = 0.5
  )
################### HEATMAP


# Filter out homicides only
(homicides <- crimes %>%
    filter(`Primary Type` == "HOMICIDE"))

# Plot on a map letting R Leaflet pick Longitude and Latitude automagically 

# addMarkers() and related functions will automatically check data frames for columns called 
# lng/long/longitude and lat/latitude (case-insensitively). If your coordinate columns have any other names, 
# you need to explicitly identify them using the lng and lat arguments. 
# Such as `addMarkers(lng = ~Longitude, lat = ~Latitude).

leaflet(data = homicides) %>%
  addTiles() %>%
  addMarkers(label = ~Date)

# Heatmap is in the extras!

library(leaflet.extras)

homicides %>% 
  filter(!is.na(Latitude)) %>% 
  leaflet() %>%
  addTiles() %>%
  addHeatmap(lng=~as.numeric(Longitude),
             lat=~as.numeric(Latitude),
             radius = 9) %>% 
  addMiniMap(tiles = 'Esri.WorldTopoMap', toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479")


# Customize your icons with The awesome markers plugin. 

# Instead of using addMarkers(), use addAwesomeMarkers() to control the appearance of the markers
# using icons from the Font Awesome, Bootstrap Glyphicons, and Ion icons icon libraries.
#https://github.com/lvoogdt/Leaflet.awesome-markers
#https://ionicons.com/
#https://fontawesome.com/icons?from=io

icons <- awesomeIcons(
  icon = 'bolt',
  iconColor = 'orange',
  markerColor = "black",
  library = 'fa'
)

leaflet(data = homicides) %>%
  addTiles() %>%
  addAwesomeMarkers(icon = icons)


# Cluster your datapoints to prevent overlap and improve readability
leaflet(data = homicides) %>%
  addTiles() %>%
  addMarkers(clusterOptions = markerClusterOptions())

# Add labels
leaflet(data = homicides) %>%
  addTiles() %>%
  addMarkers(clusterOptions = markerClusterOptions(), 
             label = ~Date)


# Add richer labels
leaflet(data = homicides) %>%
  addTiles() %>%
  addMarkers(clusterOptions = markerClusterOptions(), 
             label = paste0("Date:", homicides$Date,
                                                                     "<br> Description:", homicides$Description))

Chicago_homicides2017 <- leaflet(data = homicides) %>%
  addTiles() %>%
  addMarkers(clusterOptions = markerClusterOptions(), 
             label = paste0("Date:", homicides$Date,
                                                                     "<br> Description:", homicides$Description))
Chicago_homicides2017

# SAVE YOUR HTML DOCUMENT
library(htmlwidgets)
saveWidget(Chicago_homicides2017, "Chicago17.html", selfcontained = TRUE)
