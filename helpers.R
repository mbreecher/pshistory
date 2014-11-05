library(RecordLinkage)

ClosestMatch <- function(string, stringVector){
  
  #look for best matches based on best Levenshtein similarity and a jarowinkler score of 89%+
  distance = levenshteinSim(tolower(string), tolower(stringVector));
  best_match <- paste(stringVector[distance == max(distance)], collapse = "")
  if (jarowinkler(tolower(string), tolower(best_match)) > .89){
    result <- best_match
  }else{
    result <- NULL
  }
  result
  
}

lm_eqn <- function(df, order = 3){
  m=lm(y ~ poly(x, order), df)
  eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2,
                   list(a = format(coef(m)[1], digits = 2),
                        b = format(coef(m)[2], digits = 2),
                        r2 = format(summary(m)$r.squared, digits = 3)))
  as.character(as.expression(eq))
}

trim.leading <- function (x)  sub("^\\s+", "", x)