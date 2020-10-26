library(tidyverse)
library(leaflet)
library(shinydashboard)
library(shiny)

# -- load data
sensors <- read_rds("data/sensors.rds")
sesnor_locations <- read_csv("data/locations.csv")




ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(),
  dashboardBody()
)

server <- function(input, output) { }


shinyApp(ui, server)
