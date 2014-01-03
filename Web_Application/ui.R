
shinyUI(pageWithSidebar(
  headerPanel("S&P 500 Daily Returns App"),
  sidebarPanel(
    HTML("<center><h3>Data Upload </h3>
         <strong> Note: File must contain data matrix named ProjectData</strong>
         </center>"),
    fileInput('datafile_name', 'Choose File (R data)'),
    #tags$hr(),
    HTML("<hr>"),
    HTML("<center><strong> Note:Please go to the Parameters Tab when you change the parameters below </strong>
         </center>"),    
    HTML("<hr>"),

    ###########################################################
    # THESE ARE THE *SAME* INPUT PARAMETERS AS IN THE RunStudy.R
    numericInput("start_date", "Select Starting date (1 to number of days):", 1),
    numericInput("end_date", "Select End date (more than starting date, less than total number of dates):", 2586),
    numericInput("numb_components_used", "Select the number of PCA risk factors (between 1 and the total number of stocks):", 3),
    numericInput("use_mean_alpha", "Demean the data? (0 or 1; default is 0):", 0),
    ###########################################################
    
    HTML("<hr>"),
    HTML("<center><h3>Download the new report</h3></center>"),
    downloadButton('report'),
    HTML("<hr>")
  ),
  
  mainPanel(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    
    tabsetPanel(
      
      tabPanel("Parameters", tableOutput('parameters')),

      tabPanel("Single Stocks",
               textInput("ind_stock", "Select the ticker of the stock to show (use capital letters e.g. AAPL):", "AAPL"),
               tags$hr(),
               HTML("<div>Cumulative Returns of Selected Stock</div>"),
               plotOutput('stock_returns')
      ),
      
      tabPanel("Histogram", plotOutput('histogram')),
      tabPanel("The Market", plotOutput('market')),
      tabPanel("Market Mean Reversion", plotOutput('mr_strategy')),
      tabPanel("Ordered Stocks", 
               numericInput("stock_order", "Select the stock to plot (e.g. 1 is the best, 2 is second best, etc):", 1),
               plotOutput('chosen_stock')),
      tabPanel("Eigenvalues Plot", plotOutput("eigen_plot")),
      tabPanel("Eigenvector Returns",                
               numericInput("vector_plotted", "Select the eigenvector to plot (e.g.1):", 1),
               tags$hr(),
               HTML("<div>Cumulative Returns of Selected Eigenvector</div>"),
               plotOutput("eigen_returns")),
      tabPanel("Ordered Residuals", 
               numericInput("residuals_order", "Select the stock to plot residuals portfolio for (e.g. 1 is the best, 2 is second best, etc):", 1),
               plotOutput('chosen_residual')),
      tabPanel("Residuals Market", plotOutput('res_market')),
      tabPanel("Residuals Hindsight Portfolio", plotOutput('res_hindsight'))
    )
    
  )
))
