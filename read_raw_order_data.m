function [order_datas_train, order_datas_test] = read_raw_order_data()
%PROCESS_ORDER_DATA Summary of this function goes here
%   Detailed explanation goes here
cache_file_path = './final/basic_io/cache/order_datas.mat';
try
    load(cache_file_path, 'order_datas_train', 'order_datas_test');
catch
    [train_data_dir, test_data_dir] = get_data_dir();

    train_start_date = datenum('2016-02-23', 'yyyy-mm-dd');
    train_end_date = datenum('2016-03-17',  'yyyy-mm-dd');
    train_day_stride = 1;
    test_start_date = datenum('2016-03-19', 'yyyy-mm-dd');
    test_end_date = datenum('2016-03-31', 'yyyy-mm-dd');
    test_day_stride = 2;

    [unique_drivers, unique_distrs, unique_passengers] = get_unique_items();

    train_num_days = (train_end_date - train_start_date)/train_day_stride + 1;
    test_num_days = (test_end_date - test_start_date)/test_day_stride + 1 + 14;
    %% read raw train order data
%     order_datas_train = [];
%     order_datas_test = [];
    order_datas_train = cell(train_num_days, 1);
    order_datas_test = cell(test_num_days, 1);
    parfor i = 1:train_num_days
        fprintf('processing %d training order data\n', i);
        file_name = sprintf('order_data_%s', datestr(train_start_date+(i-1)*train_day_stride, 'yyyy-mm-dd'));
        order_datas = get_order_data(fullfile(train_data_dir, 'order_data', file_name));
        order_datas = join(order_datas, unique_distrs,'LeftKeys','start_district_hash','RightKeys','district_hash');
        order_datas.start_district_id = order_datas.district_id;
        order_datas.district_id = [];
        order_datas = join(order_datas, unique_distrs,'LeftKeys','dest_district_hash','RightKeys','district_hash');
        order_datas.dest_district_id = order_datas.district_id;
        order_datas.district_id = [];
        order_datas = join(order_datas, unique_drivers,'Keys','driver_hash');
        order_datas = join(order_datas, unique_passengers, 'Keys', 'passenger_hash');
        time_rows = rowfun(@parse_time_slot, order_datas(:, 'time'), 'OutputVariableNames', {'all_slot','day_slot', 'time_slot', 'minute_slot', 'second_slot'});
        order_datas = [order_datas, time_rows];
        order_datas = order_datas(:, {'all_slot', 'day_slot', 'time_slot', 'minute_slot', 'second_slot' ,'start_district_id', 'dest_district_id','passenger_id' ,'driver_id', 'price'});
%         order_datas_train = [order_datas_train; order_datas];
        order_datas_train{i} = order_datas;
    end
    order_datas_train = cat(1, order_datas_train{:});
    %% read raw test data
    parfor i = 1:test_num_days
        fprintf('processing %d test order data\n', i);
        if i <= 7
            file_name = sprintf('order_data_%s_test', datestr(test_start_date+(i-1)*test_day_stride, 'yyyy-mm-dd'));
        else 
            file_name = sprintf('order_data_%s_test', datestr(test_end_date+(i-7), 'yyyy-mm-dd'));
        end
        order_datas = get_order_data(fullfile(test_data_dir,'order_data', file_name));
        order_datas = join(order_datas, unique_distrs,'LeftKeys','start_district_hash','RightKeys','district_hash');
        order_datas.start_district_id = order_datas.district_id;
        order_datas.district_id = [];
        order_datas = join(order_datas, unique_distrs,'LeftKeys','dest_district_hash','RightKeys','district_hash');
        order_datas.dest_district_id = order_datas.district_id;
        order_datas.district_id = [];
        order_datas = join(order_datas, unique_drivers,'Keys','driver_hash');
        order_datas = join(order_datas, unique_passengers, 'Keys', 'passenger_hash');
        time_rows = rowfun(@parse_time_slot, order_datas(:, 'time'), 'OutputVariableNames', {'all_slot', 'day_slot', 'time_slot', 'minute_slot', 'second_slot'});
        order_datas = [order_datas, time_rows];
        order_datas = order_datas(:, { 'all_slot', 'day_slot', 'time_slot', 'minute_slot','second_slot', 'start_district_id', 'dest_district_id', 'passenger_id' ,'driver_id', 'price'});
%         order_datas_test = [order_datas_test; order_datas];
        order_datas_test{i} = order_datas;
    end
    order_datas_test = cat(1, order_datas_test{:});
    save(cache_file_path, 'order_datas_train', 'order_datas_test', '-v7.3');
end
end

function [all_slot, day_slot, time_slot, minute_slot, second_slot ] = parse_time_slot( time_str )
% convert time to time slot in a day
    start_date = datenum('2016-02-23', 'yyyy-mm-dd');
    [year, mon, day, hour, minute, second] = datevec(time_str,  'yyyy-mm-dd HH:MM:SS');
    curr_date = datenum(year, mon, day);
    day_slot = curr_date - start_date + 1;
    time_slot = hour*6 + floor(minute/10) + 1;
    minute_slot = hour*60 + minute + 1;
    second_slot = ceil(second/10) + 1;
    all_slot = (day_slot-1)*1440*6 + (minute_slot-1)*6 + second_slot;
end

