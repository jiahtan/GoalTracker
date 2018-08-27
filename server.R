library(shiny)
library(shinyTime)
library(DT)
library(dplyr)
library(ggplot2)

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
               'sleepTime' = format(input$timeSleep, '%H:%M'), 'workTime' = ifelse(input$dayOfWeek %in% c('Saturday', 'Sunday'), NA,format(input$timeWork, '%H:%M')), 'read' = input$read, 'bookTitle' = input$bookTitleProgress, 
               'readProgress' = input$readProgress, 'exercise' = input$exercise, 'dayOfWeek' = input$dayOfWeek))
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
      if(input$bookTitleAdd %in% BookList$data$BookTitle)
        BookList$data$DueDate[which(BookList$data$BookTitle == input$bookTitleAdd)] = input$bookFinishDate
      else
        BookList$data = rbind(BookList$data, data.frame(BookTitle = input$bookTitleAdd, DueDate = input$bookFinishDate))
    }
    else{
      BookList$data = BookList$data[-which(BookList$data$BookTitle == input$bookTitle),]
    }
    saveRDS(BookList$data, file = './Data/BookList.rds')
  })
  
  output$readProgressText = renderText({
    dat1 = ProgressDat$data[ProgressDat$data$bookTitle != 'NA',] %>% 
      group_by(bookTitle) %>% summarise(percentRead = max(readProgress))
    dat2 = cbind(bookTitle = as.character(BookList$data$BookTitle),
                 daysLeft = BookList$data$DueDate - Sys.Date())
    dat3 = merge(dat1,dat2, by = 'bookTitle')
    HTML(paste0('<br> Currently reading: <b>', as.character(dat3$bookTitle),'</b><br>',
                'Percentage completed is: <b>', dat3$percentRead, '%.</b><br>', 
                'You have <b>',dat3$daysLeft,'</b> days till deadline for completion.<br>', 
                'To be on track, you need to read about <b>', 
round((100 - dat3$percentRead)/as.numeric(as.character(dat3$daysLeft)),2), '%</b> in the remaining days.'))
  })
}

