#
#  Code developed for the paper "Regularized Robust Portfolio Estimation"
#
#  Copyright 2012-2013 Theodoros Evgeniou, Massimiliano Pontil,
#                      Diomidis Spinellis, Rafal Swiderski, and
#                      Nick Nassuphis.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

##############################################################################
# This file can be used independently to generate new data from yahoo finance
# IT IS NOT USED BY THE PROJECT CODE OR WEB APPLICATION
##############################################################################

rm(list=ls()); library("quantmod") # Note: for R versio 3.0.0 this library does not work yet. Earlier versions are fine

datafile= "NewProjectData" 
Starting_Date="2003-01-01"

getdata.fromscratch=0 # set to 1 if we want to re-download the data from Yahoo!. if 0 it

################################################################################################
################################################################################################
# all S&P500 as of February 2013 from http://www.standardandpoors.com/login with free registration
SP500stocks=c("MMM","ACE","AES","AFL","GAS","T","ABBV","ABT","ANF","ACN","ACT","ADBE","AMD","AET","A","APD","ARG","AKAM","AA","ALXN","ATI","AGN","ALL","ALTR","MO","AMZN","AEE","AEP","AXP","AIG","AMT","AMP","ABC","AMGN","APH","PC","ADI","AON","APA","AIV","APOL","AAPL","AMAT","ADM","AIZ","AN","AZO","ADSK","ADP","AVB","AVY","AVP","BBT","C","BHI","BLL","BAC","BCR","BAX","BEAM","BDX","BBBY","BMS","BRK.B","BBY","BIG","BIIB","BLK","HRB","BA","BWA","BXP","BSX","BMY","BRCM","BF.B","CA","CBG","CBS","CF","CHRW","CME","CMS","CNX","CSX","CVS","CVC","COG","CAM","CPB","COF","CAH","CFN","KMX","CCL","CAT","CELG","CNP","CTL","CERN","CHK","CVX","CMG","CB","CI","CINF","CTAS","CSCO","CTXS","CLF","CLX","COH","KO","CCE","CTSH","CL","CMCSA","CMA","CSC","CAG","COP","ED","STZ","GLW","COST","CVH","COV","CCI","CMI","DTV","DTE","DVA","DHR","DRI","DF","DE","DELL","DLPH","DNR","XRAY","DVN","DO","DFS","DISCA","DG","DLTR","D","DOV","DOW","DPS","DUK","DNB","ETFC","DD","EMC","EOG","EQT","EMN","ETN","ECL","EIX","EW","EA","EMR","ESV","ETR","EFX","EQR","EL","EXC","EXPE","EXPD","ESRX","XOM","FFIV","FLIR","FMC","FTI","FDO","FAST","FDX","FIS","FITB","FHN","FSLR","FE","FISV","FLS","FLR",
              "F","FRX","FOSL","BEN","FCX","FTR","GME","GCI","GPS","GRMN","GD","GE","GIS","GPC","GNW","GILD","GS","GT","GOOG","GWW","HCP","HAL","HOG","HAR","HRS","HIG","HAS","HCN","HNZ","HP","HSY","HES","HPQ","HD","HON","HRL","DHI","HSP","HST","HCBK","HUM","HBAN","ITW","IR","TEG","INTC","ICE","IPG","IBM","IFF","IGT","IP","INTU","ISRG","IVZ","IRM","JDSU","JPM","JBL","JEC","JNJ","JCI","JOY","JNPR","KLAC","K","KEY","KMB","KIM","KMI","KSS","KRFT","KR","LLL","LSI","LH","LRCX","LM","LEG","LEN","LUK","LIFE","LLY","LTD","LNC","LLTC","LMT","L","LO","LOW","LYB","MTB","M","MRO","MPC","MAR","MMC","MAS","MA","MAT","MKC","MCD","MHP","MCK","MJN","MWV","MDT","MRK","MET","PCS","MCHP","MU","MSFT","MOLX","TAP","MDLZ","MON","MNST","MCO","MS","MOS","MSI","MUR","MYL","NKE","NRG","NYX","NBR","NDAQ","NOV","NTAP","NFLX","NWL","NFX","NEM","NWSA","NEE","NI","NE","NBL","JWN","NSC","NU","NTRS","NOC","NUE","NVDA","ORLY","OKE","OXY","OMC","ORCL","OI","PCAR","PETM","PCG","PNC","PPG","PPL","PLL","PH","PDCO","PAYX","BTU","JCP","PNR","PBCT","POM","PEP","PKI","PRGO","PFE","PM","PSX","PNW","PXD","PBI","PCL","PX","PCP","PCLN","PFG","PLD","PG","PGR","PRU","PEG","PSA","PHM","QEP","QCOM",
              "PWR","DGX","RL","RRC","RTN","RHT","RF","RSG","RAI","RHI","ROK","COL","ROP","ROST","RDC","R","SAI","SCG","SLM","SWY","CRM","SNDK","SLB","SCHW","SNI","STX","SEE","SRE","SHW","SIAL","SPG","SJM","SNA","SO","LUV","SWN","SE","S","STJ","SWK","SPLS","SBUX","HOT","STT","SRCL","SYK","STI","SYMC","SYY","TROW","TEL","TE","TJX","TGT","THC","TDC","TER","TSO","TXN","TXT","ADT","BK","WMB","TMO","TIF","TWC","TWX","TMK","TSS","TRV","TRIP","TYC","TSN","USB","UNP","UPS","X","UTX","UNH","UNM","URBN","VFC","VLO","VAR","VTR","VRSN","VZ","VIAB","V","VNO","VMC","WPX","WMT","WAG","DIS","WPO","WM","WAT","WLP","WFC","WDC","WU","WY","WHR","WFM","WIN","WEC","WYN","WYNN","XL","XEL","XRX","XLNX","XYL","YHOO","YUM","ZMH","ZION","EBAY")
