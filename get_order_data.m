function rst = get_order_data( file_path )
%GET_ORDER_DATA Summary of this function goes here
%   Detailed explanation goes here
rst = readtable(file_path, 'Delimiter','\t','ReadVariableNames',false, 'Format','%s%s%s%s%s%f%s');
rst.Properties.VariableNames = {'order_hash', 'driver_hash', 'passenger_hash', 'start_district_hash', 'dest_district_hash', 'price', 'time'};
end

