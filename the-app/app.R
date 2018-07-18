#!/usr/local/bin//Rscript --vanilla


library(shiny)
library(shinydashboard)
library(magrittr)
library(data.table)
library(ggplot2)
library(stringr)

options(warn=1)

#####################################
# set up

validxtab <- fread("./valid-lc-call-xtab.txt")
TOTALBIBS <- validxtab[institution=="CUL", numofbibs] + validxtab[institution=="PUL", numofbibs]+ validxtab[institution=="NYPL", numofbibs]

instxwalk <- data.table(institution=c("NYPL", "CUL", "PUL", "HUL"),
                        instname=c("NYPL", "Columbia", "Princeton", "Harvard"))
setkey(instxwalk, institution)

validxtab[, .(institution, invalid, valid)] %>% melt(id="institution", measures.var=c("valid", "invalid")) -> tmp
setnames(tmp, "variable", "lccall")
instxwalk[tmp] -> validandinvalid

broads <- fread("./broad-subjects.txt")
instxwalk[broads] -> broads


langvalidxtab <- fread("./valid-lang-xtab.txt")
langs <- fread("./languages.txt")
# xwalked later

yearvalidxtab <- fread("./valid-year-xtab.txt")
years <- fread("./years-SAMPLE.txt")
instxwalk[years] -> years

subjects <- fread("./subjects.txt")
instxwalk[subjects] -> subjects

#####################################

header <- dashboardHeader(
  title = "ReCAP Collection",
  dropdownMenu(type = "messages")
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
    menuItem("LC Call Numbers", tabName = "lccall", icon = icon("circle")),
    menuItem("Broad Subject Analysis", tabName = "broadsubject", icon = icon("envelope")),
    menuItem("Detailed Subject Analysis", tabName = "detailedsubject", icon = icon("envelope-open")),
    menuItem("Language Analysis", tabName = "language", icon = icon("language")),
    menuItem("Publication Year Analysis", tabName = "pubyear", icon = icon("calendar"))
  )
)

