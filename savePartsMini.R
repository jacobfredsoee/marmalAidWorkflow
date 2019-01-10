print(paste(Sys.time(), "|", "starting"))

results = readRDS("results.rds")
numbercolumns = 1:(ncol(results[[1]])/2)
percentageColumns = (ncol(results[[1]])/2 + 1):(ncol(results[[1]]))
names(results) = sub("/", "_", names(results))

print(paste(Sys.time(), "|", "probeinfo"))
probesinfo = read.csv("/home/jcf/MarmalAid/450k_probesinfo.csv", sep = ";", stringsAsFactors = FALSE)

rownames(probesinfo) = probesinfo$TargetID

probesinfo = probesinfo[rownames(results[[1]]),]

essentialProbeInfo = probesinfo[,c("TargetID", "gene.by.jbbr", "Index", "CHR", "MAPINFO", "UCSC_REFGENE_NAME", "RELATION_TO_UCSC_CPG_ISLAND")]

for(i in 1:length(results)) {
  
  baseName = paste("/home/jcf/MarmalAid/ProcessedData/", names(results)[i], sep = "")
  print(paste(Sys.time(), "|", baseName))
  
  if(!file.exists(paste(baseName, ".rds", sep = ""))) { 
    saveRDS(results[[i]], paste(baseName, ".rds", sep = ""))
  }
  if(!file.exists(paste(baseName, ".csv", sep = ""))) { 
    write.table(cbind(essentialProbeInfo, results[[i]]), paste(baseName, ".csv", sep = ""), sep = ";", col.names = NA)
  }
}

data.frame(type = names(results), count = sapply(1:length(results), function(i) results[[i]][1,1]))

data.frame(size = format(sort(sapply(ls(), function(x) object.size(get(x)))), big.mark = ","))


print(paste(Sys.time(), "|", "Saving"))
saveRDS(results, "results.rds")