################################################################################################
################################################################################################
if (getdata.fromscratch){
  # GET THE DATA NOW
  # just use the dates for which SPY is available
  tmpdata<-as.matrix(try(getSymbols(Symbols="SPY",from = Starting_Date,auto.assign=FALSE)))
  SPYDAYS=length(tmpdata) # number of days data we will use
  ProjectData.price=matrix(rep(NA,nrow(tmpdata)*length(SP500stocks)), ncol=length(SP500stocks))
  ProjectData.volume=matrix(rep(NA,nrow(tmpdata)*length(SP500stocks)), ncol=length(SP500stocks))
  colnames(ProjectData.price)<-SP500stocks; rownames(ProjectData.price)<-rownames(tmpdata)
  colnames(ProjectData.volume)<-SP500stocks; rownames(ProjectData.volume)<-rownames(tmpdata)
  nancolumn=matrix(rep(NA,nrow(tmpdata)),ncol=1); rownames(nancolumn)<-rownames(tmpdata)
  for (i in 1:length(SP500stocks))
  {
    ticker=SP500stocks[i]
    tmpdata<-as.matrix(try(getSymbols(Symbols=ticker,from = "2003-01-01",auto.assign=FALSE)))
    if (!inherits(tmpdata, "try-error"))
    {
      therownames=intersect(rownames(tmpdata),rownames(ProjectData.price))
      ProjectData.price[therownames,i]<-tmpdata[therownames,6] # adjusted close price
      ProjectData.volume[therownames,i]<-tmpdata[therownames,5] # shares volume for now - need to convert to dollars later
      cat(" ",i,ticker)
    }else {cat(" ",i," NOT ",ticker)}
  }
  ################################################################################################
  ################################################################################################
  # Cleaning out the stocks which had NAs for either price or volume (they may have data problems)
  dataset<-ProjectData.returns; dataset.Vol<-ProjectData.volume; dataset.Prc<-ProjectData.price
  # check for NaN's now
  logret.notnan=which(!is.nan(apply(dataset,2,sum)))
  vol.notnan=which(!is.nan(apply(dataset.Vol,2,sum)))
  prc.notnan=which(!is.nan(apply(dataset.Prc,2,sum)))
  notnan=intersect(intersect(logret.notnan,vol.notnan),prc.notnan)
  dataset<-dataset[,notnan]; dataset.Vol<-dataset.Vol[,notnan]; dataset.Prc<-dataset.Prc[,notnan]
  #  check for NAs now
  dataset.Vol<-dataset.Vol[,apply(dataset,2,function(col)all(!is.na(col)))]
  dataset.Prc<-dataset.Prc[,apply(dataset,2,function(col)all(!is.na(col)))]
  dataset<-dataset[,apply(dataset,2,function(col)all(!is.na(col)))]
  if (0){
    # filter dataset for suspiciously high-return days
    # does not change results, but just in case there are some data problems
    suspicious<-function(dataset,threshold)which(apply(dataset,2,function(x)any(abs(x)>threshold)))
    dataset.Vol<-dataset.Vol[,-suspicious(dataset,0.5)]
    dataset.Prc<-dataset.Prc[,-suspicious(dataset,0.5)]
    dataset<-dataset[,-suspicious(dataset,0.5)]
  }

  ProjectData=log((tail(ProjectData.price,-1))/(head(ProjectData.price,-1)))
  save(ProjectData,file="NewProjectData")

  } else{
  load(datafile)
}
