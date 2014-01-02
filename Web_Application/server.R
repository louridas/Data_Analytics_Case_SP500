options(shiny.maxRequestSize=30*1024^2)

shinyServer(function(input, output,session) {
  
  start_date<-reactive({
    input$start_date
  })
  
  end_date<-reactive({
    input$end_date
  })
  
  numb_components_used<-reactive({
    input$numb_components_used
  })
  
  values <- reactiveValues()
  
  output$histogram<-renderPlot({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    
    load(inFile$datapath)
    values$thedata<-ProjectData
    ProjectData_app<-values$thedata[input$start_date:input$end_date,]
    
    hist(ProjectData_app,breaks=200)
    
  })
  
  output$stock_returns <- renderPlot({    
    stockx=ProjectData_app[,input$ind_stock]
    names(stockx)<-rownames(values$thedata)
    pnl_plot(stockx)    
  })
  
  output$market <- renderPlot({    
    market=apply(ProjectData_app,1,mean)
    names(market)<-rownames(ProjectData_app)
    pnl_plot(market)    
  })
  
  output$bw_stocks <- renderPlot({    
    best_stock=which.max(apply(ProjectData_app,2,sum))
    worst_stock=which.min(apply(ProjectData_app,2,sum))
    pnl_plot(ProjectData_app[,best_stock])
    pnl_plot(ProjectData_app[,worst_stock])
  })
  
  output$mr_strategy <- renderPlot({        
    mr_strategy = -sign(shift(market,1))*market
    names(x)<-rownames(ProjectData_app)
    pnl_plot(mr_strategy)
  })
  
  output$eigen_plot <- renderPlot({    
    SP500PCA<-PCA(ProjectData_app, graph=FALSE)
    Variance_Explained_Table<-SP500PCA$eig
    SP500_Eigenvalues=Variance_Explained_Table[,1]
    plot(SP500_Eigenvalues,main="The S&P 500 Daily Returns Eigenvalues", ylab="Value")
  })
  
  output$res_market <- renderPlot({    
    TheFactors=SP500PCA_simple$vectors[,1:numb_components_used]
    TheFactors=apply(TheFactors,2,norm1)
    TheFactors=apply(TheFactors,2,function(r)if (sum(ProjectData%*%r)<0) -r else r)
    Factor_series=ProjectData%*%TheFactors
    demean_IVs=apply(Factor_series,2,function(r)r-use_mean_alpha*mean(r))
    ProjectData_demean=apply(ProjectData,2,function(r) r-use_mean_alpha*mean(r))
    stock_betas=(solve(t(demean_IVs)%*%demean_IVs)%*%t(demean_IVs))%*%(ProjectData_demean)
    stock_alphas= use_mean_alpha*matrix(apply(ProjectData_demean,2,mean)-t(stock_betas)%*%matrix(apply(Factor_series,2,mean),ncol=1),nrow=1)
    stock_alphas_matrix=rep(1,nrow(ProjectData))%*%stock_alphas
    # make sure each residuals portfolio invests a total of 1 dollar.
    stock_betas_stock=apply(rbind(stock_betas,rep(1,ncol(stock_betas))),2,norm1)
    stock_betas=head(stock_betas_stock,-1) # last one is the stock weight
    stock_weight=rep(1,nrow(ProjectData))%*%tail(stock_betas_stock,1)
    Stock_Residuals=stock_weight*ProjectData-(Factor_series%*%stock_betas + stock_alphas_matrix)
    res_market=apply(Stock_Residuals,1,mean)
    names(res_market)<-names(market)
    pnl_plot(res_market)
    
  })
  
  output$res_hindsight <- renderPlot({    
    selected_strat_res=apply(mr_Stock_Residuals,2,function(r) if (sum(r)<0) -r else r)
    selected_mr_market_res=apply(selected_strat_res,1,mean)
    names(selected_mr_market_res)<-names(market)
    pnl_plot(selected_mr_market_res)
  })
  
  
  output$report = downloadHandler(
    filename = 'WebApp_Report.html',
    content = function(file) {
      out = knit2html('WebApp_Report.Rmd')
      file.rename(out, file) # move pdf to file for downloading
    },    
    contentType = 'application/pdf'
  )
  
  
})
