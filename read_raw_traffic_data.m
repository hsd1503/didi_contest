function [traffic_datas_train, traffic_datas_test] = read_raw_traffic_data( )
%READ_RAW_TRAFFIC_DATA Summary of this function goes here
%   Detailed explanation goes here
cache_file_path = './final/basic_io/cache/traffic_datas.mat';
try
    load(cache_file_path, 'traffic_datas_train', 'traffic_datas_test');
catch
    [train_data_dir, test_data_dir] = get_data_dir();

    train_start_date = datenum('2016-02-23', 'yyyy-mm-dd');
    train_end_date = datenum('2016-03-17',  'yyyy-mm-dd');
    train_day_stride = 1;
    test_start_date = datenum('2016-03-19', 'yyyy-mm-dd');
    test_end_date = datenum('2016-03-31', 'yyyy-mm-dd');
    test_day_stride = 2;

    [~, unique_distrs, ~] = get_unique_items();

    train_num_days = (train_end_date - train_start_date)/train_day_stride + 1;
    test_num_days = (test_end_date - test_start_date)/test_day_stride + 1 + 14;
    %% read raw order data
    traffic_datas_train = [];
    traffic_datas_test = [];
    for i = 1:train_num_days
        fprintf('processing %d training traffic data\n', i);
        file_name = sprintf('traffic_data_%s', datestr(train_start_date+(i-1)*train_day_stride, 'yyyy-mm-dd'));
        traffic_datas = get_traffic_data(fullfile(train_data_dir, 'traffic_data', file_name));
        traffic_datas = join(traffic_datas, unique_distrs,'Keys','district_hash');
        time_rows = rowfun(@parse_time_slot, traffic_datas(:, 'time'), 'OutputVariableNames', {'all_slot','day_slot', 'time_slot', 'minute_slot'});
        traffic_datas = [traffic_datas, time_rows];
        tj_level_1_num = rowfun(@parse_traffic_level, traffic_datas(:, 'tj_level_1'), 'OutputVariableNames',...
                                {'tj_level_1_cnt'});
        tj_level_2_num = rowfun(@parse_traffic_level, traffic_datas(:, 'tj_level_2'), 'OutputVariableNames',...
                                {'tj_level_2_cnt'});
        tj_level_3_num = rowfun(@parse_traffic_level, traffic_datas(:, 'tj_level_3'), 'OutputVariableNames',...
                                {'tj_level_3_cnt'});
        tj_level_4_num = rowfun(@parse_traffic_level, traffic_datas(:, 'tj_level_4'), 'OutputVariableNames',...
                                {'tj_level_4_cnt'});
        traffic_datas = [traffic_datas, tj_level_1_num, tj_level_2_num, tj_level_3_num, tj_level_4_num];
        traffic_datas = traffic_datas(:, {'all_slot', 'day_slot', 'time_slot', 'minute_slot', 'district_id', 'tj_level_1_cnt', 'tj_level_2_cnt', 'tj_level_3_cnt', 'tj_level_4_cnt' });
        traffic_datas_train = [traffic_datas_train; traffic_datas];
    end
    for i = 1:test_num_days
        fprintf('processing %d test traffic data\n', i);
        if i <= 7
            file_name = sprintf('traffic_data_%s_test', datestr(test_start_date+(i-1)*test_day_stride, 'yyyy-mm-dd'));
        else 
            file_name = sprintf('traffic_data_%s_test', datestr(test_end_date+(i-7), 'yyyy-mm-dd'));
        end
%         file_name = sprintf('traffic_data_%s_test', datestr(test_start_date+(i-1)*test_day_stride, 'yyyy-mm-dd'));
        traffic_datas = get_traffic_data(fullfile(test_data_dir, 'traffic_data', file_name));
        traffic_datas = join(traffic_datas, unique_distrs, 'Keys', 'district_hash');
        time_rows = rowfun(@parse_time_slot, traffic_datas(:, 'time'), 'OutputVariableNames', {'all_slot','day_slot', 'time_slot', 'minute_slot'});
        traffic_datas = [traffic_datas, time_rows];
        tj_level_1_num = rowfun(@parse_traffic_level, traffic_datas(:, 'tj_level_1'), 'OutputVariableNames',...
                                {'tj_level_1_cnt'});
        tj_level_2_num = rowfun(@parse_traffic_level, traffic_datas(:, 'tj_level_2'), 'OutputVariableNames',...
                                {'tj_level_2_cnt'});
        tj_level_3_num = rowfun(@parse_traffic_level, traffic_datas(:, 'tj_level_3'), 'OutputVariableNames',...
                                {'tj_level_3_cnt'});
        tj_level_4_num = rowfun(@parse_traffic_level, traffic_datas(:, 'tj_level_4'), 'OutputVariableNames',...
                                {'tj_level_4_cnt'});
        traffic_datas = [traffic_datas, tj_level_1_num, tj_level_2_num, tj_level_3_num, tj_level_4_num];
        traffic_datas = traffic_datas(:, {'all_slot', 'day_slot', 'time_slot', 'minute_slot', 'district_id', 'tj_level_1_cnt', 'tj_level_2_cnt', 'tj_level_3_cnt', 'tj_level_4_cnt' });
        traffic_datas_test = [traffic_datas_test; traffic_datas];
    end
    save(cache_file_path, 'traffic_datas_train', 'traffic_datas_test', '-v7.3');
end
end

function [all_slot, day_slot, time_slot, minute_slot ] = parse_time_slot( time_str )
% convert time to time slot in a day
    start_date = datenum('2016-02-23', 'yyyy-mm-dd');
    [year, mon, day, hour, minute, ~] = datevec(time_str,  'yyyy-mm-dd HH:MM:SS');
    curr_date = datenum(year, mon, day);
    day_slot = curr_date - start_date + 1;
    time_slot = hour*6 + floor(minute/10) + 1;
    minute_slot = hour*60 + minute + 1;
    all_slot = (day_slot-1)*1440 + minute_slot;
end

function level_num = parse_traffic_level(level_str)
    tmp = strsplit(level_str{1}, ':');
    level_num = str2double(tmp{2});
end

