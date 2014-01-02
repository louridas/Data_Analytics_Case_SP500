
# Project Name: "S&P500 Daily Stock Returns Analysis"

rm(list = ls()) # clean up the workspace

######################################################################

# THESE ARE THE PROJECT PARAMETERS NEEDED TO GENERATE THE REPORT

# Please ENTER the name of the file with the data used. The file should contain a matrix with one row per observation (e.g. person) and one column per attribute. THE NAME OF THIS MATRIX NEEDS TO BE ProjectData (otherwise you will need to replace the name of the ProjectData variable below with whatever your variable name is, which you can see in your Workspace window after you load your file)
datafile_name="SP500data"

# this loads the selected data
load(paste("Datasets",datafile_name,sep="/")) # this contains only the matrix ProjectData

# Please ENTER the number of principal components to eventually use for this report
numb_components_used = 3

# Please ENTER 0 or 1 to de-mean or not the data in the regression estimation of the report (Default is 0)
use_mean_alpha=0

# Please ENTER the stocks to use (default is 1:ncol(ProjectData), namely all of them)
stocks_used=1:ncol(ProjectData)

# Please ENTER the time period to use (default is 1 to nrow(ProjectData), namely all the days)
start_date=1
end_date=nrow(ProjectData)

# Would you like to also start a web application once the report and slides are generated?
# 1: start application, 0: do not start it. 
# Note: starting the web application will open a new browser with the application running
strat_webapp=0


######################################################################
# Run it now and generate the report, slides, and if needed start the web application

days_used=start_date:end_date
ProjectData=ProjectData[days_used,stocks_used]
source("R_code/library.R")

knit2html("Reports_Slides/SP500_report.Rmd")
slidify("Reports_Slides/SP500_slides.Rmd")

if (strat_webapp)
  runApp("Web_Application")
