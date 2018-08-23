library(shiny)
library(shinyTime)
library(DT)

BookList = reactiveValues(data = readRDS(file = './Data/BookList.rds'))
ProgressDat = reactiveValues(data = readRDS(file = './Data/ProgressData.rds'))

server <- function(input, output, session) {

  output$bookTitleProgressUI =renderUI({
    selectInput("bookTitleProgress", 'Book Title', 
                choices = c(as.character(BookList$data$BookTitle),NA), selected = NA)
  })
  
  output$bookTitleUI =renderUI({
    selectInput("bookTitle", 'Book Title', 
                choices = BookList$data$BookTitle)
  })
  
  observeEvent(input$action, {
    ProgressDat$data = rbind(ProgressDat$data,data.frame('Date' = input$date, 'wakeupTime' = format(input$timeWakeup, '%H:%M'), 
               'sleepTime' = format(input$timeSleep, '%H:%M'), 'workTime' = format(input$timeWork, '%H:%M'), 'read' = input$read, 'bookTitle' = input$bookTitleProgress, 
               'readProgress' = input$readProgress, 'exercise' = input$exercise))
    saveRDS(ProgressDat$data, file = './Data/progressData.rds')
    output$dataText <- renderText({
      'Data Recorded'
    })
  })
    
  output$readingListTable = DT::renderDataTable({
    BookList$data
  })
  
  observeEvent(input$bookSubmit, {
    if(input$readingListAction == 'Add'){
      BookListChange = rbind(BookList$data, data.frame(BookTitle = input$bookTitleAdd, DueDate = input$bookFinishDate))
    }
    else{
      BookListChange = BookList$data[-which(BookList$data$BookTitle == input$bookTitle),]
    }
    BookList$data = BookListChange
    saveRDS(BookList$data, file = './Data/BookList.rds')
  })
}