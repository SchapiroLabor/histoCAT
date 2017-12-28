function [ samplefolders,fcsfiles_path,HashID ] = Load_SampleFolders(HashID,samplefolders,varargin)
% LOAD_SAMPLEFOLDERS: Main function for loading folders
% The selected folders should contain all *.tiff files for each image (and a mask if exists)
%
% Input variables:
% HashID --> Unique folder IDs
% samplefolders --> paths to the selected sample folders
%
% Output variables:
% samplefolders --> paths to the selected sample folders
% fcsfiles_path --> if there are fcs-files: path to fcs-files, empty string
% otherwise
% HashID --> Unique folder IDs
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%For UnitTest
if nargin == 1   
    %Select sample folders
    samplefolders = uipickfiles('Prompt','Select folders containing tiffs with/without segmentation mask'); 
end

%Make sure user selected folders containing each samples and not individual
%files
check_dir = cellfun(@isdir, samplefolders);
found_notDir = find(check_dir == 0);
if ~isempty(found_notDir)
    errordlg('The tiff images (and segmentation mask) of each acquisition have to be in a single folder. Please select acquisition folders and not individual files! Please see manual for further information.');
    return;
end

%Initiate cell if it's not already one
if iscell(samplefolders) ~= 1
    samplefolders = [];
    fcsfiles_path = [];
    return;
end

%Get the fileparts
[path,name,ext] = cellfun(@fileparts,samplefolders,'UniformOutput',false);

%Get the position of the samples (each sample is stored in a separate folder)
find_dir = find(cellfun(@isdir,samplefolders));
fcsfiles_path(find_dir) = {['']};

%Store HashIDs as unique identifiers like imageids
fullHash = cellfun(@DataHash,samplefolders,'UniformOutput',false);

%If HashID not already present add new, else concatenate to existing
if isempty(HashID) == 1
    HashID = cellfun(@(x) x(1:5),fullHash,'UniformOutput',false);
else
    concatHashes = cellfun(@(x) x(1:5),fullHash,'UniformOutput',false);
    HashID = unique([HashID concatHashes],'stable');
end

end


