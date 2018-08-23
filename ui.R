library(shiny)
library(shinyTime)

# Define UI for application that draws a histogram
ui <- navbarPage("Goal Tracker",
                 tabPanel("Goal Data Updater" ,
                          sidebarLayout(
                            sidebarPanel(
                              dateInput('date',label = 'Date',value = Sys.Date()),
                              timeInput("timeWakeup", "Wake up time:",seconds = FALSE, value = strptime("07:00:00", "%T") ),
                              timeInput('timeSleep','Sleep time', seconds = FALSE, value = strptime("23:00:00", "%T")),
                              timeInput('timeWork', 'Work time', second = FALSE, value = strptime("09:00:00", "%T")),
                              radioButtons("read", "Read book?",
                                           choices = list("Yes", "No"),selected = 'Yes'),
                              conditionalPanel(
                                condition = "input.read == 'Yes'",
                                uiOutput('bookTitleProgressUI'),
                                sliderInput("readProgress", h3("% of book read today."),
                                            min = 0, max = 100, value = 0)
                              ),
                              radioButtons("exercise", "Exercise?",
                                           choices = list("Yes", "No"),selected = 'No'),
                              actionButton("action", "Submit"),
                              textOutput('dataText')
                            ),
                            
                            mainPanel(
                            )
                          )
                 ),
                 tabPanel("Reading List Editor",
                          
                          sidebarLayout(
                            
                            sidebarPanel(
                              selectInput("readingListAction", "Changes to Reading List", 
                                          choices = list("Add Item" = 'Add', "Delete Item" = 'Delete'), selected = 'Add'),
                              conditionalPanel(
                                condition = "input.readingListAction == 'Add'",
                                textInput("bookTitleAdd", label = NULL,value = "Enter book title."),
                                dateInput('bookFinishDate',
                                          label = 'Expected Finish Date',
                                          value = Sys.Date())),
                              conditionalPanel(
                                condition = "input.readingListAction == 'Delete'",
                                uiOutput('bookTitleUI')
                              ),
                              actionButton("bookSubmit", "Submit")
                            ),
                            
                            mainPanel(
                              h3("Reading List"),
                              DT::dataTableOutput("readingListTable")
                            )
                          )
                 )
)