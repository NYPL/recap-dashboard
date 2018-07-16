#!/usr/local/bin//Rscript --vanilla


library(shiny)
library(shinydashboard)
library(magrittr)
library(data.table)


header <- dashboardHeader(
  title = "ReCAP collection",
  dropdownMenu(type = "messages",
               messageItem(
                 from = "Notice",
                 message = "The Harvard items are only integration candidates",
                 icon = icon("life-ring"),
                 time = "2018-07-16"
               ),               
               messageItem(
                 from = "Last update",
                 message = "This dashboard was last updated 2018-07-16",
                 icon = icon("life-ring"),
                 time = "2018-07-16"
               )
  )
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Widgets", tabName = "widgets", icon = icon("th"))
  )
)

body <- dashboardBody(
  tabItems(
    
    # First tab content
    tabItem(tabName = "dashboard",
            
            fluidRow(
              valueBoxOutput("totalItemsValueBox")
            )
              
            # fluidRow(
            #   box(plotOutput("plot1", height = 250)),
            #   
            #   box(
            #     title = "Controls",
            #     sliderInput("slider", "Number of observations:", 1, 100, 50)
            #   )
            # )
    ),
    
    # Second tab content
    tabItem(tabName = "widgets",
            h2("Widgets tab content")
    )
    
  )
)


ui <- dashboardPage(header, sidebar, body)





server <- function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
  output$totalItemsValueBox <- renderValueBox({
    valueBox(
      "100",
      "Items in ReCAP collection",
      color="purple"  
    )
  })
  
}




shinyApp(ui, server)
