train_feats_table = readtable('D:\projects\didi\final\training_file\season2\all_train_feat_combined_detail_new_aver_ngb7.txt', 'ReadVariableNames', false);

train_feats_table.Var211 = [];
orig_headers = train_feats_table.Properties.VariableNames;

train_feats_table = table2array(train_feats_table);

%% add gap ratio feature per 1 min
gap_ratios_train_per1min = train_feats_table(:, 36:65) ./ train_feats_table(:, 6:35);
gap_ratios_train_per1min(isnan(gap_ratios_train_per1min)|gap_ratios_train_per1min==Inf) = 0;

%% add aver gap ratio feature per 1min
aver_gap_ratios_train_per1min = mean(gap_ratios_train_per1min, 2);

%% add gap ratio feature per 5 min
gap_ratios_train_per5min = train_feats_table(:, 162:167) ./ train_feats_table(:, 156:161);
gap_ratios_train_per5min(isnan(gap_ratios_train_per5min)|gap_ratios_train_per5min==Inf) = 0;

%% add aver gap ratio feature per 5min
aver_gap_ratios_train_per5min = mean(gap_ratios_train_per5min, 2);

%% add gapratio change per1min
gapratio_change_train_per1min = gap_ratios_train_per1min(:,1:end-1) ./ gap_ratios_train_per1min(:, 2:end);
gapratio_change_train_per1min(isnan(gapratio_change_train_per1min)) = 1;
gapratio_change_train_per1min(gapratio_change_train_per1min==Inf) = 2; 

%% add aver gapratio change per1min
aver_gapratio_change_train_per1min = mean(gapratio_change_train_per1min, 2);

%% add gapratio change per5min
gapratio_change_train_per5min = gap_ratios_train_per5min(:, 1:end-1) ./ gap_ratios_train_per5min(:,2:end);
gapratio_change_train_per5min(isnan(gapratio_change_train_per5min)) = 1;
gapratio_change_train_per5min(gapratio_change_train_per5min==Inf) = 2; 

%% add aver gapratio change per5min
aver_gapratio_change_train_per5min = mean(gapratio_change_train_per5min, 2);

%% add prev gap change ratio per 1 min
gap_change_ratios_train_per1min = train_feats_table(:,36:64) ./ train_feats_table(:, 37:65);
gap_change_ratios_train_per1min(isnan(gap_change_ratios_train_per1min)) = 1;
gap_change_ratios_train_per1min(gap_change_ratios_train_per1min==Inf) = 2;

%% add aver prev gap change ratio per 1 min
aver_gap_change_ratio_per1min_train = mean(gap_change_ratios_train_per1min, 2);

%% add prev gap change ratio per 5 min
gap_change_ratios_train_per5min = train_feats_table(:,162:166) ./ train_feats_table(:, 163:167);
gap_change_ratios_train_per5min(isnan(gap_change_ratios_train_per5min)) = 1;
gap_change_ratios_train_per5min(gap_change_ratios_train_per5min==Inf) = 2;

%% add aver prev gap change ratio per 5 min
aver_gap_change_ratio_per5min_train = mean(gap_change_ratios_train_per5min, 2);

%% add avergap change ratio per5min
avergap_change_ratios_train = train_feats_table(:, 193:198)./train_feats_table(:, 194:199);
avergap_change_ratios_train(isnan(avergap_change_ratios_train)) = 1;
avergap_change_ratios_train(avergap_change_ratios_train==Inf) = 2;

%% add aver avergap change ratio per5min
aver_avergap_change_ratios_train = mean(avergap_change_ratios_train, 2);

%% add prev drivernum change ratio per 1 min
drivernum_change_ratios_train_per1min = train_feats_table(:,66:94) ./ train_feats_table(:, 67:95);
drivernum_change_ratios_train_per1min(isnan(drivernum_change_ratios_train_per1min)) = 1;
drivernum_change_ratios_train_per1min(drivernum_change_ratios_train_per1min==Inf) = 2;

%% add aver prev drivernum change ratio per 1 min
aver_drivernum_change_ratio_per1min_train = mean(drivernum_change_ratios_train_per1min, 2);

%% add prev drivernum ratio per 5 min
drivernum_change_ratios_train_per5min = train_feats_table(:,168:172) ./ train_feats_table(:, 169:173);
drivernum_change_ratios_train_per5min(isnan(drivernum_change_ratios_train_per5min)) = 1;
drivernum_change_ratios_train_per5min(drivernum_change_ratios_train_per5min==Inf) = 2;

