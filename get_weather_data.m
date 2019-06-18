function rst = get_weather_data( file_path )
%GET_WEATHER_DATA Summary of this function goes here
%   Detailed explanation goes here
rst = readtable(file_path, 'Delimiter', '\t', 'ReadVariableNames', false);
rst.Properties.VariableNames = {'time', 'weather', 'temperature', 'PM'};
end

