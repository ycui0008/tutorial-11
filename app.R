library(tidyverse)
library(leaflet)
library(shinydashboard)
library(shiny)

# -- load data
# sensors <- read_rds("data/sensors.rds")
sensor_locations <- read_csv("data/locations.csv")

# sensors %>%
#   filter(site_id == "arc1046") %>%
#   group_by(type) %>%
#   filter(local_time == max(local_time)) %>%
#   ungroup()



ui <- dashboardPage(
  dashboardHeader(title = "Melbourne Weather Sensor", titleWidth = 300),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    box(leafletOutput("map"), title = "Sensor locations", width = 12),
    valueBoxOutput("temperature"),
    valueBoxOutput("humidity"),
    valueBoxOutput("pollution")
  )
)

server <- function(input, output) {
  recent_measurements <- reactive({
    # req(input$map_marker_click)

    site_id <- if(is.null(input$map_marker_click)){
      "arc1046"
    } else {
      input$map_marker_click$id
    }


    sensors %>%
      filter(site_id == {{site_id}}) %>%
      group_by(type) %>%
      filter(local_time == max(local_time)) %>%
      ungroup()
  })

  output$map <- renderLeaflet({
    leaflet(sensor_locations) %>%
      addTiles() %>%
      addMarkers(lng = ~longitude, lat = ~latitude, popup = ~description, layerId = ~site_id)
  })
  output$temperature <- renderValueBox({

    recent_measurements() %>%
      filter(type == "TPH.TEMP") %>%
      pull(value) %>%
      valueBox(subtitle = "Temperature")
  })

  output$humidity <- renderValueBox({
    recent_measurements() %>%
      filter(type == "TPH.RH") %>%
      pull(value) %>%
      valueBox(subtitle = "Relative Humidity")
  })

  output$pollution <- renderValueBox({

    recent_measurements() %>%
      filter(type == "PM2.5") %>%
      with(
        valueBox(value = paste(value, units),
                 subtitle = type,
                 color = case_when(
                      value > 300 ~ "maroon",
                      value > 200 ~ "purple",
                      value > 150 ~ "red",
                      value > 100 ~"orange",
                      value > 50 ~"yellow",
                      TRUE ~ "green"
                    )))
  })
}


shinyApp(ui, server)