%% add aver prev drivernum change ratio per 5 min
aver_drivernum_change_ratio_per5min_train = mean(drivernum_change_ratios_train_per5min, 2);

%% ===============concat all feature ============
concated_headers = [orig_headers, ...
                arrayfun(@(i)sprintf('gapratio_per1min_%d',i), 1:30, 'UniformOutput', false), {'aver_gapratio_per1min'}, ...
                arrayfun(@(i)sprintf('gapratio_per5min_%d',i), 1:6, 'UniformOutput', false), {'aver_gapratio_per5min'}, ...
                arrayfun(@(i)sprintf('gapratio_change_per1min_%d',i), 1:29, 'UniformOutput', false), {'aver_gapratio_change_per1min'}, ... 
                arrayfun(@(i)sprintf('gapratio_change_per5min_%d',i), 1:5, 'UniformOutput', false), {'aver_gapratio_change_per5min'}, ... 
                arrayfun(@(i)sprintf('gapchange_ratio_per1min_%d',i), 1:29, 'UniformOutput', false), {'aver_gapchange_ratio_per1min'}, ... 
                arrayfun(@(i)sprintf('gapchange_ratio_per5min_%d',i), 1:5, 'UniformOutput', false), {'aver_gapchange_ratio_per5min'}, ... 
                arrayfun(@(i)sprintf('avergapchange_ratio_%d',i), 1:6, 'UniformOutput', false), {'aver_avergapchange_ratio'}, ... 
                arrayfun(@(i)sprintf('drivernumchange_ratio_per1min_%d',i), 1:29, 'UniformOutput', false), {'aver_drivernumchange_ratio_per1min'}, ...
                arrayfun(@(i)sprintf('drivernumchange_ratio_per5min_%d',i), 1:5, 'UniformOutput', false), {'aver_drivernumchange_ratio_per5min'}, ... 
                ];


concated_train_feats_table = array2table([train_feats_table, ...
                                   gap_ratios_train_per1min, aver_gap_ratios_train_per1min, ...
                                   gap_ratios_train_per5min, aver_gap_ratios_train_per5min, ...
                                   gapratio_change_train_per1min, aver_gapratio_change_train_per1min, ...
                                   gapratio_change_train_per5min, aver_gapratio_change_train_per5min, ...
                                   gap_change_ratios_train_per1min, aver_gap_change_ratio_per1min_train, ...
                                   gap_change_ratios_train_per5min, aver_gap_change_ratio_per5min_train, ...
                                   avergap_change_ratios_train, aver_avergap_change_ratios_train, ...
                                   drivernum_change_ratios_train_per1min, aver_drivernum_change_ratio_per1min_train, ...
                                   drivernum_change_ratios_train_per5min, aver_drivernum_change_ratio_per5min_train], ...
                                   'VariableNames', concated_headers);

%% add weight
concated_train_feats_table.weight = ones(height(concated_train_feats_table), 1);

save('./final/basic_io/cache_new/all_concated_feats_table.mat', 'concated_train_feats_table', '-v7.3');

writetable(concated_train_feats_table, 'D:\projects\didi\final\training_file\season2\concated_all_train_feat_combined_detail_new_aver_ngb7.txt', 'WriteVariableNames', false);


load('./final/basic_io/cache_new/all_concated_feats_table.mat', 'concated_train_feats_table');
all_concated_train_feats_table = concated_train_feats_table;
all_concated_train_feats_table.weight = [];
headers_back = all_concated_train_feats_table.Properties.VariableNames;

all_concated_train_feats_table = table2array(all_concated_train_feats_table);

%% add avergap per1min
load('./final/basic_io/cache_new/aver_request_gap_permin.mat', 'aver_requests_permin', 'aver_gaps_permin');
avergap_test_per1min = zeros(size(all_concated_train_feats_table, 1), 30);
averrequest_test_per1min = zeros(size(all_concated_train_feats_table, 1), 30);

for i = 1:size(all_concated_train_feats_table, 1)
    distr = all_concated_train_feats_table(i, 2);
    minute_slot = all_concated_train_feats_table(i, 5);
    avergap_test_per1min(i, :) = aver_gaps_permin(distr, minute_slot-10:-1:minute_slot-39);
    averrequest_test_per1min(i, :) = aver_requests_permin(distr, minute_slot-10:-1:minute_slot-39);
