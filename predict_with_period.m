function predict_with_period()
    predict_table = readtable('D:\projects\didi\final\result\season2\gggg.csv', 'ReadVariableNames', false);
    predict_table.Properties.VariableNames = {'district_id', 'date', 'pred_val'};
    predict_table.day_slot = ones(height(predict_table), 1);
    predict_table.time_slot = ones(height(predict_table), 1);
    for i = 1:height(predict_table)
        [predict_table.day_slot(i), predict_table.time_slot(i)] = parse_time_slot(predict_table.date{i});
    end
%     time_rows = rowfun(@parse_time_slot, predict_table(:, 'date'), 'OutputVariableNames', {'day_slot', 'time_slot'});
%     predict_table = [predict_table, time_rows];
    load('./final/basic_io/cache_new/order_datas_perslot.mat');
    order_datas_train_perslot.weekday = get_weekday(order_datas_train_perslot.day_slot);
    order_datas_test_perslot.weekday = get_weekday(order_datas_test_perslot.day_slot);
%     period_districts = [44,8,21,32,38,24,19,22];
    period_districts = [8, 9, 16, 21, 44, 14, 15, 23, 32, 38, 2, 3, 19, 22, 24];
%     period_districts = 1:58;
    aver_wave_workday = zeros(58, 144);
    aver_wave_weekend = zeros(58, 144);
    
    for distr = period_districts
        order_datas_curr_distr = order_datas_train_perslot(order_datas_train_perslot.district_id==distr, :);
        for j = 1:height(order_datas_curr_distr)
            if order_datas_curr_distr.weekday(j)<=5
                aver_wave_workday(distr, order_datas_curr_distr.time_slot(j)) = aver_wave_workday(distr, order_datas_curr_distr.time_slot(j))...
                                                                                 + order_datas_curr_distr.gap(j);
            else
                aver_wave_weekend(distr, order_datas_curr_distr.time_slot(j)) = aver_wave_weekend(distr, order_datas_curr_distr.time_slot(j))...
                                                                                 + order_datas_curr_distr.gap(j);
            end
        end
    end
    aver_wave_workday = aver_wave_workday/18;
    aver_wave_weekend = aver_wave_weekend/6;
    
    cnt = 0;
    ratio_weight = [1/3;1/3;1/3];
    for i = 1:height(predict_table)
        curr_id = predict_table.district_id(i);
        if ismember(curr_id, period_districts)
            cnt = cnt + 1;
           time_slot = predict_table.time_slot(i);
           day_slot = predict_table.day_slot(i);
           feats = zeros(3,1);
           for j = 1:3
               curr_feat = order_datas_test_perslot.gap(order_datas_test_perslot.district_id==curr_id & ...
                                                order_datas_test_perslot.day_slot==day_slot & ...
                                                order_datas_test_perslot.time_slot == time_slot -j);
               if ~isempty(curr_feat)
                   feats(j) = curr_feat;
               end
           end
           weekday = get_weekday(day_slot);
           if weekday<=5
               aver_prev_vals = aver_wave_workday(curr_id, time_slot-1:-1:time_slot-3);
               target_val = aver_wave_workday(curr_id, time_slot);
               ratio = feats(:)./aver_prev_vals(:);
               ratio(ratio==Inf|isnan(ratio)) = 1;
               predict_table.pred_val(i) = round(0.5*predict_table.pred_val(i) + 0.5*sum(ratio.*ratio_weight)*target_val);
           else
               aver_prev_vals = aver_wave_weekend(curr_id, time_slot-1:-1:time_slot-3);
               target_val = aver_wave_weekend(curr_id, time_slot);
               ratio = feats(:)./aver_prev_vals(:);
               ratio(ratio==Inf|isnan(ratio)) = 1;
               predict_table.pred_val(i) = round(0.5*predict_table.pred_val(i) +  0.5*sum(ratio.*ratio_weight)*target_val);
           end
        end
    end
    disp(cnt);
    submit_table = predict_table(:, {'district_id', 'date', 'pred_val'});
    writetable(submit_table, 'D:\projects\didi\xgboost\gggg_period.csv', 'WriteVariableNames', false);
end

function [day_slot, time_slot] = parse_time_slot( time_str )
% convert time to time slot in a day
    start_date = datenum('2016-02-23', 'yyyy-mm-dd');
    [year, mon, day] = datevec(time_str(1:10),  'yyyy-mm-dd');
    curr_date = datenum(year, mon, day);
    day_slot = curr_date - start_date + 1;
    time_slot = str2double(time_str(12:end));
end

function weekday = get_weekday(day_slot)
    start_weekday = 2;
    weekday = mod(day_slot-1+start_weekday, 7);
    weekday(weekday==0) = 7;
end