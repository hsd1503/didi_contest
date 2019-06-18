function sample_train_feat()
%SAMPLE_TRAIN_FEAT Summary of this function goes here
%   Detailed explanation goes here
load('./final/basic_io/cache/train_feats_table_interval_1_combined_detail_new_aver.mat');
train_feats_table = train_feats_table_interval_1;


train_start_date = datenum('2016-02-23', 'yyyy-mm-dd');
train_end_date = datenum('2016-03-17',  'yyyy-mm-dd');
train_day_stride = 1;
train_num_days = (train_end_date - train_start_date)/train_day_stride + 1;

val_num_days = 7;
ngb_slot_num = 7;

headers = train_feats_table.Properties.VariableNames;
headers{1} = 'target_gap';
headers{2} = 'district_id';
headers{3} = 'day_slot';
headers{4} = 'weekday';
headers{5} = 'minute_slot';
train_feats_table.Properties.VariableNames = headers;

feat_for_train = [];
% feat_for_val = [];
% train_sat_idxs = train_feats_table.day_slot <= train_num_days-val_num_days;
% feat_for_train = train_feats_table(train_sat_idxs, :);
for time_slot = 46:12:142
    train_sat_idxs = train_feats_table.minute_slot >= (time_slot-ngb_slot_num)*10 & ...
                     train_feats_table.minute_slot <= min(144, time_slot+ngb_slot_num)*10; %& ...
%                      train_feats_table.day_slot <= train_num_days-val_num_days;

%     val_sat_idxs = train_feats_table.day_slot >= train_num_days-val_num_days+1 & ...
%                    train_feats_table.minute_slot >= (time_slot)*10 & ...
%                    train_feats_table.minute_slot <= min(144, time_slot)*10;
    feat_for_train = [feat_for_train; train_feats_table(train_sat_idxs, :)];
%     feat_for_val = [feat_for_val; train_feats_table(val_sat_idxs, :)];
end
variablenames_back = feat_for_train.Properties.VariableNames;
feat_for_train = table2array(feat_for_train);
% feat_for_val = table2array(feat_for_val);
feat_for_train(isnan(feat_for_train)) = 0;
% feat_for_val(isnan(feat_for_val)) = 0;

feat_for_train = array2table(feat_for_train, 'VariableNames', variablenames_back);
% feat_for_val = array2table(feat_for_val, 'VariableNames', variablenames_back);

% train_ratio = zeros(size(feat_for_train, 1), 6);
% val_ratio = zeros(size(feat_for_val, 1), 6);
% 
% sat_idxs = feat_for_train(:,6:11)>0;
% request_feat = feat_for_train(:, 6:11);
% gap_feat = feat_for_train(:, 12:17);
% train_ratio(sat_idxs) = gap_feat(sat_idxs)./request_feat(sat_idxs);
% 
% sat_idxs = feat_for_val(:,6:11)>0;
% request_feat = feat_for_val(:, 6:11);
% gap_feat = feat_for_val(:, 12:17);
% val_ratio(sat_idxs) = gap_feat(sat_idxs)./request_feat(sat_idxs);
% 
% feat_for_train = [feat_for_train, train_ratio];
% feat_for_val = [feat_for_val, val_ratio];
% 
% ratio_headers = {'prev_ratio_5', 'prev_ratio_10', 'prev_ratio_15', 'prev_ratio_20', 'prev_ratio_25', 'prev_ratio_30'};
% 
% feat_for_train = array2table(feat_for_train, 'VariableNames', [variablenames_back, ratio_headers]);
% feat_for_val = array2table(feat_for_val, 'VariableNames', [variablenames_back, ratio_headers]);


% feat_for_train.weight = ones(height(feat_for_train), 1);
% feat_for_train.weight(feat_for_train.target_gap>50) = 2;
% feat_for_train.weight(feat_for_train.target_gap>50) = 4;
% feat_for_train.weight(feat_for_train.target_gap>100) = 8;

% feat_for_val.weight = ones(height(feat_for_val), 1);
% feat_for_val.weight(feat_for_val.target_gap>50) = 2;
% feat_for_val.weight(feat_for_val.target_gap>50) = 4;
% feat_for_val.weight(feat_for_val.target_gap>100) = 8;

%     big_idxs = find(feat_for_train.target_gap>1);
%     small_idxs = find(feat_for_train.target_gap<=1);
%     slt_idxs = [big_idxs; small_idxs(randperm(length(small_idxs), 10000))];
%     feat_for_train = feat_for_train(slt_idxs, :);
train_file_path = sprintf('./final/training_file/donnie/all_train_feat_combined_detail_new_aver_ngb%d.txt', ngb_slot_num);
% val_file_path = sprintf('./final/training_file/donnie/val_feat_combined_detail_new_aver_ngb%d.txt', ngb_slot_num);
writetable(feat_for_train, train_file_path, 'WriteVariableNames', false);
% writetable(feat_for_val, val_file_path, 'WriteVariableNames', false);
end

