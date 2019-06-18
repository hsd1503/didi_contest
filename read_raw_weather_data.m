function [ weather_datas_train, weather_datas_test ] = read_raw_weather_data( )
%READ_RAW_WEATHER_DATA Summary of this function goes here
%   Detailed explanation goes here
cache_file_path = './final/basic_io/cache/weather_datas.mat';
try
    load(cache_file_path, 'weather_datas_train', 'weather_datas_test');
catch
    [train_data_dir, test_data_dir] = get_data_dir();

    train_start_date = datenum('2016-02-23', 'yyyy-mm-dd');
    train_end_date = datenum('2016-03-17',  'yyyy-mm-dd');
    train_day_stride = 1;
    test_start_date = datenum('2016-03-19', 'yyyy-mm-dd');
    test_end_date = datenum('2016-03-31', 'yyyy-mm-dd');
    test_day_stride = 2;

    train_num_days = (train_end_date - train_start_date)/train_day_stride + 1;
    test_num_days = (test_end_date - test_start_date)/test_day_stride + 1 + 14;
    %% read raw order data
    weather_datas_train = [];
    weather_datas_test = [];
    for i = 1:train_num_days
        fprintf('processing %d training weather data\n', i);
        file_name = sprintf('weather_data_%s', datestr(train_start_date+(i-1)*train_day_stride, 'yyyy-mm-dd'));
        weather_datas = get_weather_data(fullfile(train_data_dir, 'weather_data', file_name));
        time_rows = rowfun(@parse_time_slot, weather_datas(:, 'time'), 'OutputVariableNames', {'all_slot','day_slot', 'time_slot', 'minute_slot'});
        weather_datas = [weather_datas, time_rows];
        weather_datas = weather_datas(:, {'all_slot', 'day_slot', 'time_slot', 'minute_slot', 'weather', 'temperature', 'PM' });
        weather_datas_train = [weather_datas_train; weather_datas];
    end
    for i = 1:test_num_days
        fprintf('processing %d test weather data\n', i);
        if i <= 7
            file_name = sprintf('weather_data_%s_test', datestr(test_start_date+(i-1)*test_day_stride, 'yyyy-mm-dd'));
        else 
            file_name = sprintf('weather_data_%s_test', datestr(test_end_date+(i-7), 'yyyy-mm-dd'));
        end
        weather_datas = get_weather_data(fullfile(test_data_dir, 'weather_data', file_name));
        time_rows = rowfun(@parse_time_slot, weather_datas(:, 'time'), 'OutputVariableNames', {'all_slot','day_slot', 'time_slot', 'minute_slot'});
        weather_datas = [weather_datas, time_rows];
        weather_datas = weather_datas(:, {'all_slot', 'day_slot', 'time_slot', 'minute_slot', 'weather', 'temperature', 'PM' });
        weather_datas_test = [weather_datas_test; weather_datas];
    end
    save(cache_file_path, 'weather_datas_train', 'weather_datas_test', '-v7.3');
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
