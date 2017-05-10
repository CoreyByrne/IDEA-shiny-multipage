library(shiny)
library(shinyjs)

# generic viewer
viewer <- function(id, ...) {
  return(div(
    id=id,
    class="viewer",
    ...
  ))
}

# plot viewer, which had more functionality
# but has since moved into the main function
plotViewer <- function(id) {
  return(fillPage(div(
    id=id,
    class="viewer",
    plotlyOutput(outputId = id, width = "100%", height = "100%")
  )))
}

# the function called from outside the controller
createMultipageServer <- function(controller, ...) {
  args <- list(...)
  
  
  controlledInput = reactiveValues()
  
  # server maps input to output
  server <- function(input, output, session) {
    observe({
      for(opt in names(input)) {
        if(opt != "viewer" && input$viewer == "Controller") {
          controlledInput[[opt]] = input[[opt]]
        }
      }
    })
  
    for(o in names(args)) {
      output[[o]] <- eval(parse(text = paste0("renderPlotly({
        args$", o, "(controlledInput)
      })")))
    }
  }

  e = "div(id = \"viewers\", class = \"container\", controller"
  for(i in 1:length(names(args))) {
    e = paste0(e, ", plotViewer(names(args)[[", i, "]])")
  }
  e = paste0(e, ")")
  viewers = eval(parse(text=e))
  
  # ui is the page itself
  ui <- bootstrapPage(
    useShinyjs(),
    includeScript('www/multipage.js'),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "multipage.css")
    ),
    selectInput(inputId = "viewer",
    label = "Viewer:",
    choices = c("-", "Controller", names(args)),
    selected = "-"),
    viewers
  )

  return(list(ui = ui, server = server))
}