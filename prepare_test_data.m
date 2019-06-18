function prepare_test_data()
%PREPARE_TRAIN_DATA Summary of this function goes here
%   Detailed explanation goes here
train_start_date = datenum('2016-02-23', 'yyyy-mm-dd');
train_end_date = datenum('2016-03-17',  'yyyy-mm-dd');
train_day_stride = 1;
train_num_days = (train_end_date - train_start_date)/train_day_stride + 1;

test_start_date = datenum('2016-03-19', 'yyyy-mm-dd');
test_end_date = datenum('2016-03-31', 'yyyy-mm-dd');
test_day_stride = 2;
test_num_days = (test_end_date - test_start_date)/test_day_stride + 1 + 14;

%% order_data: { 'all_slot', 'day_slot', 'time_slot', 'minute_slot', 'start_district_id', 'dest_district_id', 'driver_id', 'price'}
[~, order_datas_test] = read_raw_order_data();
null_driver_id = get_null_driver_id();
special_passenger_id = get_special_passenger_id();
test_feats = [];
slot_interval = 1;
interval_num = 30 / slot_interval;
% start_day_slot = train_num_days + 1;
% end_day_slot = start_day_slot + test_day_stride*(test_num_days-1) ;
test_day_slots = [26:2:38, 39:52];

for distr = 1:58
    fprintf('processing %d th district...\n', distr);
    order_datas_curr_district = order_datas_test(order_datas_test.start_district_id==distr, :);
    order_datas_from_other_district = order_datas_test(order_datas_test.dest_district_id==distr, :);
%     for day_slot = start_day_slot:test_day_stride:end_day_slot
    for idx = 1:length(test_day_slots)
        day_slot = test_day_slots(idx);
        weekday = get_weekday(day_slot);
        if mod(idx, 2)
            start_min_slot = 460;
        else
            start_min_slot = 580;
        end
        for minute_slot = start_min_slot:120:1420
            target_all_slot_end = (day_slot - 1) * 1440 + minute_slot;
            target_gap = nan;
            
            prev_all_slot_end = target_all_slot_end - 10;
            prev_requests = nan(1, interval_num);
            prev_gaps = nan(1, interval_num);
            prev_driver_nums = nan(1, interval_num);
%             prev_passenger_nums = nan(1, interval_num);
            prev_ordernum_from_other = nan(1, interval_num);
            prev_ordernum_from_other_valid = nan(1, interval_num);
            for k = slot_interval:slot_interval:30
                ngb_idxs = order_datas_curr_district.all_slot >= prev_all_slot_end - k + 1 & order_datas_curr_district.all_slot <= prev_all_slot_end - (k - slot_interval);
                if any(ngb_idxs)
                    prev_requests(k/slot_interval) = sum(ngb_idxs);
                    prev_gaps(k/slot_interval) = sum(order_datas_curr_district.driver_id(ngb_idxs)==null_driver_id);
                    prev_driver_nums(k/slot_interval) = length(unique(setdiff(order_datas_curr_district.driver_id(ngb_idxs), null_driver_id)));
%                     prev_passenger_nums(k/slot_interval) = length(unique(setdiff(order_datas_curr_district.passenger_id(ngb_idxs), special_passenger_id)));
%                     prev_passenger_nums(k/slot_interval) = prev_passenger_nums(k/slot_interval) + sum(order_datas_curr_district.passenger_id(ngb_idxs)==special_passenger_id);
                end
                ngb_idxs_from_other = order_datas_from_other_district.all_slot >= prev_all_slot_end - k + 1 & order_datas_from_other_district.all_slot <= prev_all_slot_end - (k - slot_interval);
                if any(ngb_idxs_from_other)
                    prev_ordernum_from_other(k/slot_interval) = sum(ngb_idxs_from_other);
                    prev_ordernum_from_other_valid(k/slot_interval) = sum(order_datas_from_other_district.driver_id(ngb_idxs_from_other)~=null_driver_id);
                end
            end
            raw_feat = [target_gap, distr, day_slot, weekday, minute_slot, prev_requests, prev_gaps, prev_driver_nums, prev_ordernum_from_other, prev_ordernum_from_other_valid];
            test_feats = [test_feats; raw_feat];
        end
    end
