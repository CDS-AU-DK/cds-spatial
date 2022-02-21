library(shiny)
library(leaflet)
library(mapboxapi)
library(sf)

token <- "token"
# Read in the hospital data
hospital <- readr::read_rds("../data/hospitals.rds") 

st_crs(hospital) <- 4326

# Set up a sidebar panel with a text box for an input address, 
# and a placeholder to print out the driving instructions
ui <- fluidPage(
  sidebarPanel(
    textInput("address_text", label = "Address",
              placeholder = "Type an address or place name"),
    actionButton("action", "Find the nearest hospital"),
    htmlOutput("instructions"),
    width = 3
  ),
  mainPanel(
    leafletOutput(outputId = "map", width = "100%", height = 600)
  )
)

# Set up reactive elements to generate routes when the action button is clicked,
# then map the routes and print out the driving directions
server <- function(input, output) {
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addMapboxTiles(style_id = "streets-v11",
                     username = "mapbox",
                     access_token = token)  %>%
      addMarkers(data = hospital, popup = ~placename)
    
    
  })
  
  # Find the closest hospital with mb_matrix()
  closest_location <- eventReactive(input$action, {
    
    input_sf <- mb_geocode(input$address_text, output = "sf",
                           access_token = token) 
    
    st_crs(input_sf) <- 4326
    
    min_index <- mb_matrix(
      origins = input_sf,
      destinations = hospital,
      access_token = token
    ) %>%
      as.vector() %>%
      which.min()
    
    min_coords <- hospital[min_index, ] %>%
      st_coordinates() %>%
      as.vector()
    
    return(min_coords)
    
  })
  
  observeEvent(closest_location(), {
    
    route <- mb_directions(
      origin = mb_geocode(input$address_text, access_token = token),
      destination = closest_location(),
      profile = "driving",
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
      addPolylines(data = route, color = "black",
                   opacity = 1) %>%
      flyTo(lng = flyto_coords[1],
            lat = flyto_coords[2],
            zoom = 14)
    
    output$instructions <- renderUI({
      HTML(paste0(
        paste("&bull;", route$instruction, sep = ""),
        collapse = "<br/>"))
    })
  })
  
}

shinyApp(ui = ui, server = server)