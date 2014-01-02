
shinyUI(pageWithSidebar(
  headerPanel("S&P 500 Daily Returns App"),
  sidebarPanel(
    HTML("<hr>"),
    HTML("<center><h3>Data Upload </h3></center><br>"),
    fileInput('file1', 'Choose File (R data)'),
    tags$hr(),
    HTML("<hr>"),
    numericInput("start_date", "Select Starting date (e.g. 1):", 1),
    numericInput("end_date", "Select End date (e.g. 2586):", 2586),
    numericInput("numb_components_used", "Select the number of PCA risk factors:", 3),

    tags$hr(),
    HTML("<hr>"),

    HTML("<center><h3>Download your report</h3></center><br>"),
    downloadButton('report'),
    HTML("<hr>")
  ),
  
  mainPanel(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    
    tabsetPanel(
      
      tabPanel("Single Stocks",
               textInput("ind_stock", "Select the stock to show (e.g. AAPL):", ),
               tags$hr(),
               HTML("<div>Cumulative Returns of Selected Stock</div>"),
               plotOutput('stock_returns')
      ),
      
      tabPanel("Histogram", plotOutput('histogram')),
      tabPanel("The Market", plotOutput('market')),
      tabPanel("Market Mean Reversion", plotOutput('mr_market')),
      tabPanel("Best Stock", plotOutput('best_stocks')),
      tabPanel("Worst Stock", plotOutput('best_stocks')),
      tabPanel("Eigenvalues Plot", plotOutput("eigen_plot")),
      tabPanel("Eigenvector Returns",                
               numericInput("vector_plotted", "Select the eigenvector to plot (e.g.1):", 1),
               tags$hr(),
               HTML("<div>Cumulative Returns of Selected Eigenvector</div>"),
               plotOutput("eigen_returns")),
      tabPanel("Residuals Market", plotOutput('res_market')),
      tabPanel("Residuals Hindsight Portfolio", plotOutput('res_hindsight'))
    )
    
  )
))
