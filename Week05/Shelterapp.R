library(shiny)
library(leaflet)
library(mapboxapi)
library(sf)

token <- my_token
# Read in the shelter data
shelter <- readr::read_rds("../data/shelters.rds") 

st_crs(shelter) <- 4326

# Set up a sidebar panel with a text box for an input address, 
# and a placeholder to print out the driving instructions
ui <- fluidPage(
  sidebarPanel(
    textInput("address_text", label = "Address",
              placeholder = "Type an address or place name"),
    actionButton("action", "Find the nearest shelter"),
    textInput("instructions_text", label = "Instructions to the shelter /n (beware:location error ~100m)"),
    htmlOutput("instructions"),
    width = 3
  ),
  mainPanel(
    leafletOutput(outputId = "map", width = "100%", height = 1000)
  )
)

# Set up reactive elements to generate routes when the action button is clicked,
# then map the routes and print out the driving directions
server <- function(input, output) {
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addMapboxTiles(style_id = "satellite-streets-v11",
                     username = "mapbox",
                     access_token = token)  %>%
      addMarkers(data = shelter)
                 #, popup = ~placename)
    
    
  })
  
  # Find the closest shelter with mb_matrix()
  closest_location <- eventReactive(input$action, {
    
    input_sf <- mb_geocode(input$address_text, output = "sf",
                           access_token = token) 
    
    st_crs(input_sf) <- 4326
    
    min_index <- mb_matrix(
      origins = input_sf,
      destinations = shelter,
      access_token = token
    ) %>%
      as.vector() %>%
      which.min()
    
    min_coords <- shelter[min_index, ] %>%
      st_coordinates() %>%
      as.vector()
    
    return(min_coords)
    
  })
  
  observeEvent(closest_location(), {
    
    route <- mb_directions(
      origin = mb_geocode(input$address_text, 
                          access_token = token),
      destination = closest_location(),
      profile = "walking",
      output = "sf",
      steps = TRUE,
      access_token = token
    ) 
    
    st_crs(route) <- 4326
    
    flyto_coords <- route %>%
      st_union() %>%
      st_centroid() %>%
      st_coordinates() %>%
      as.vector()
    
    leafletProxy(mapId = "map") %>%
      clearShapes() %>%
      addPolylines(data = route, color = "red",
                   opacity = 1) %>%
      #addMarkers(data = input_sf) %>% 
      flyTo(lng = flyto_coords[1],
            lat = flyto_coords[2],
            zoom = 16)
    
    output$instructions <- renderUI({
      HTML(paste0(
        paste("&bull;", route$instruction, sep = ""),
        collapse = "<br/>"))
    })
  })
  
}

shinyApp(ui = ui, server = server)