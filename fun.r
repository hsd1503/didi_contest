evalerror_mae <- function(preds, dtrain) {
  labels <- getinfo(dtrain, "label")
  err <- 0
  for (i in 1:length(labels)){
    err <- err + abs(preds[i] - labels[i])
  }
  err <- err/length(labels)
  return(list(metric = "mae", value = err))
}

evalerror_mae1 <- function(preds, dtrain) {
  labels <- getinfo(dtrain, "label")
  err <- 0
  preds <- 10^(preds)-1
  labels <- 10^(labels)-1
  for (i in 1:length(labels)){
    err <- err + abs(preds[i] - labels[i])
  }
  err <- err/length(labels)
  return(list(metric = "mae", value = err))
}




mapeObj1=function(preds,dtrain){
  gaps=getinfo(dtrain,'label')
  grad=sign(preds-gaps)/gaps
  hess=1/gaps
  grad[which(gaps==0)]=0
  hess[which(gaps==0)]=0
  return(list(grad = grad, hess = hess))
}

mapeObj3=function(preds,dtrain){
  gaps=getinfo(dtrain,'label')
  grad=sign(preds-gaps)/gaps
  hess=1/abs(preds-gaps)
  grad[which(gaps==0)]=0
  hess[which(gaps==0)]=0
  return(list(grad = grad, hess = hess))
}

logregobj <- function(preds, dtrain) {
  labels <- getinfo(dtrain, "label")
  preds <- 1/(1 + exp(-preds))
  grad <- preds - labels
  hess <- preds * (1 - preds)
  return(list(grad = grad, hess = hess))
}