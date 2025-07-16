% setLoadDirStartingPath.m
function setLoadDirStartingPath(path)
%SETLOADDIRSTARTINGPATH Sets the starting path for loading directories.
%   Saves the provided 'path' to 'histoCAT_Data.mat'.

dataFilePath = fullfile(fileparts(mfilename('fullpath')), 'loadDirStartingPath.mat');
loadDirStartingPath = path;

save(dataFilePath, 'loadDirStartingPath');

disp(['Load directory starting path set to: ', path]);

end