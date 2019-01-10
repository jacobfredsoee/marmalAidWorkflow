con = file("/home/jcf/MarmalAid/ChampData.csv", "r")
datasetNames = unlist(strsplit(gsub("beta.", "", gsub('\"', '', readLines(con, 1))), "\t"))
Annotation = read.delim("/home/jcf/MarmalAid/Annotation_JCF.csv", stringsAsFactors=FALSE)
rownames(Annotation) = gsub("-", ".", Annotation$Id)

group = Annotation[datasetNames,"ANNOTATION_JCF"]

savePath = "/home/jcf/MarmalAid/ProcessedData/betavalues/"

counter = 1
while(TRUE) {
  
  line = readLines(con, 1)
  if(length(line) == 0) {
    break
  }
  
  betaValues = unlist(strsplit(gsub('\"', '', line), "\t"))
  probeName = betaValues[1]
  
  betaValues = rbind(group, betaValues[2:length(betaValues)])
  rownames(betaValues)[2] = probeName
  
  print(paste(Sys.time(), counter, paste(round(counter / 485513 * 100, 6), "%", sep = ""), probeName, sep = " | "))
  write.table(betaValues, paste(savePath, probeName, ".csv", sep = ""), quote = FALSE, sep = ";", col.names = datasetNames)
  
  counter = counter + 1
}

close(con)

