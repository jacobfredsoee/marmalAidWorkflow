library(ChAMP)
library(marmalaid)
library(RPMM)

FileList = as.character(read.table("/home/siri/MarmalAid/samples_JCF.txt")[,1])
MarmalAidDataDir = "/home/siri/MarmalAid/Rdata/"

setwd("/home/siri/MarmalAid")

update_marmalaid("./")

MyProbes1 = read.table("./450K_probes.txt", sep = "\t", header = TRUE,  row.names = NULL) 
MyProbes = as.vector(MyProbes1[,1])

myLoad = list()
myLoad[["beta"]] = beta
samplesheet = read.csv("/home/siri/MarmalAid/Marmalaid_samplesheet_jcf.csv", sep = ";", header=TRUE)
myLoad[["pd"]] = samplesheet

MarmalAidDataMatrix = matrix(ncol = length(FileList), nrow = length(MyProbes))
colnames(MarmalAidDataMatrix) = FileList
rownames(MarmalAidDataMatrix) = MyProbes

for(i in 1:length(FileList)) {
  if(i %% 25 == 0) print(paste(Sys.time(), " | ", round(i/length(FileList) * 100, 2), "% loaded", sep = ""))
  tryCatch({
    
    load(paste(MarmalAidDataDir, FileList[i], "_nm_imp.Rdata", sep = ""))
    
    MarmalAidDataMatrix[,i] = a[MyProbes]
    
  }, error = function(e) {
    print(paste(FileList[i], e, sep =" | "))
    return(NA)
  })
}

print(paste("Unsuccesful file:", FileList[colSums(is.na(MarmalAidDataMatrix)) != 0]))
MarmalAidDataMatrix = MarmalAidDataMatrix[,colSums(is.na(MarmalAidDataMatrix)) == 0]

print(Sys.time())
print("starting ChAMP")
source("/home/siri/ChAMPSource/champ.norm.R")
source("/home/siri/ChAMPSource/BMIQ.R")
myNorm = champ.norm(beta = MarmalAidDataMatrix, filterXY=FALSE, sampleSheet = "/home/siri/MarmalAid/Marmalaid_all_samplesheet.csv", QCimages = TRUE, plotBMIQ = TRUE)

print(Sys.time())
print("saving rds")
ChampData = as.data.frame(myNorm)
saveRDS(ChampData , file = "/home/siri/ChampData.rds")

print(Sys.time())
print("saving csv")
stepSize = 500
if(ncol(ChampData) > stepSize) {
  n = 1
  i = 1
  while(i * stepSize < ncol(ChampData)) {
    fileName = paste("/home/siri/ChampData_", n, "_", i * stepSize, ".csv", sep = "")
    print(fileName)
    print(paste(n, " _> ", i * stepSize))
    
    write.table(ChampData[,n:(i * stepSize)], fileName, sep = "\t")
    
    n = i * stepSize + 1
    i = i + 1
  }
  fileName = paste("/home/siri/ChampData_", n, "_", ncol(ChampData), ".csv", sep = "")
  print(fileName)
  write.table(ChampData[,n:ncol(ChampData)], fileName, sep = "\t")
} else {
  write.table(ChampData, "/home/siri/ChampData.csv", sep = "\t")
}
