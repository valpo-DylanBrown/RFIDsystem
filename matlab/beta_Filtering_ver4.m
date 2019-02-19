%% ADD %
% Automate registration%
    %ThingSpeak? Automate Students.csv?%
% Fix TimeZone to function through daylight savings time
% Read Channel ID and API key from text file | maybe not
% Read data from q/a
% Find bugs
%% Variables %%
%Input the Channel ID for your ThingSpeak Server
channelID = 699369;
readChannelID = channelID;
% Enter your Read API key (' ')
readAPIKey = '4LTO5DS0KFCMAWEG';

%Input the Channel ID for your ThingSpeak Server
writeChannelID = channelID;
% Enter your Write API key (' ')
writeAPIKey = '8BZUUR7S8I924EN5';
%% Read Data %%
% Pulls data from ThingSpeak API. NumPoints is changeable. Timetable
%can typically be used. Threw excpetions here. Table is changed to a timetable. 
data = thingSpeakRead(readChannelID, 'ReadKey', readAPIKey, 'Fields',1,'NumPoints',100,'outputFormat','table');

%Prints raw ThingSpeak table for debugging
data;

%Changes data from table to timetable. Creates easier filtering
newdata = table2timetable(data);

%Prints timetable for debugging
%% FILTERING %%

%Filters time range from datestr to now (CST) 
% "+0.21" roughly converts UTC to CST. Needs to be altered for later betas
% NOTE THIS DOES NOT ACCOUNT FOR DAYLIGHT SAVINGS TIME
% The "-0.5" subtracts 12 hours from the current datetime. This number can
% be shortened or lengthed depending on needs of clients.
S = timerange((datetime('now')+0.21)-0.5, datetime('now'));


%Creates new timetable with the filtered time range S and rfid
filteredData = newdata(S,:);

%Prints timetable for debugging
%filteredData;

%% STUDENT KEY TABLE %% 
% reads table with student keys
% must be in directory of .m file
% can be read as text (.csv, .txt, .dat) or a spreadsheet
T = readtable('students.csv');

% Address table by the tag IDs
% Tags must be in column 3 or (:, 3) must be changed
tagIDs = table2cell(T(:, 3));
% Sets the table to be addressed by tagIDs
T.Properties.RowNames = tagIDs;

% Add column called "Present" and set to zero
T.Present = zeros(height(T), 1);
% Add a columnt called "Date" and put today's date in
T.Date = repmat({datestr(now, 02)}, height(T), 1); 

% For every filtered tag ID we've found, mark the student present
%  This is accomplished by setting the 'Present' field to 1
for i = 1:length(filteredData.rfid)
    try
        epc = filteredData.rfid{i};      
        T({epc}, :).Present = 1;
    catch ME
        fileID = fopen('log.rtf'); %%opens log file for errors%%
        error = warning(ME.identifier, '%s', ME.message);  %catches exceptions%
        fprintf(fileID, error); %%prints to log file%%
        fclose(fileID); %%closes log%%
        continue
    end
end             

% Make a copy but only save Last name, First name, Present and Date
Tout = T(:, {'lastName', 'firstName', 'Present', 'Date'});

% Write this output to a file 
% Can be outputted to a text (.txt, .dat, .csv) file or 
% Excel (xls,.xlsm,.xlsx) file
writetable(Tout, 'out.xlsx');
%%opens the spreadsheet depending on system
if ismac
    system('open out.xlsx');
elseif ispc
    winopen('out.xlsx');
elseif isunix
    unix('out.xlsx');
end


%% INFORMATION %%
% Compiled on Matlab 2018b
% Compiled on Macbook Pro
% Author - Dylan Brown
% This code is used in part with SparkFun ESP8266 and Arduino to filter
% RFID tags from a database into a classroom attendance system
% Others Involved: Ahmed Almousa, Matthew Bickelhaupt, & Chris Gutschlag