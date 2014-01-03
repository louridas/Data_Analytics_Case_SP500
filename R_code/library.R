# Required R libraries (need to be installed - it can take a few minutes the first time you run the project)

if (require(devtools)==FALSE){install.packages("devtools"); library(devtools)}
if (require(slidifyLibraries)==FALSE){install_github("slidifyLibraries", "ramnathv"); library(slidifyLibraries)}
if (require(slidify)==FALSE){install_github("slidify", "ramnathv")}; library(slidify)
if (require(shiny)==FALSE){install.packages("shiny")}; library(shiny)
if (require(knitr)==FALSE){install.packages("knitr")}; library(knitr)

if (require(graphics)==FALSE){install.packages("graphics")}; library(graphics)
if (require(grDevices)==FALSE){install.packages("grDevices")}; library(grDevices)
if (require(xtable)==FALSE){install.packages("xtable")}; library(xtable)

if (require(FactoMineR)==FALSE){install.packages("FactoMineR")}; library(FactoMineR)


########################################################

sharpe<-function(x,exclude_zero=(x!=0))round(16*mean(drop(x[exclude_zero]))/sd(drop(x[exclude_zero])),digits=1)
bps<-function(x,exclude_zero=(x!=0))round(100*mean(drop(x[exclude_zero])),digits=1)
gain_ratio<-function(x)round(sum(x>0)/sum(x!=0),digits=2)
drawdown<-function(x)round(max(cummax(cumsum(x))-cumsum(x)),digits=2)

pnl_stats<-function(x){
  if(class(x)=="matrix")if(ncol(x)>1)x<-x[,1]
  c(sum=round(sum(x),digits=2),bps=bps(x),sharpe=sharpe(x),dd=drawdown(x),gain_ratio=gain_ratio(x))
}

pnl_plot<-function(x,...){
  ylab<-deparse(substitute(x))
  if(class(x)=="matrix")if(ncol(x)>1)x<-x[,1,drop=FALSE]
  if(class(x)!="matrix") x<-matrix(x,ncol=1,dimnames=list(names(x),NULL))
  assetname=ifelse (is.null(colnames(x)),"",paste(colnames(x),": ",sep=""))
  main<-paste(assetname,paste(names(pnl_stats(x)),pnl_stats(x),sep=":",collapse=" "),sep=" ")
  plot(cumsum(x),type="l",ylab="Percent Return",xlab="Date",main=main,axes=FALSE,...)
  if(!is.null(rownames(x))){
    axis(1,at=seq(1,nrow(x),length.out=5),labels=rownames(x)[seq(1,nrow(x),length.out=5)])
    axis(2)
  } else { axis(1); axis(2)}
}



norm1<-function(x)if(sum(abs(x))>0) return(x/sum(abs(x))) else return(x)
shift<-function(a,n=1,filler=0){
  x<-switch(class(a),matrix=a,matrix(a,ncol=1,dimnames=list(names(a),NULL)))
  if(n==0)return(x)
  if(n>0){
    rbind(matrix(filler,ncol=ncol(x),nrow=n),head(x,-n)) 
  } else {
    rbind(tail(x,n),matrix(filler,ncol=ncol(x),nrow=abs(n)))
  }
}