end
% 
% test_feats_table = array2table(test_feats);
% test_feats_table.weight = ones(height(test_feats_table), 1);

% test_feats_table.Properties.VariableNames = {'target_gap', 'district_id', 'day_slot', 'weekday', 'minute_slot', ...
%                                                 'prev_requests_5','prev_requests_10','prev_requests_15', 'prev_requests_20','prev_requests_25','prev_requests_30',...
%                                                 'prev_gaps_5', 'prev_gaps_10', 'prev_gaps_15', 'prev_gaps_20','prev_gaps_25', 'prev_gaps_30', ...
%                                                 'prev_driver_nums_5', 'prev_driver_nums_10','prev_driver_nums_15','prev_driver_nums_20','prev_driver_nums_25', 'prev_driver_nums_30', ...
%                                                 'prev_ordernum_from_other_5','prev_ordernum_from_other_10','prev_ordernum_from_other_15','prev_ordernum_from_other_20','prev_ordernum_from_other_25','prev_ordernum_from_other_30',...
%                                                 'prev_ordernum_from_other_valid_5', 'prev_ordernum_from_other_valid_10', 'prev_ordernum_from_other_valid_15','prev_ordernum_from_other_valid_20','prev_ordernum_from_other_valid_25','prev_ordernum_from_other_valid_30', ...
%                                                 'weight'};
% save('./final/basic_io/cache_new/test_feats_interval_1.mat', 'test_feats_table', '-v7.3');                                    
% district_id, poi_num
% [poi_data_1, poi_data_2] = read_raw_poi_data();
% 
% % traffic_data: {'all_slot', 'day_slot', 'time_slot', 'minute_slot', 'district_id', 'tj_level_1_cnt', 'tj_level_2_cnt', 'tj_level_3_cnt', 'tj_level_4_cnt' }
% [~, traffic_datas_test] = read_raw_traffic_data();
% 
% % weather_data: {'all_slot', 'day_slot', 'time_slot', 'minute_slot', 'weather', 'temperature', 'PM' };
% [ ~, weather_datas_test ] = read_raw_weather_data();
% 
load('./final/basic_io/cache_new/test_feats.mat', 'test_feats_table');
load('./final/basic_io/cache_new/traffic_datas.mat', 'traffic_datas_test');
load('./final/basic_io/cache_new/order_datas_per5min.mat', 'order_datas_train_per5min');
load('./final/basic_io/cache_new/weather_datas.mat', 'weather_datas_test');


back_variablenames = test_feats_table.Properties.VariableNames;
back_variablenames(1:5) = {'target_gap', 'district_id', 'day_slot', 'weekday', 'minute_slot'};
test_feats_table.Properties.VariableNames = back_variablenames;
%% add average gap 
% grp_perdistr_per5min = grpstats(order_datas_train_per5min, {'district_id', 'time_slot_5min'}, {'mean'}, 'DataVars', {'request', 'gap'});
grp_perdistr_per5min = grpstats(order_datas_train_per5min, {'district_id', 'time_slot_5min'}, {'sum'}, 'DataVars', {'request', 'gap'});
grp_perdistr_per5min.mean_gap = grp_perdistr_per5min.sum_gap/24;
grp_perdistr_per5min.mean_request = grp_perdistr_per5min.sum_request/24;
average_feats = [];
for i = 1:height(test_feats_table)
    if ~mod(i, 1000)
        disp(i);
    end
    slot_5min = test_feats_table.minute_slot(i)/5;
    aver_requests = nan(1, 7);
    aver_gaps = nan(1, 7);
    target_idxs = grp_perdistr_per5min.district_id == test_feats_table.district_id(i) & ...
                  grp_perdistr_per5min.time_slot_5min >= slot_5min - 1 & ...
                  grp_perdistr_per5min.time_slot_5min <= slot_5min;
    if any(target_idxs)
        aver_requests(1) = sum(grp_perdistr_per5min.mean_request(target_idxs));
        aver_gaps(1) = sum(grp_perdistr_per5min.mean_gap(target_idxs));
    end
    for slot_span = 2:7
        target_idxs = grp_perdistr_per5min.district_id == test_feats_table.district_id(i) & ...
                      grp_perdistr_per5min.time_slot_5min == slot_5min - slot_span;
        if any(target_idxs)
            aver_requests(slot_span) = grp_perdistr_per5min.mean_request(target_idxs);
            aver_gaps(slot_span) = grp_perdistr_per5min.mean_gap(target_idxs);
        end
    end
    row_feat = [aver_requests, aver_gaps];
    average_feats = [average_feats; row_feat];
