# didi_contest
Code for 2016 Di-Tech Competition


# Usage
1. 修改get_data_dir.m里面的原始data路径
2. 运行get_unique_items.m获取所有的district_hash, driver_hash, passenger_hash,并转化为唯一数字id,便于保存
3. 分别运行read_raw_order_data.m, read_raw_traffic_data.m, read_raw_weather_data.m 读入所有训练和测试的原始数据，并缓存成mat
4. 修改get_null_driver_id.m的null_id值，设置为driver_hash为NULL的数字id
5. 运行prepare_train_data和prepare_test_data,以及add_more_feature_2_forall, add_more_feature_2_test准备好特征
6. 运行sample_train_feat_back采样生成train 和validation数据
7. 运行xgboost， 得到特征importance排名，根据importance排名选择特征，运行reduce_feature_dim得到选取的特征
8. 根据选取的特征训练xgboost模型得到结果，运行predict_with_period和parse_rst对模型结果进行调整得到最终结果。

# Detailed Document
see Detailed.pdf