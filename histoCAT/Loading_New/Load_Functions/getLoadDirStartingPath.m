% getLoadDirStartingPath.m
function loadDirPath = getLoadDirStartingPath()
%GETLOADDIRSTARTINGPATH Returns the starting path for loading directories.
%   If 'histoCAT_Data.mat' exists and contains 'loadDirStartingPath',
%   it returns that value. Otherwise, it returns the user's home path.

dataFilePath = fullfile(fileparts(mfilename('fullpath')), 'loadDirStartingPath.mat');

if exist(dataFilePath, 'file')
    data = load(dataFilePath, 'loadDirStartingPath');
    if isfield(data, 'loadDirStartingPath')
        loadDirPath = data.loadDirStartingPath;
        return;
    end
end

% If file doesn't exist or doesn't contain the variable, return user's home path
loadDirPath = getUserHomePath(); 

end