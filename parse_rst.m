function parse_rst()
rst_file = 'D:\projects\didi\xgboost\gggg_period.csv';
rst_table = readtable(rst_file, 'ReadVariableNames', false);
error_0_case_cnt = 0;
error_1_case_cnt = 1;

load('./final/basic_io/cache_new/test_feats.mat');
headers_backup = test_feats_table.Properties.VariableNames;
test_feats_table = table2array(test_feats_table);
test_feats_table(isnan(test_feats_table)) = 0;
test_feats_table = array2table(test_feats_table, 'VariableNames', headers_backup);
for i = 1:height(rst_table)
    distr = rst_table.Var1(i);
%     day_slot = str2double(rst_table.Var2{i}(9:10)) - 18 + 25;
    day_slot = get_day_slot(rst_table.Var2{i});
    time_slot = str2double(rst_table.Var2{i}(12:end));
    sat_idxs = test_feats_table.district_id==distr&test_feats_table.day_slot==day_slot&test_feats_table.minute_slot==time_slot*10;
    prev_gaps = [test_feats_table.prev_gaps_5(sat_idxs), test_feats_table.prev_gaps_10(sat_idxs), ...
                 test_feats_table.prev_gaps_15(sat_idxs), test_feats_table.prev_gaps_20(sat_idxs), ...
                 test_feats_table.prev_gaps_25(sat_idxs), test_feats_table.prev_gaps_30(sat_idxs)];
    if rst_table.Var3(i)>=1 && sum(prev_gaps<=1)>=4 && sum(prev_gaps==0)>=2 && sum(prev_gaps(1:2))==0
        rst_table.Var3(i) = 0;
        error_0_case_cnt = error_0_case_cnt + 1;
    end
    if rst_table.Var3(i)>=2 && sum(prev_gaps<=1)>=5 && sum(prev_gaps==0)>=2 && sum(prev_gaps(1:2))==1
        rst_table.Var3(i) = 1;
        error_1_case_cnt = error_1_case_cnt + 1;
    end
end
disp(error_0_case_cnt);
disp(error_1_case_cnt);
writetable(rst_table,  'D:\projects\didi\xgboost\gggg_period_modified.csv', 'WriteVariableNames', false);
end

function day_slot = get_day_slot(timestr)
    start_date = datenum('2016-02-23', 'yyyy-mm-dd');
    [year, mon, day, ~, ~, ~] = datevec(timestr(1:10),  'yyyy-mm-dd');
    curr_date = datenum(year, mon, day);
    day_slot = curr_date - start_date + 1;
end

function [day_slot, time_slot] = parse_time_slot( time_str )
% convert time to time slot in a day
    start_date = datenum('2016-02-23', 'yyyy-mm-dd');
    [year, mon, day] = datevec(time_str(1:10),  'yyyy-mm-dd');
    curr_date = datenum(year, mon, day);
    day_slot = curr_date - start_date + 1;
    time_slot = str2double(time_str(12:end));
end
