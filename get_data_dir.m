function [train_data_dir, test_data_dir] = get_data_dir( )
%GET_DATA_DIR Summary of this function goes here
%   Detailed explanation goes here
    raw_data_dir = 'D:\projects\didi\rawdata\final_season_2';
    train_data_dir = fullfile(raw_data_dir, 'training_set');
    test_data_dir = fullfile(raw_data_dir, 'test_set', 'test_set_2');
end

