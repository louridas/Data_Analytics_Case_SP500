
# To be able to upload data up to 30MB
options(shiny.maxRequestSize=30*1024^2)

shinyServer(function(input, output,session) {
  
  #Note: Keep track of all the variables in final$varname...  
  final<-reactiveValues()
  
    
  output$parameters<-renderTable({
    ######################################
    # Just load here all the input variables, like in RunStudy.R
    inFile <- input$datafile_name
    if (is.null(inFile))
      return(NULL)    
    load(inFile$datapath)
    final$start_date<-reactive({
      input$start_date
    }) 
    final$end_date<-reactive({
      input$end_date
    })  
    final$numb_components_used<-reactive({
      input$numb_components_used
    })
    final$use_mean_alpha<-reactive({
      input$use_mean_alpha
    })    
    ######################################
    
    ######################################
    # Compute all necessary variables here, all at once
    final$ProjectData<-ProjectData[input$start_date:input$end_date,]
    
    market=apply(final$ProjectData,1,mean)
    names(market)<-rownames(final$ProjectData)
    mr_strategy = -sign(shift(market,1))*market
    names(mr_strategy)<-names(market)
    SP500PCA<-PCA(final$ProjectData, graph=FALSE)
    SP500PCA_simple<-eigen(cor(final$ProjectData))
    
    TheFactors=SP500PCA_simple$vectors[,1:input$numb_components_used,drop=F]
    TheFactors=apply(TheFactors,2,norm1)
    TheFactors=apply(TheFactors,2,function(r)if (sum(final$ProjectData%*%r)<0) -r else r)
    Factor_series=final$ProjectData%*%TheFactors
    demean_IVs=apply(Factor_series,2,function(r)r-use_mean_alpha*mean(r))
    ProjectData_demean=apply(final$ProjectData,2,function(r) r-use_mean_alpha*mean(r))
    stock_betas=(solve(t(demean_IVs)%*%demean_IVs)%*%t(demean_IVs))%*%(ProjectData_demean)
    stock_alphas= use_mean_alpha*matrix(apply(ProjectData_demean,2,mean)-t(stock_betas)%*%matrix(apply(Factor_series,2,mean),ncol=1),nrow=1)
    stock_alphas_matrix=rep(1,nrow(final$ProjectData))%*%stock_alphas
    # make sure each residuals portfolio invests a total of 1 dollar.
    stock_betas_stock=apply(rbind(stock_betas,rep(1,ncol(stock_betas))),2,norm1)
    stock_betas=head(stock_betas_stock,-1) # last one is the stock weight
    stock_weight=rep(1,nrow(final$ProjectData))%*%tail(stock_betas_stock,1)
    Stock_Residuals=stock_weight*final$ProjectData-(Factor_series%*%stock_betas + stock_alphas_matrix)
    
    mr_Stock_Residuals=-sign(shift(Stock_Residuals,1))*Stock_Residuals
    selected_strat_res=apply(mr_Stock_Residuals,2,function(r) if (sum(r)<0) -r else r)
    selected_mr_market_res=apply(selected_strat_res,1,mean)
    names(selected_mr_market_res)<-names(market)
    
    final$market<-market
    final$mr_strategy<-mr_strategy
    final$SP500PCA<-SP500PCA
    final$SP500PCA_simple<-SP500PCA_simple
    final$Stock_Residuals<-Stock_Residuals
    final$selected_mr_market_res<-selected_mr_market_res
    ######################################        
        
    #allparameters<-matrix(c(input$start_date,input$end_date,ncol(final$ProjectData)),ncol=1)
    allparameters<-matrix(c(rownames(ProjectData)[input$start_date],rownames(ProjectData)[input$end_date],ncol(final$ProjectData), input$numb_components_used),ncol=1)
    rownames(allparameters)<-c("start date", "end date", "number of stocks", "number of PCA components used")
    allparameters<-as.data.frame(allparameters)
    return(allparameters)
   
  })

  ################################################
  # These are the outputs of the various tabs etc

  output$stock_returns <- renderPlot({        
    ###### Just load all necessary variables so that we can use the code as is from the report
    ProjectData<-final$ProjectData
    ######
    stockx=ProjectData[,input$ind_stock]
    names(stockx)<-rownames(ProjectData)
    pnl_plot(stockx)    
  })
  
  output$histogram<-renderPlot({    
    ###### Just load all necessary variables so that we can use the code as is from the report
    ProjectData<-final$ProjectData
    ######
    hist(ProjectData,main="Histogram of All Daily Stock Returns",xlab="Daily Stock Returns (%)", breaks=200)
  })
  
  output$market <- renderPlot({    
    pnl_plot(final$market)    
  })
  
  output$mr_strategy <- renderPlot({        
    pnl_plot(final$mr_strategy)
  })
  
  output$chosen_stock <- renderPlot({    
    ###### Just load all necessary variables so that we can use the code as is from the report
    ProjectData<-final$ProjectData
    ######
    tmp=apply(ProjectData,2,sum)
    chosen_id=sort(tmp,decreasing=TRUE,index.return=TRUE)$ix[input$stock_order]
    chosen_stock=ProjectData[,chosen_id]
    names(chosen_stock)<-names(final$market)
    # Need to fix this
    cat(colnames(final$ProjectData)[chosen_id])
    pnl_plot(chosen_stock)
  })
  
  output$eigen_plot <- renderPlot({    
    ###### Just load all necessary variables so that we can use the code as is from the report
    SP500PCA<-final$SP500PCA
    ######
    Variance_Explained_Table<-SP500PCA$eig
    SP500_Eigenvalues=Variance_Explained_Table[,1]
    plot(SP500_Eigenvalues,main="The S&P 500 Daily Returns Eigenvalues", ylab="Value")
  })
  
  output$eigen_returns <- renderPlot({   
    ###### Just load all necessary variables so that we can use the code as is from the report
    ProjectData<-final$ProjectData
    market<-final$market
    SP500PCA_simple<-final$SP500PCA_simple
    ######
    
    # Note the abuse of the variable name: it does not need to be the first eigenvector
    PCA_first_component=ProjectData%*%norm1(SP500PCA_simple$vectors[,input$vector_plotted])
    if(sum(PCA_first_component)<0) {PCA_first_component=-PCA_first_component; flipped_sign=-1} else {flipped_sign=1}
    names(PCA_first_component)<-names(market)
    
    pnl_plot(PCA_first_component)
    
    #component_weights=flipped_sign*norm1(SP500PCA_simple$vectors[,input$vector_plotted])
    #names(component_weights)<-colnames(final$ProjectData)
    #final$component_weights<-component_weights
    #plot(final$component_weights,ylab="Component Weights",xlab="Stock",main="Component Weights on Stocks")
    
  })
  
  output$chosen_residual <- renderPlot({    
    ###### Just load all necessary variables so that we can use the code as is from the report
    Stock_Residuals<-final$Stock_Residuals
    ######
    tmp=apply(Stock_Residuals,2,sum)
    chosen_id=sort(tmp,decreasing=TRUE,index.return=TRUE)$ix[input$residuals_order]
    chosen_stock=Stock_Residuals[,chosen_id]
    names(chosen_stock)<-names(final$market)
    # Need to fix this
    cat(colnames(final$ProjectData)[chosen_id])

    pnl_plot(chosen_stock)
  })
  
  output$res_market <- renderPlot({    
    ###### Just load all necessary variables so that we can use the code as is from the report
    market<-final$market
    Stock_Residuals<-final$Stock_Residuals
    ######
    
    res_market=apply(Stock_Residuals,1,mean)
    names(res_market)<-names(market)
    final$res_market<-res_market
    pnl_plot(res_market)  
  })
  
  output$res_hindsight <- renderPlot({    
    pnl_plot(final$selected_mr_market_res)
  })
  
  
  # The new report
  
  output$report = downloadHandler(
    filename <- function() {paste(paste('SP500_Report',Sys.time() ),'.html')},
    content = function(file) {
      #############################################################
      # All the parameters that the report takes from RunStudy.R
      ProjectData<-final$ProjectData
      numb_components_used <- input$numb_components_used
      use_mean_alpha <- input$use_mean_alpha
      #############################################################

      out = knit2html('WebApp_Report.Rmd')
      file.rename(out, file) # move pdf to file for downloading
    },    
    contentType = 'application/pdf'
  )
  
  
})
