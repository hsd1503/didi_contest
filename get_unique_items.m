function [unique_drivers, unique_distrs, unique_passengers] = get_unique_items()
%GET_UNIQUE_ITEMS Summary of this function goes here
%   Detailed explanation goes here
cache_file_path = './final/basic_io/cache_new/unique_ids.mat';
try
    load(cache_file_path, 'unique_drivers', 'unique_distrs', 'unique_passengers');
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
    unique_drivers = cell.empty();
    unique_distrs = cell.empty();
    unique_passengers = cell.empty();

    for i = 1:train_num_days
        fprintf('processing %d training order data\n', i);
        file_name = sprintf('order_data_%s', datestr(train_start_date+(i-1)*train_day_stride, 'yyyy-mm-dd'));
        order_datas = get_order_data(fullfile(train_data_dir, 'order_data', file_name));
        unique_distrs = union(unique_distrs, unique([order_datas.start_district_hash; order_datas.dest_district_hash]));
        unique_drivers = union(unique_drivers, unique(order_datas.driver_hash));
        unique_passengers = union(unique_passengers, unique(order_datas.passenger_id));
    end
    for i = 1:test_num_days
        fprintf('processing %d test order data\n', i);
        if i <= 7
            file_name = sprintf('order_data_%s_test', datestr(test_start_date+(i-1)*test_day_stride, 'yyyy-mm-dd'));
        else
            file_name = sprintf('order_data_%s_test', datestr(test_end_date+(i-7), 'yyyy-mm-dd'));
        end
        order_datas = get_order_data(fullfile(test_data_dir,'order_data', file_name));
        unique_distrs = union(unique_distrs, unique([order_datas.start_district_hash; order_datas.dest_district_hash]));
        unique_drivers = union(unique_drivers, unique(order_datas.driver_hash));
        unique_passengers = union(unique_passengers, unique(order_datas.passenger_hash));
    end
    clustermap = get_clustermap(fullfile(train_data_dir, 'cluster_map', 'cluster_map'));
    clustermap = sortrows(clustermap, [2]);
    unique_distrs = setdiff(unique_distrs, clustermap.district_hash);
    unique_distrs = [clustermap.district_hash; unique_distrs];
    unique_distrs = table(unique_distrs, (1:length(unique_distrs))');
    unique_drivers = table(unique_drivers, (1:length(unique_drivers))');
    unique_passengers = table(unique_passengers, (1:length(unique_passengers))');
    
    % load previous saved unique items
    
    unique_distrs.Properties.VariableNames = {'district_hash', 'district_id'};
    unique_drivers.Properties.VariableNames = {'driver_hash', 'driver_id'};
    unique_passengers.Properties.VariableNames = {'passenger_hash', 'passenger_id'};
    
 
    save(cache_file_path, 'unique_distrs', 'unique_drivers', 'unique_passengers');
end
end

function rst = get_clustermap(file_path)
    rst = readtable(file_path, 'Delimiter', '\t', 'ReadVariableNames', false);
    rst.Properties.VariableNames = {'district_hash', 'district_id'};
end