end

average_feats = array2table(average_feats, 'VariableNames', {'aver_request', 'aver_request_5', 'aver_request_10', 'aver_request_15', 'aver_request_20', 'aver_request_25', 'aver_request_30', ...
                                                              'aver_gap', 'aver_gap_5', 'aver_gap_10', 'aver_gap_15', 'aver_gap_20', 'aver_gap_25', 'aver_gap_30'});


%% traffic_feats = [];
traffic_feats = [];
for i = 1:height(test_feats_table)
    if ~mod(i, 1000)
        disp(i);
    end
    target_idxs = traffic_datas_test.district_id == test_feats_table.district_id(i) & ...
                  traffic_datas_test.day_slot == test_feats_table.day_slot(i) & ...
                  traffic_datas_test.minute_slot == (ceil(test_feats_table.minute_slot(i)/10)-2)*10+1;
    row_feat = nan(1, 9);
    if any(target_idxs)
        target_data = table2array(traffic_datas_test(target_idxs, { 'tj_level_1_cnt', 'tj_level_2_cnt', 'tj_level_3_cnt', 'tj_level_4_cnt'}));
        row_feat(1) = sum(target_data);
        row_feat(2:5) = target_data;
        row_feat(6:9) = target_data/row_feat(1);
    end
    traffic_feats = [traffic_feats; row_feat];
end

traffic_feats = array2table(traffic_feats, 'VariableNames', {'total_tj_cnt', 'tj_level_1_cnt', 'tj_level_2_cnt', 'tj_level_3_cnt', 'tj_level_4_cnt', ...
                                                             'tj_level_1_ratio', 'tj_level_2_ratio', 'tj_level_3_ratio', 'tj_level_4_ratio'});

%% add weather
weather_feats = [];
for i = 1:height(test_feats_table)
    if ~mod(i, 1000)
        disp(i);
    end
    target_idxs = weather_datas_test.day_slot == test_feats_table.day_slot(i) & ...
                  weather_datas_test.time_slot == (ceil(test_feats_table.minute_slot(i)/10)-2);
    row_feat = nan(1,2);
    if any(target_idxs)
        target_idxs = find(target_idxs);
        target_idxs = target_idxs(end);
        row_feat(1) = weather_datas_test.weather(target_idxs);
        row_feat(2) = weather_datas_test.PM(target_idxs);
    else
        target_idxs = find(weather_datas_test.day_slot == test_feats_table.day_slot(i));
        [~, closed] = min(abs(weather_datas_test.time_slot(target_idxs) - (ceil(test_feats_table.minute_slot(i)/10)-2)));
        target_idxs = target_idxs(closed);
        row_feat(1) = weather_datas_test.weather(target_idxs);
        row_feat(2) = weather_datas_test.PM(target_idxs);
%         fprintf('error weather in %d\n', i);
    end
    weather_feats = [weather_feats; row_feat];
end
weather_feats = array2table(weather_feats, 'VariableNames', {'weather', 'PM'});

test_feats_table = [test_feats_table, average_feats, traffic_feats, weather_feats];
save('./final/basic_io/cache_new/test_feats_table_interval_1_combined.mat', 'test_feats_table', '-v7.3');
% load('./final/basic_io/cache/test_feats_table_interval_1_combined_detail.mat', 'test_feats_table_interval_1');
% test_feats_table_interval_1 = table2array(test_feats_table_interval_1);
% test_feats_table_interval_1(isnan(test_feats_table_interval_1)) = 0;
% test_feats_table_interval_1 = array2table(test_feats_table_interval_1);
% test_feats_table_interval_1.weight = ones(height(test_feats_table_interval_1), 1);
% writetable(test_feats_table_interval_1, './final/training_file/donnie/test_feat_interval_1_combined_detail.txt', 'WriteVariableNames', false);
end

function weekday = get_weekday(day_slot)
    start_weekday = 2;
    weekday = mod(day_slot-1+start_weekday, 7);
end