body <- dashboardBody(
  tabItems(
    
    # OVERVIEW TAB
    tabItem(tabName = "overview",
            h1("Overview"),
            br(),
            fluidRow(
              valueBoxOutput("totalBibsValueBox")
            ),
            fluidRow(
              valueBoxOutput("nyplBibsValueBox"),
              valueBoxOutput("culBibsValueBox"),
              valueBoxOutput("pulBibsValueBox")
            ),
            fluidRow(
              valueBoxOutput("harvardBibsValueBox")
            ),
            fluidRow(br(), br(), br()),
            fluidRow(
              tags$pre("     * since last data update 
     ‡ only adding NYPL, Columbia and Princeton's collections")
            )
    ),
    
    
    
    
    # LC CALL NUMBER TAB
    tabItem(tabName = "lccall",
            h2("Library of Congress Call Numbers"),
            br(),
            fluidRow(
              valueBoxOutput("nyplLcPercValueBox"),
              valueBoxOutput("culLcPercValueBox"),
              valueBoxOutput("pulLcPercValueBox"),
              valueBoxOutput("harvardLcPercValueBox")
            ),
            fluidRow(
              column(12,
                     box(plotOutput("validornotplot"), width=8)
                     )
            )
    ),
    
    
    
    
    # BROAD SUBJECT TAB
    tabItem(tabName = "broadsubject",
            h2("Broad Subject Analysis"),
            br(),
            fluidRow(
              column(12,
                     box(plotOutput("broadsubjectplot"), width=8, height="710"),
                     box(
                       title = "Controls",
                       selectInput("broad_typeview", "Percent or count?",
                                   c("Percent" = "percent",
                                     "Count" = "count")),
                       sliderInput("broad_numberoftopsubjects", "Number of top subjects:", 1, 22, 5),
                       checkboxInput("broad_nyplp", "Include NYPL", TRUE),
                       checkboxInput("broad_culp", "Include Columbia", TRUE),
                       checkboxInput("broad_pulp", "Include Princeton", TRUE),
                       checkboxInput("broad_harvp", "Include Harvard", FALSE),

                       
                       width=4
                     )
              )
            ),
            fluidRow(br(), br()),
            fluidRow(
              tags$pre("     * percentages represent percent of that institution's collection in a particular broad subject")
            )
    ),
    
    
    # SUBJECT TAB
    tabItem(tabName = "detailedsubject",
            h2("Detailed Subject Analysis"),
            br(),
            fluidRow(
              column(12,
                     box(plotOutput("subjectplot"), width=8, height=710),
                     box(
                       title = "Controls",
                       selectInput("subject_dropdown", "Broad Subject",
                                   c("Language and Literature (P)" = "P",
                                     "Social Sciences (H)" = "H",
                                     "Education (L)" = "L",
                                     "Law (K)" = "K",
                                     "General Works (A)" = "A",
                                     "Philosophy, Psychology, Religion (B)" = "B",
                                     "Political Science (J)" = "J",
                                     "Fine Arts (N)" = "N",
                                     "Technology (T)" = "T"
                                   )),
                       selectInput("subject_typeview", "Percent or count?",
                                   c("Percent in broad subject in institution" = "percent_cat",
                                     "Percent in institution" = "percent_inst",
                                     "Count" = "count")),
                       sliderInput("subject_numberoftopsubjects", "Number of top subjects:", 1, 22, 5),
                       checkboxInput("subject_nyplp", "Include NYPL", TRUE),
                       checkboxInput("subject_culp", "Include Columbia", TRUE),
                       checkboxInput("subject_pulp", "Include Princeton", TRUE),
                       checkboxInput("subject_harvp", "Include Harvard", FALSE),
                       
                       
                       width=4
                     )
              )
            )
    ),
    
    
    
    # LANGUAGE TAB
    tabItem(tabName = "language",
            h2("Language Analysis"),
            br(),
            fluidRow(
              valueBoxOutput("nyplLangPercBox"),
              valueBoxOutput("culLangPercBox"),
              valueBoxOutput("pulLangPercBox")
            ),
            
            fluidRow(
              column(12,
                     box(plotOutput("overalllanguageplot"), width=8),
                     box(
                       title = "Controls",
                       sliderInput("overall_numberoftoplanguages", "Number of top languages:", 1, 50, 5),
                       width=4
                     )
              )
            ),
            fluidRow(
              column(12,
                     box(plotOutput("instlanguageplot"), width=8, height=710),
                     box(
                       title = "Controls",
                       selectInput("instlang_typeview", "Percent or count?",
                                   c("Percent" = "percent",
                                     "Count" = "count")),
                       sliderInput("instlang_numberoftoplanguages", "Number of top subjects:", 1, 50, 5),
                       checkboxInput("instlang_nyplp", "Include NYPL", TRUE),
                       checkboxInput("instlang_culp", "Include Columbia", TRUE),
                       checkboxInput("instlang_pulp", "Include Princeton", TRUE),
                       width=4
                     )
              )
            ),
            fluidRow(br(), br()),
            fluidRow(
              tags$pre("     * percentages represent percent of that institution's collection in a particular language")
            )
    ),
    
    
    
    # PUB YEAR TAB
    tabItem(tabName = "pubyear",
            h2("Year of Publication Analysis"),
            br(),
            fluidRow(
              valueBoxOutput("nyplYearPercBox"),
              valueBoxOutput("culYearPercBox"),
              valueBoxOutput("pulYearPercBox")
            ),
            
            fluidRow(
              column(12,
                     box(plotOutput("overallyearplot"), width=8)
              )
            ),
            fluidRow(
              column(12,
                     box(plotOutput("instyearsplot"), width=8),
                     box(
                       title = "Controls",
                       checkboxInput("instyear_nyplp", "Include NYPL", TRUE),
                       checkboxInput("instyear_culp", "Include Columbia", TRUE),
                       checkboxInput("instyear_pulp", "Include Princeton", TRUE),
                       width=4
                     )
              )
            ),
            fluidRow(br(), br()),
            fluidRow(
              tags$pre("     * years above 2018 or below 1800 are considered invalid")
            )
    )
    
    
    
    
    
  )
)


ui <- dashboardPage(header, sidebar, body)





server <- function(input, output) {

  output$totalBibsValueBox <- renderValueBox({
    valueBox(
      prettyNum(TOTALBIBS, big.mark=","),
      "Bibs in ReCAP collection*‡",
      color="purple",
      icon=icon("book")
    )
  })
  output$nyplBibsValueBox <- renderValueBox({
    valueBox(
      prettyNum(validxtab[institution=="NYPL", numofbibs], big.mark=","),
      "Bibs in NYPL contribution*",
      color="red",
      icon=icon("book")
    )
  })
  output$culBibsValueBox <- renderValueBox({
    valueBox(
      prettyNum(validxtab[institution=="CUL", numofbibs], big.mark=","),
      "Bibs in Columbia University contribution*",
      color="blue",
      icon=icon("book")
    )
  })
  output$pulBibsValueBox <- renderValueBox({
    valueBox(
      prettyNum(validxtab[institution=="PUL", numofbibs], big.mark=","),
      "Bibs in Princeton University contribution*",
      color="orange",
      icon=icon("book")
    )
  })
  output$harvardBibsValueBox <- renderValueBox({
    valueBox(
      prettyNum(validxtab[institution=="HUL", numofbibs], big.mark=","),
      "Bibs in Harvard University's integration canidates",
      color="black",
      icon=icon("book")
    )
  })
  
  
  output$nyplLcPercValueBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*validxtab[institution=="NYPL", percent_valid]),
      "Percent of NYPL bibs with valid LC Call Numbers",
      color="red",
      icon=icon("genderless")
    )
  })
  output$culLcPercValueBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*validxtab[institution=="CUL", percent_valid]),
      "Percent of Columbia bibs with valid LC Call Numbers",
      color="blue",
      icon=icon("genderless")
    )
  })
  output$pulLcPercValueBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*validxtab[institution=="PUL", percent_valid]),
      "Percent of Princeton bibs with valid LC Call Numbers",
      color="orange",
      icon=icon("genderless")
    )
  })
  output$harvardLcPercValueBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*validxtab[institution=="HUL", percent_valid]),
      "Percent of Harvard candidates bibs with valid LC Call Numbers",
      color="black",
      icon=icon("genderless")
    )
  })
  output$validornotplot <- renderPlot({
    ggplot(validandinvalid, aes(y=value/1000, x=instname, fill=lccall)) +
      geom_bar(stat="identity") +
      guides(fill=guide_legend(title="")) +
      ylab("number of bibs (thousands)") +
      xlab("institution") +
      ggtitle("Proportion of valid LC Call Numbers across institutions")
  })
  
  
  
  output$broadsubjectplot <- renderPlot({
    broadscopy <- copy(broads)
    
    if(input$broad_nyplp==FALSE){ broadscopy <- broadscopy[institution!="NYPL", ] }
    if(input$broad_culp==FALSE){ broadscopy <- broadscopy[institution!="CUL", ] }
    if(input$broad_pulp==FALSE){ broadscopy <- broadscopy[institution!="PUL", ] }
    if(input$broad_harvp==FALSE){ broadscopy <- broadscopy[institution!="HUL", ] }
    
    tmp <- broadscopy[, .(total=sum(N)), broad_subject_letters][order(-total), ][1:input$broad_numberoftopsubjects, broad_subject_letters]
    smaller <- broadscopy[broad_subject_letters %in% tmp, ]

    if(input$broad_typeview=="count"){ smaller[, relvar:=N] }
    if(input$broad_typeview=="percent"){ smaller[, relvar:=100*perc] }
      
    
    ggplot(smaller, aes(x=str_wrap(broad_subject, width=10), y=relvar, fill=instname)) +
      geom_bar(stat="identity", position=position_dodge()) +
      guides(fill=guide_legend(title="Institution")) +
      xlab("Broad Subject") + ylab("") +
      coord_flip()
  }, height=700)
  
  
  
  
  
  
  output$subjectplot <- renderPlot({
    
    subjectcopy <- subjects[broad_subject_letters==input$subject_dropdown, ]
    
    
    if(input$subject_nyplp==FALSE){ subjectcopy <- subjectcopy[institution!="NYPL", ] }
    if(input$subject_culp==FALSE){ subjectcopy <- subjectcopy[institution!="CUL", ] }
    if(input$subject_pulp==FALSE){ subjectcopy <- subjectcopy[institution!="PUL", ] }
    if(input$subject_harvp==FALSE){ subjectcopy <- subjectcopy[institution!="HUL", ] }
    
    tmp <- subjectcopy[, .(total=sum(N_in_subject)), subject_letters][order(-total), ][1:input$subject_numberoftopsubjects, subject_letters]
    smaller <- subjectcopy[subject_letters %in% tmp, ]
    if(input$subject_typeview=="count"){ smaller[, relvar:=N_in_subject] }
    if(input$subject_typeview=="percent_cat"){ smaller[, relvar:=100*percent_in_category] }
    if(input$subject_typeview=="percent_inst"){ smaller[, relvar:=100*percent_in_institution] }
    
    ggplot(smaller, aes(x=str_wrap(subject, width=10), y=relvar, group=instname, fill=instname)) +
      geom_bar(stat="identity", position=position_dodge()) +
      guides(fill=guide_legend(title="Institution")) +
      coord_flip() +
      ylab(input$typeview) + xlab("LC Call Number Subject Classification")
  }, height=700)
  
  
  
  
  
  output$nyplLangPercBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*langvalidxtab[institution=="NYPL", percent_valid]),
      "Percent of NYPL bibs from which a language was extracted",
      color="red",
      icon=icon("language")
    )
  })
  output$culLangPercBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*langvalidxtab[institution=="CUL", percent_valid]),
      "Percent of Columbia bibs from which a language was extracted",
      color="blue",
      icon=icon("language")
    )
  })
  output$pulLangPercBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*langvalidxtab[institution=="PUL", percent_valid]),
      "Percent of Princeton bibs from which a language was extracted",
      color="orange",
      icon=icon("language")
    )
  })
  output$overalllanguageplot <- renderPlot({
    langs[, .(total=sum(N)), language][order(-total)][1:input$overall_numberoftoplanguages] -> tmp
    
    ggplot(tmp, aes(x=reorder(language, -total), y=total/1000)) +
      geom_bar(stat="identity") +
      ggtitle("Number of bibs of each language across all ReCAP partners") +
      xlab("language code") + ylab("bibs (in thousands)")
    
  })
  output$instlanguageplot <- renderPlot({
    langscopy <- copy(langs)
    
    if(input$instlang_nyplp==FALSE){ langscopy <- langscopy[institution!="NYPL", ] }
    if(input$instlang_culp==FALSE){ langscopy <- langscopy[institution!="CUL", ] }
    if(input$instlang_pulp==FALSE){ langscopy <- langscopy[institution!="PUL", ] }
    
    tmp <- langscopy[, .(total=sum(N)), langcode][order(-total), ][1:input$instlang_numberoftoplanguages, langcode]
    smaller <- langscopy[langcode %in% tmp, ]
    
    if(input$instlang_typeview=="count"){ smaller[, relvar:=N] }
    if(input$instlang_typeview=="percent"){ smaller[, relvar:=100*perc] }
    
    instxwalk[smaller, on="institution"] -> smaller
    
    ggplot(smaller, aes(x=language, y=relvar, fill=instname)) +
      geom_bar(stat="identity", position=position_dodge()) +
      guides(fill=guide_legend(title="Institution")) +
      xlab("Language") + ylab("") +
      coord_flip()
    
  }, height=700)
  
  
  output$nyplYearPercBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*yearvalidxtab[institution=="NYPL", percent_valid]),
      "Percent of NYPL bibs from which a publication year was extracted",
      color="red",
      icon=icon("calendar")
    )
  })
  output$culYearPercBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*yearvalidxtab[institution=="CUL", percent_valid]),
      "Percent of Columbia bibs from which a publication year was extracted",
      color="blue",
      icon=icon("calendar")
    )
  })
  output$pulYearPercBox <- renderValueBox({
    valueBox(
      sprintf("%d%%", 100*yearvalidxtab[institution=="PUL", percent_valid]),
      "Percent of Princeton bibs from which a publication year was extracted",
      color="orange",
      icon=icon("calendar")
    )
  })
  output$overallyearplot <- renderPlot({
    ggplot(years, aes(x=year, fill="pink")) +
      geom_density(alpha=.5, bw=5) +
      theme(legend.position="none") +
      ggtitle("distribution of publication years across all ReCAP partners") +
      ylab("")
  })
  output$instyearsplot <- renderPlot({
    yearscopy <- copy(years)
    
    if(input$instyear_nyplp==FALSE){ yearscopy <- yearscopy[institution!="NYPL", ] }
    if(input$instyear_culp==FALSE){ yearscopy <- yearscopy[institution!="CUL", ] }
    if(input$instyear_pulp==FALSE){ yearscopy <- yearscopy[institution!="PUL", ] }
    
    ggplot(yearscopy, aes(x=year, fill=instname)) +
      geom_density(alpha=.5, bw=5) +
      guides(fill=guide_legend(title="Institution")) +
      ggtitle("distribution of publication years by ReCAP institution") +
      ylab("")
  })
  
  
  
  
}




shinyApp(ui, server)




