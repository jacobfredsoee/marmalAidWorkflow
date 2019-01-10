library(ChAMP)
library(marmalaid)

setwd("/home/siri/MarmalAid")

update_marmalaid("./")

MyProbes1 = read.table("./450K_probes.txt", sep = "\t", header = TRUE,  row.names = NULL) 
MyProbes = as.vector(MyProbes1[,1])

args = commandArgs(trailingOnly = TRUE)
Data = basename(substr(args[1], 1, regexpr("\\.", args[1])-1))

MarmalAidDataDir = "/home/siri/MarmalAid/Rdata/"

myLoad = list()
myLoad[["beta"]] = beta
samplesheet = read.csv("/home/siri/MarmalAid/Marmalaid_samplesheet_jcf.csv", sep = ";", header=TRUE)
myLoad[["pd"]] = samplesheet 

betaValues = tryCatch({
  
  print(paste(Sys.time(), "starting", Data, sep = " | "))
  
  load(paste(MarmalAidDataDir, Data, ".Rdata", sep = ""))
  betaValues = a[MyProbes]
  
  betaAsFrame = data.frame(betaValues)
  colnames(betaAsFrame)[1] = Data
  
  as.data.frame(champ.norm(beta = betaAsFrame, filterXY=FALSE, sampleSheet = "/home/siri/MarmalAid/Marmalaid_all_samplesheet.csv", QCimages = FALSE, plotBMIQ = TRUE))
}, error = function(e) {
  print(paste(Data, e, sep ="|"))
  return(NA)
})

if(class(betaValues) == "data.frame") {
  print(paste("Saving ", Data, " to file", sep =""))
  saveRDS(betaValues, file = paste("/home/siri/MarmalAid/resultsChamp/Data/", Data, ".rds", sep = ""))
}