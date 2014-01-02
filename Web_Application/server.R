shinyServer(function(input, output,session) {
  
  rotationInput <- reactive({
    switch(input$rotation,
           "none" = none,
           "varimax" = varimax,
           "promax" = promax,
		   "oblimin" = oblimin,
		   "simplimax" = simplimax,
		   "cluster" = cluster)
  })
  
  factornum<-reactive({
  input$factors
  })
	values <- reactiveValues()
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects and uploads a 
    # file, it will be a data frame with 'name', 'size', 'type', and 'datapath' 
    # columns. The 'datapath' column will contain the local filenames where the 
    # data can be found.

    inFile <- input$file1

    if (is.null(inFile))
      return(NULL)
    
   values$thedata<-read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
	
	values$thedata[1:input$rows,]
	
  })
  
  output$cols<-renderPrint({
    ncol(values$thedata)
  })
  
 final<-reactiveValues()
  
  output$finaldata<-renderTable({
    
    cc<-input$checkdata
    cc<-paste("c(",cc,")",sep="")
    cc<-eval(parse(text=cc))
    fdata<-values$thedata[1:input$rows,cc]
    final$thedata<-as.data.frame(values$thedata[,cc])
    return(fdata)
   
  })
  output$colindex<-renderTable({
    coll<-t(c(1:ncol(values$thedata)))
    name<-colnames(values$thedata)
    return(rbind(name,coll))
  })
  
  
  output$intcors<-renderPrint({
  corthres = 0.4
final$thedata<-as.data.frame(final$thedata)
the_correlation = cor(final$thedata)
for (i in 1:(ncol(final$thedata) - 1)) {
    thecori = cor(final$thedata[, i], final$thedata)
    useonly = setdiff(which(abs(thecori) > corthres), i)
    labels_used = colnames(final$thedata)[useonly]
    thecori = matrix(thecori[useonly], nrow = 1)
    colnames(thecori) <- labels_used
    cat("\nAttribute", colnames(final$thedata)[i], "has these correlations above", 
        corthres, ": ")
    if (length(thecori) == 0) 
        cat("No Large Correlations") else sapply(1:ncol(thecori), function(j) cat(colnames(thecori)[j], ":", 
        thecori[j], ","))
}
  })
  
  
  output$summary<-renderTable({
  rotationInput()
  id <- sapply(final$thedata, is.factor)
  # Convert to numeric
  final$thedata[id] <- lapply(final$thedata[id], as.numeric)
  
  summary(final$thedata)
  })
  
  output$correlation<-renderTable({
    require(Hmisc)
    x <- as.matrix(final$thedata)
    R <- rcorr(x)$r
    p <- rcorr(x)$P
    mystars <- ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", "  "))
    R <- format(round(cbind(rep(-1.111, ncol(x)), R), 3))[,-1]
    Rnew <- matrix(paste(R, mystars, sep=""), ncol=ncol(x))
    diag(Rnew) <- paste(diag(R), "", sep = "")
    rownames(Rnew) <- colnames(x)
    colnames(Rnew) <- paste(colnames(x), "", sep = "")
    Rnew <- as.data.frame(Rnew)
    return(Rnew)
    
  })
  output$eigenvalues<-renderTable({
  rotationInput()
  if (require(FactoMineR)==FALSE){install.packages("FactoMineR")}
library(FactoMineR)
  thedata<-final$thedata
  result <- PCA(thedata,graph=FALSE)
  eigenvalues<-result$eig
print(eigenvalues)
  })
  
  output$cor_old_new<-renderTable({
  factornum()
  if (require(FactoMineR)==FALSE){install.packages("FactoMineR")}
library(FactoMineR)
  thedata<-final$thedata
  result <- PCA(thedata,ncp=input$factors,graph=FALSE)
  corfactor <- result$var$cor
corfactornew<-as.data.frame(corfactor)
print(corfactornew)
  })
  
  output$scores<-renderTable({
  rotationInput()
  factornum()
   if (require(FactoMineR)==FALSE){install.packages("FactoMineR")}
library(FactoMineR)
  thedata<-final$thedata
  result <- PCA(thedata,graph=FALSE)
 if (require(psych)==FALSE){install.packages("psych")}
library(psych)
fa<-principal(thedata, nfactors=input$factors, rotate=paste(input$rotation))
 factormatrix <- fa$scores
facmat<-as.data.frame(factormatrix[1:input$rows1,])
print(facmat)
  
  })
  
  
  output$plot<-renderPlot({
  library(FactoMineR)
  if (require(ggplot2)==FALSE){install.packages("ggplot2")}
library(ggplot2)
  result <- PCA(final$thedata, graph=FALSE) # graphs generated automatically

# %interpretation of components
eigenvalues<-result$eig

# eigen values plot
x<-ggplot() +
  geom_line(aes(x = 1:length(eigenvalue),y = eigenvalue),data=eigenvalues,fun.data = mean_sdl,mult = 1,stat = 'summary') +
  xlab(label = 'Number of Factors') +
  ylab(label = 'Eigenvalues') +
  ggtitle(label = 'Scree Plot') +
  theme_classic() +
  theme_grey() +
  theme_bw() +
  theme_grey() +
  coord_cartesian(xlim = c(0 ,29),ylim = c(0,10)) +
  stat_abline(data=eigenvalues,intercept = 1.0,slope = 0.0,colour = '#00cc33',size = 1.0) +
  geom_point(aes(x = 1:length(eigenvalue),y = eigenvalue),data=eigenvalues,colour = '#3333ff')
print(x)
  
  })
  
  output$report = downloadHandler(
    filename = 'factor.html',
    
    content = function(file) {
      out = knit2html('WebApp_Report.Rmd')
      file.rename(out, file) # move pdf to file for downloading
    },
    
    contentType = 'application/pdf'
  )
  
  
})
