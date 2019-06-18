library(xgboost)
library(R.matlab)

############
### read 
setwd("H:/Code/didi/didi2/")
source('fun.r')

#############################
### 1，读取数据
### 先选取全部的特征，第一列为待预测值，test中为0
train_mat_raw <- as.matrix(read.table('train_feats_reduced.txt', header = F, sep = ','))
validation_mat_raw <- as.matrix(read.table('val_feats_reduced.txt', header = F, sep = ','))

n_col <- ncol(validation_mat_raw)

#############################
### 2，特征选择
### 先选取全部的特征，第一列为待预测值，test中为0
selected_col <- c(2: 52)
train_mat_all <- train_mat_raw[, selected_col]
validation_mat_all <- validation_mat_raw[, selected_col]

### 选取全部的列，看特征的importance
train_mat <- train_mat_all
validation_mat <- validation_mat_all

### 处理数据
train_mat[,1] <- as.numeric(train_mat[,1])
validation_mat[,1] <- as.numeric(validation_mat[,1])
train_dmat <- xgb.DMatrix(data = train_mat, label = train_mat_raw[, 1], missing = NA)
validation_dmat <- xgb.DMatrix(data = validation_mat, label = validation_mat_raw[, 1], missing = NA)
watchlist <- list(test=validation_dmat, train=train_dmat)


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
                 nrounds=10000, early.stop.round=20, maximize=FALSE)
print(bst$bestScore)


#############################
### 4，输出特征的重要性排序
raw_aa <- xgb.importance(model = bst)
feature_id <- read.table('data/f211_new.txt', header = F, sep = ',')

aa <- raw_aa
aa[,1] <- as.numeric(aa[,Feature])+1
feature_list <- as.character(rep(0,nrow(aa)))
for(i in seq(1,nrow(aa))){
  feature_list[i] <- as.character(feature_id[aa[i,Feature],1])
}
out_feature <- cbind(aa, feature_list)
write.table(out_feature, 'f_importance.csv', row.names=F, col.names = F, quote = F, sep = ",")

