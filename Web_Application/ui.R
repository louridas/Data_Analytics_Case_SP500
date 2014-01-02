shinyUI(pageWithSidebar(
  headerPanel("S&P 500 Daily Prices Web app"),
  sidebarPanel(
  HTML("<hr>"),
  HTML("<center><h2>Upload Area</h2></center><br>"),
    fileInput('file1', 'Choose CSV File',
              accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
    tags$hr(),
    checkboxInput('header', 'Header', TRUE),
    radioButtons('sep', 'Separator',
                 c(Comma=',',
                   Semicolon=';',
                   Tab='\t'),
                 'Comma'),
    radioButtons('quote', 'Quote',
                 c(None='',
                   'Double Quote'='"',
                   'Single Quote'="'"),
                 'Double Quote'),
				 HTML("<hr>"),
			numericInput("factors", "Select the number of factors:", 1),
				selectInput("rotation", "Select rotation method:", 
                choices = c("none", "varimax", "quatimax","promax","oblimin","simplimax","cluster")),
				HTML("<hr>"),
				 HTML("<center><h2>Download your dynamic report</h2></center><br>"),
  downloadButton('report'),
  HTML("<hr>")
  ),
  
  mainPanel(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    
  tabsetPanel(
  
		tabPanel("Data_Imports",HTML("<h4>Loaded data</h4><hr>"),numericInput("rows", "Select the number of rows to show:", 10),HTML("<div>Column index table</div><hr>"),tableOutput('colindex'),HTML("<div>Data Contents</div><hr>"),tableOutput('contents'),
		         conditionalPanel(
		           condition = "output.contents",HTML("<h4>Select attributes</h4><hr>"),textInput("checkdata","Check your columns consecutive e.g 1:5 or separate e.g 8 all combined with comma","")
		         ,HTML("<h4>Selected data</h4><hr>"),tableOutput('finaldata'))
		          ),
            
		tabPanel("Summary", tableOutput('summary')),
		tabPanel("Correlations",HTML("<div>** = correlation is significant at 1% level; * = correlation is significant at 5% level</div>"),tableOutput('correlation')),
      tabPanel("Scree Plot", plotOutput("plot")), 
	  tabPanel("Eigen values Table", tableOutput('eigenvalues')),
	  tabPanel("Correlation of old variables with new factors", tableOutput('cor_old_new')),
	  tabPanel("Scores", numericInput("rows1", "Select the number of rows to show:", 10),tableOutput('scores')), 
      tabPanel("Cor of Atr used in Reduction", verbatimTextOutput("intcors"))
    )
    
  )
))
