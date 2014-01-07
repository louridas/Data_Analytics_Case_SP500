
# To be able to upload data up to 30MB
options(shiny.maxRequestSize=30*1024^2)

shinyServer(function(input, output,session) {
  
  ############################################################
  # STEP 1: Create the place to keep track of all the new variables 
  # based on the inputs of the user 
  new_values<-reactiveValues()
  
  
  ############################################################
  # STEP 2:  Read all the input variables, which are the SAME as in RunStudy.R
  # Note: When we use these variables we need to take them from input$ and
  # NOT from new_values$ !
  output$parameters<-renderTable({

    inFile <- input$datafile_name
    if (is.null(inFile))
      return(NULL)    
    load(inFile$datapath)
    new_values$start_date<-reactive({
      input$start_date
    }) 
    new_values$end_date<-reactive({
      input$end_date
    })  
    new_values$numb_components_used<-reactive({
      input$numb_components_used
    })
    new_values$use_mean_alpha<-reactive({
      input$use_mean_alpha
    })    

    ############################################################
    # STEP 3: Create the new dataset that will be used in Step 3, using 
    # the new inputs. Note that it uses only input$ variables
    
    new_values$ProjectData<-ProjectData[input$start_date:input$end_date,]
    
    ############################################################
    # STEP 4: Compute all the variables used in the Report and Slides: this
    # is more or less a "cut-and-paste" from the R chunks of the reports
    
    # MOTE: again, for the input variables we must use input$ on the right hand side, 
    # and not the new_values$ !
    
    market=apply(new_values$ProjectData,1,mean)
    names(market)<-rownames(new_values$ProjectData)
    mr_strategy = -sign(shift(market,1))*market
    names(mr_strategy)<-names(market)
    
    SP500PCA<-PCA(new_values$ProjectData, graph=FALSE)
    SP500PCA_simple<-eigen(cor(new_values$ProjectData))
    Variance_Explained_Table<-SP500PCA$eig
    SP500_Eigenvalues=Variance_Explained_Table[,1]
    
    PCA_first_component=ProjectData%*%norm1(SP500PCA_simple$vectors[,1])
    PCA_second_component=ProjectData%*%norm1(SP500PCA_simple$vectors[,2])
    
    TheFactors=SP500PCA_simple$vectors[,1:input$numb_components_used,drop=F]
    TheFactors=apply(TheFactors,2,norm1)
    TheFactors=apply(TheFactors,2,function(r)if (sum(new_values$ProjectData%*%r)<0) -r else r)
    Factor_series=new_values$ProjectData%*%TheFactors
    demean_IVs=apply(Factor_series,2,function(r)r-use_mean_alpha*mean(r))
    ProjectData_demean=apply(new_values$ProjectData,2,function(r) r-use_mean_alpha*mean(r))
    stock_betas=(solve(t(demean_IVs)%*%demean_IVs)%*%t(demean_IVs))%*%(ProjectData_demean)
    stock_alphas= use_mean_alpha*matrix(apply(ProjectData_demean,2,mean)-t(stock_betas)%*%matrix(apply(Factor_series,2,mean),ncol=1),nrow=1)
    stock_alphas_matrix=rep(1,nrow(new_values$ProjectData))%*%stock_alphas
    # make sure each residuals portfolio invests a total of 1 dollar.
    stock_betas_stock=apply(rbind(stock_betas,rep(1,ncol(stock_betas))),2,norm1)
    stock_betas=head(stock_betas_stock,-1) # last one is the stock weight
    stock_weight=rep(1,nrow(new_values$ProjectData))%*%tail(stock_betas_stock,1)
    Stock_Residuals=stock_weight*new_values$ProjectData-(Factor_series%*%stock_betas + stock_alphas_matrix)
    colnames(Stock_Residuals)<-colnames(new_values$ProjectData)
    mr_Stock_Residuals=-sign(shift(Stock_Residuals,1))*Stock_Residuals
    selected_strat_res=apply(mr_Stock_Residuals,2,function(r) if (sum(r)<0) -r else r)
    
    res_market=apply(Stock_Residuals,1,mean)
    names(res_market)<-names(market)
    selected_mr_market_res=apply(selected_strat_res,1,mean)
    names(selected_mr_market_res)<-names(market)
    
    ############################################################
    # STEP 5: Store all new calculated variables in new_values$ so that the tabs 
    # read them directly. 
    # NOTE: the tabs below do not do many calculations as they are all done in Step 4
    
    new_values$market<-market
    new_values$mr_strategy<-mr_strategy
    new_values$SP500PCA<-SP500PCA
    new_values$SP500PCA_simple<-SP500PCA_simple
    new_values$PCA_first_component<-PCA_first_component
    new_values$PCA_second_component<-PCA_second_component
    
    new_values$SP500_Eigenvalues<-SP500_Eigenvalues
    new_values$Stock_Residuals<-Stock_Residuals
    new_values$res_market<-res_market
    new_values$selected_mr_market_res<-selected_mr_market_res

    #############################################################
    # STEP 5b: Print whatever basic information about the selected data needed. 
    # THese will show in the first tab of the application (called "parameters")
    
    allparameters=c(rownames(ProjectData)[input$start_date],rownames(ProjectData)[input$end_date],
                    nrow(new_values$ProjectData),ncol(new_values$ProjectData), input$numb_components_used,colnames(new_values$ProjectData))
    allparameters<-matrix(allparameters,ncol=1)    
    rownames(allparameters)<-c("start date", "end date", "number of days", 
                               "number of stocks", "number of PCA components used",
                               paste("Stock:",1:ncol(new_values$ProjectData)))
    colnames(allparameters)<-NULL
    allparameters<-as.data.frame(allparameters)
    return(allparameters)   
  })
  
  ############################################################
  # STEP 6: These are now just the outputs of the various tabs. There
  # is one output per tab, plot or table or... (type help(renredPlot) for example
  # to see various options) 
  
  output$stock_returns <- renderPlot({        
    stockx=new_values$ProjectData[,input$ind_stock,drop=F]
    rownames(stockx)<-rownames(new_values$ProjectData)
    pnl_plot(stockx)    
  })
  
  output$histogram<-renderPlot({    
    hist(new_values$ProjectData,main="Histogram of All Daily Stock Returns",xlab="Daily Stock Returns (%)", breaks=200)
  })
  
  output$market <- renderPlot({    
    pnl_plot(new_values$market)    
  })
  
  output$mr_strategy <- renderPlot({        
    pnl_plot(new_values$mr_strategy)
  })
  
  output$chosen_stock <- renderPlot({    
    tmp=apply(new_values$ProjectData,2,sum)
    chosen_id=sort(tmp,decreasing=TRUE,index.return=TRUE)$ix[input$stock_order]
    chosen_stock=new_values$ProjectData[,chosen_id,drop=F]
    rownames(chosen_stock)<-rownames(new_values$ProjectData)
    pnl_plot(chosen_stock)
  })
  
  output$eigen_plot <- renderPlot({    
    plot(new_values$SP500_Eigenvalues,main="The S&P 500 Daily Returns Eigenvalues", ylab="Value")
  })
  
  output$eigen_returns <- renderPlot({   
    ###### Just load all necessary variables so that we can use the code as is from the report
    ProjectData<-new_values$ProjectData
    market<-new_values$market
    SP500PCA_simple<-new_values$SP500PCA_simple
    ######
    
    # Note the abuse of the variable name: it does not need to be the first eigenvector
    PCA_first_component=ProjectData%*%norm1(SP500PCA_simple$vectors[,input$vector_plotted])
    if(sum(PCA_first_component)<0) {PCA_first_component=-PCA_first_component; flipped_sign=-1} else {flipped_sign=1}
    names(PCA_first_component)<-names(market)
    
    pnl_plot(PCA_first_component)
  })
  
  output$chosen_residual <- renderPlot({    
    tmp=apply(new_values$Stock_Residuals,2,sum)
    chosen_id=sort(tmp,decreasing=TRUE,index.return=TRUE)$ix[input$residuals_order]
    chosen_stock=new_values$Stock_Residuals[,chosen_id,drop=F]
    rownames(chosen_stock)<-names(new_values$market)
    pnl_plot(chosen_stock)
  })
  
  output$res_market <- renderPlot({    
    pnl_plot(new_values$res_market)  
  })
  
  output$res_hindsight <- renderPlot({    
    pnl_plot(new_values$selected_mr_market_res)
  })
  
  
  ############################################################
  # STEP 7: There are again outputs, but they are "special" one as
  # they produce the reports and slides. See the internal structure 
  # for both of them - which is the same for both.

  # The new report 
  
  output$report = downloadHandler(
    filename <- function() {paste(paste('SP500_Report',Sys.time() ),'.html')},
    
    content = function(file) {
      
      filename.Rmd <- paste('SP500_Report', 'Rmd', sep=".")
      filename.md <- paste('SP500_Report', 'md', sep=".")
      filename.html <- paste('SP500_Report', 'html', sep=".")
      
      #############################################################
      # All the (SAME) parameters that the report takes from RunStudy.R
      ProjectData<-new_values$ProjectData
      numb_components_used <- input$numb_components_used
      use_mean_alpha <- input$use_mean_alpha
      PCA_first_component<- new_values$PCA_first_component
      PCA_second_component<- new_values$PCA_second_component
      market<-new_values$market
      #############################################################
      
      if (file.exists(filename.html))
        file.remove(filename.html)
      unlink(".cache", recursive=TRUE)      
      unlink("assets", recursive=TRUE)      
      unlink("figures", recursive=TRUE)      
      
      file.copy("../doc/SP500_Report.Rmd",filename.Rmd,overwrite=T)
      out = knit2html(filename.Rmd,quiet=TRUE)
      
      unlink(".cache", recursive=TRUE)      
      unlink("assets", recursive=TRUE)      
      unlink("figures", recursive=TRUE)      
      file.remove(filename.Rmd)
      file.remove(filename.md)
      
      file.rename(out, file) # move pdf to file for downloading
    },    
    contentType = 'application/pdf'
  )
  
  # The new slide 
  
  output$slide = downloadHandler(
    filename <- function() {paste(paste('SP500_Slides',Sys.time() ),'.html')},
    
    content = function(file) {
      
      filename.Rmd <- paste('SP500_Slides', 'Rmd', sep=".")
      filename.md <- paste('SP500_Slides', 'md', sep=".")
      filename.html <- paste('SP500_Slides', 'html', sep=".")
      
      #############################################################
      # All the (SAME) parameters that the report takes from RunStudy.R
      ProjectData<-new_values$ProjectData
      numb_components_used <- input$numb_components_used
      use_mean_alpha <- input$use_mean_alpha
      PCA_first_component<- new_values$PCA_first_component
      PCA_second_component<- new_values$PCA_second_component
      market<-new_values$market
      #############################################################
      
      if (file.exists(filename.html))
        file.remove(filename.html)
      unlink(".cache", recursive=TRUE)     
      unlink("assets", recursive=TRUE)    
      unlink("figures", recursive=TRUE)      
      
      file.copy("../doc/SP500_Slides.Rmd",filename.Rmd,overwrite=T)
      slidify(filename.Rmd)
      
      unlink(".cache", recursive=TRUE)     
      unlink("assets", recursive=TRUE)    
      unlink("figures", recursive=TRUE)      
      file.remove(filename.Rmd)
      file.remove(filename.md)
      file.rename(filename.html, file) # move pdf to file for downloading      
      },    
    contentType = 'application/pdf'
  )
  
})
