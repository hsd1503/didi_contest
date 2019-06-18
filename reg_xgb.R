library(xgboost)
library(R.matlab)

############
### read 
setwd("H:/Code/didi/final_submit/cache/")
source('fun.r')

#############################
### 1，读取数据
### 先选取全部的特征，第一列为待预测值，test中为0
data1 <- readMat('all_concated_feats_table_only_reduced.mat')
train_mat_raw <- data1$all.concated.feats.reduced
data2 <- readMat('concated_test_feats_table_only_reduced.mat')
validation_mat_raw <- data2$concated.test.feats.table.1.reduced

n_col <- ncol(validation_mat_raw)

#############################
### 2，特征选择
### 选取特征选择排序后的特征
selected_col <- c(2: 52)
train_mat <- train_mat_raw[, selected_col]
validation_mat <- validation_mat_raw[, selected_col]

### 处理数据
train_mat[,1] <- as.numeric(train_mat[,1])
validation_mat[,1] <- as.numeric(validation_mat[,1])
train_dmat <- xgb.DMatrix(data = train_mat, label = train_mat_raw[, 1], missing = NA)
validation_dmat <- xgb.DMatrix(data = validation_mat, validation_mat_raw[, 1], missing = NA)
watchlist <- list(train=train_dmat)


#############################
### 3，训练模型
source('fun.r')
params = list(booster='gbtree',
              objective='reg:linear',
              eval_metric=evalerror_mae,
              max_depth=7,
              colsample_bytree=0.9,
              min_child_weight=10,
              eta=0.01
)                                                          

bst <- xgb.train(data = train_dmat, watchlist = watchlist, params=params,
                 nrounds=930)
print(bst$bestScore)

############
### 4，预测结果
test_pred <- predict(bst, validation_dmat)
n_row <- getinfo(validation_dmat,'nrow')

for(i in (1:n_row)){
  if(test_pred[i] <= 0.5){
    test_pred[i] <- 0
  }
}
# for(i in (1:n_row)){
#   test_pred[i] <- round(test_pred[i])
#   
# }

pred_head <- read.csv('pred_head.csv', header = FALSE)
write.table(cbind(pred_head, as.numeric(test_pred)), 'submit.csv', row.names=F, col.names = F, quote=F,sep=',')
