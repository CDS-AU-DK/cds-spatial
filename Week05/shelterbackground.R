# GEnerate a accessibility raster for shelters for 1 to 10 mins walk
library(sf)
library(raster)
library(fasterize)
library(mapboxapi)


shelter

walking_isos <- mb_isochrone(
  shelter,
  profile = "walking",
  time = 1:15
)


isos_proj <- st_transform(walking_isos, 25832)

template <- raster(isos_proj, resolution = 25)
iso_surface <- fasterize(isos_proj, template, field = "time", fun = "min")

pal <- colorNumeric("viridis", isos_proj$time, na.color = "transparent")

mapbox_map %>%
  addRasterImage(iso_surface, colors = pal, opacity = 0.5) %>%
  addCircleMarkers(data = shelter, radius = 0.1 ,col = "black") %>% 
  addLegend(values = isos_proj$time, pal = pal,
            title = "walk-time (in minutes) <br> to shelters in Aarhus")

writeRaster(iso_surface, "../data/shelter_iso_surf25.tif", format = "GTiff" )
test <- raster("../data/shelter_iso_surf25.tif")



png("shelterisos.png", width=600, height = 600)
par(bg = 'blue')
plot(iso_surface); plot(st_transform(shelter$geometry, crs(iso_surface)), col = "red", cex = 0.2, add = TRUE)
#grid( col = "white")
dev.off()