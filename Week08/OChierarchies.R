# OC data: creating spatial hierarchy for Eric Kansa April 2023

library(sf)

# Load survey polygons
kaz <- read_sf("C:/Users/adela/Downloads/kaz-survey-units-reproj-w-uuids-fixed.geojson")
yam <- read_sf("C:/Users/adela/Downloads/yam-survey-units-reproj-w-uuids.geojson")

plot(yam$geometry)
plot(kaz$geometry)

names(kaz)
st_crs(kaz)

# Load site polygons
k_sites <- read_sf("C:/Users/adela/Desktop/TRAP_Oxbow/KAZ/KAZ_margins.shp")
names(k_sites)
plot(k_sites$geometry)
k_sites

# Load site attributes (chronology)

# Check for spatial join 
# to join attributes 

kaz_join_site <- kaz %>% 
  st_transform(32635) %>% 
  st_join(k_sites[,4:8])

kaz_join_site
colnames(kaz_join_site)
tail(kaz_join_site[30:36])

# check what groupings you get now