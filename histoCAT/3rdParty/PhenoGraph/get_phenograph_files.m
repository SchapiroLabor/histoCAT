function [phenograph_files] = get_phenograph_files()
    % 1. Define the starting folder
    startFolder = fullfile(pwd, "histoCAT/3rdParty/PhenoGraph");
    
    % 2. Get the path string for the folder and all subfolders
    pathString = genpath(startFolder);
    
    % 3. Split the path string into individual folder paths
    % On Windows, the delimiter is ';', on Unix/Linux/Mac, it is ':'
    if ispc % Check if the system is Windows
        folderList = strsplit(pathString, ';', 'CollapseDelimiters', true);
    else
        folderList = strsplit(pathString, ':', 'CollapseDelimiters', true);
    end
    
    % Remove the last empty cell if it exists from the split
    if isempty(folderList{end})
        folderList(end) = [];
    end
    
    % 4. Loop through each folder to find files and compile the list
    fullPaths = {};
    for i = 1:length(folderList)
        currentFolder = folderList{i};
        
        % Find all files in the current folder (excluding '.' and '..')
        fileInfo = dir(currentFolder);
        
        % Filter out directories
        fileInfo = fileInfo(~[fileInfo.isdir]);
        
        % Create full paths for these files
        currentPaths = fullfile(currentFolder, {fileInfo.name});
        fullPaths = [fullPaths, currentPaths]; % Append to the main list
    end
    
    phenograph_files = string(fullPaths);
end