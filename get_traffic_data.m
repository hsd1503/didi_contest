function rst = get_traffic_data( file_path )
%READ_TRAF Summary of this function goes here
%   Detailed explanation goes here
rst = readtable(file_path, 'Delimiter','\t', 'ReadVariableNames', false);
rst.Properties.VariableNames = {'district_hash' 'tj_level_1' 'tj_level_2' 'tj_level_3' 'tj_level_4' 'time'};
end

