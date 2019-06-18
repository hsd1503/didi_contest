function [poi_data_1, poi_data_2]= read_raw_poi_data()
%READ_RAW_POI_DATA Summary of this function goes here
%   Detailed explanation goes here
cache_file_path = './final/basic_io/cache/poi_datas.mat';
try
    load(cache_file_path, 'poi_data_1', 'poi_data_2');
catch
    [train_data_dir, ~] = get_data_dir();
    poi_file_path_1 = fullfile(train_data_dir, 'poi_data', 'poi_data_2');
    poi_file_path_2 = fullfile(train_data_dir, 'poi_data', 'poi_data_1');
    [~, unique_distrs, ~] = get_unique_items();
    poi_data_1 = readtable(poi_file_path_1, 'Delimiter','\t','ReadVariableNames',false);
    poi_data_2 = readtable(poi_file_path_2, 'Delimiter','\t','ReadVariableNames',false);
    headers_1 = arrayfun(@(i)sprintf('first_%d_cnt',i), 1:(width(poi_data_1)-1), 'UniformOutput', false);
    headers_2 = arrayfun(@(i)sprintf('second_%d_cnt',i), 1:(width(poi_data_2)-1), 'UniformOutput', false);
    poi_data_1.Properties.VariableNames = ['district_hash', headers_1];
    poi_data_2.Properties.VariableNames = ['district_hash', headers_2];
    poi_data_1 = join(poi_data_1, unique_distrs,'Keys', 'district_hash');
    poi_data_2 = join(poi_data_2, unique_distrs,'Keys', 'district_hash');
    poi_data_1 = poi_data_1(:, ['district_id', headers_1]);
    poi_data_2 = poi_data_2(:, ['district_id', headers_2]);
    poi_data_1 = sortrows(poi_data_1, [1]);
    poi_data_2 = sortrows(poi_data_2, [1]);
    save(cache_file_path, 'poi_data_1', 'poi_data_2');
end
end

