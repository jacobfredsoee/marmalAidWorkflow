#Load data
print(paste(Sys.time(), "|", "starting"))
ChampData = readRDS("./ChampData.rds")
colnames(ChampData) = sub("beta.", "", colnames(ChampData))
colnames(ChampData) = gsub("[.]", "-", colnames(ChampData))

MarmalAidAnnotation = read.csv("./Annotation_JCF.csv", sep = "\t", stringsAsFactors = FALSE)
rownames(MarmalAidAnnotation) = MarmalAidAnnotation$Id
Probes450K = readRDS("./450KProbes.rds")

MarmalAidSamplessheet = subset(MarmalAidAnnotation, MarmalAidAnnotation$Id %in% colnames(ChampData))

MarmalAidSamplessheet$ANNOTATION_JCF = gsub(" ", "_", MarmalAidSamplessheet$ANNOTATION_JCF)
groups = unique(MarmalAidSamplessheet$ANNOTATION_JCF)

results = list()
length(results) = length(groups)
names(results) = groups

summarizeBeta = function(dataset, stepsize = 0.1) {
  counter = 1
  steps = seq(0, 1, by = stepsize)
  
  countMatrix = matrix(nrow = nrow(dataset), ncol = length(steps))
  colnames(countMatrix) = paste("#>=", steps, sep = "")
  rownames(countMatrix) = rownames(dataset)
  
  for(currentStep in steps) {
    countMatrix[,counter] = rowSums(dataset >= currentStep)
    
    print(currentStep)
    
    counter = counter + 1
  }
  percentageMatrix = countMatrix[,1:ncol(countMatrix)]/countMatrix[,1]
  colnames(percentageMatrix) = paste("%>=", steps, sep = "")
  
  return(cbind(countMatrix, percentageMatrix))
}

for(i in 1:length(groups)) {
  ids = subset(MarmalAidSamplessheet, ANNOTATION_JCF == groups[i])$Id
  
  print(paste(Sys.time(), "|", "starting:", names(results)[i]))
  
  results[[i]] = summarizeBeta(as.matrix(ChampData[,ids]))

}

print(paste(Sys.time(), "|", "saving"))
saveRDS(results, "./results.rds")

data.frame(type = names(results), count = sapply(1:length(results), function(i) results[[i]][1,1]))

data.frame(size = format(sort(sapply(ls(), function(x) object.size(get(x)))), big.mark = ","))
