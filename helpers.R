library(RecordLinkage)

ClosestMatch = function(string, stringVector){
  
  distance = levenshteinSim(tolower(string), tolower(stringVector));
  stringVector[distance == max(distance)]
  
}