end

%% add gap/avergap per1min
gap_avergap_ratio_test_per1min = all_concated_train_feats_table(:, 36:65) ./ avergap_test_per1min;
gap_avergap_ratio_test_per1min(gap_avergap_ratio_test_per1min==Inf) = 2;
gap_avergap_ratio_test_per1min(isnan(gap_avergap_ratio_test_per1min)) = 1;

% aver gap/avergap per1min
aver_gap_avergap_ratio_test_per1min = mean(gap_avergap_ratio_test_per1min, 2);

%% add request/averrequest per1min
request_averrequest_ratio_test_per1min = all_concated_train_feats_table(:, 6:35) ./ averrequest_test_per1min;
request_averrequest_ratio_test_per1min(request_averrequest_ratio_test_per1min==Inf) = 2;
request_averrequest_ratio_test_per1min(isnan(request_averrequest_ratio_test_per1min)) = 1;

% aver request/averrequest per1min
aver_request_averrequest_ratio_test_per1min = mean(request_averrequest_ratio_test_per1min, 2);

%% add gap/avergap per5min
gap_avergap_ratio_test_per5min = all_concated_train_feats_table(:, 162:167) ./ all_concated_train_feats_table(:,194:199);
gap_avergap_ratio_test_per5min(gap_avergap_ratio_test_per5min==Inf) = 2;
gap_avergap_ratio_test_per5min(isnan(gap_avergap_ratio_test_per5min)) = 1;

% aver gap/avergap per5min
aver_gap_avergap_ratio_test_per5min = mean(gap_avergap_ratio_test_per5min, 2);

%% add request/averrequest per5min
request_averrequest_ratio_test_per5min = all_concated_train_feats_table(:, 156:161) ./ all_concated_train_feats_table(:,187:192);
request_averrequest_ratio_test_per5min(request_averrequest_ratio_test_per5min==Inf) = 2;
request_averrequest_ratio_test_per5min(isnan(request_averrequest_ratio_test_per5min)) = 1;

% aver request/averrequest per5min
aver_request_averrequest_ratio_test_per5min = mean(request_averrequest_ratio_test_per5min, 2);
aver_request_averrequest_ratio_val_per5min = mean(request_averrequest_ratio_val_per5min, 2);

concated_headers = [headers_back, ...
                arrayfun(@(i)sprintf('avergap_per1min_%d',i), 1:30, 'UniformOutput', false), ...
                arrayfun(@(i)sprintf('averrequest_per1min_%d',i), 1:30, 'UniformOutput', false), ...
                arrayfun(@(i)sprintf('gap_avergap_ratio_per1min_%d',i), 1:30, 'UniformOutput', false), {'aver_gap_avergap_ratio_per1min'}, ... 
                arrayfun(@(i)sprintf('request_averrequest_ratio_per1min_%d',i), 1:30, 'UniformOutput', false), {'aver_request_averrequest_ratio_per1min'}, ... 
                arrayfun(@(i)sprintf('gap_avergap_ratio_per5min_%d',i), 1:6, 'UniformOutput', false), {'aver_gap_avergap_ratio_pe5min'}, ... 
                arrayfun(@(i)sprintf('request_averrequest_ratio_per5min_%d',i), 1:6, 'UniformOutput', false), {'aver_request_averrequest_ratio_per5min'}, ... 
                ];


all_concated_train_feats_table_1 = array2table([all_concated_train_feats_table, ...
                                   avergap_test_per1min, averrequest_test_per1min, ...
                                   gap_avergap_ratio_test_per1min, aver_gap_avergap_ratio_test_per1min, ...
                                   request_averrequest_ratio_test_per1min, aver_request_averrequest_ratio_test_per1min, ...
                                   gap_avergap_ratio_test_per5min, aver_gap_avergap_ratio_test_per5min, ...
                                   request_averrequest_ratio_test_per5min, aver_request_averrequest_ratio_test_per5min], ...
                                   'VariableNames', concated_headers);

all_concated_train_feats_table_1.weight = ones(height(all_concated_train_feats_table_1), 1);

all_concated_train_feats_table_1 = table2array(all_concated_train_feats_table_1);

all_concated_train_feats_table_1(isnan(all_concated_train_feats_table_1)) = 0;
save('./final/basic_io/cache_new/all_concated_train_feats_table_1.mat', 'all_concated_train_feats_table_1', '-v7.3');



