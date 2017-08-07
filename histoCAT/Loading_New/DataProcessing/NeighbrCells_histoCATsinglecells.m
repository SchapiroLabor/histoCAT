function [ Fcs_Interest_all,length_neighbr,sizes_neighbrs ] = NeighbrCells_histoCATsinglecells( rownum,allvarnames,expansionfeature,Current_channels,Current_Mask,...
    Current_singlecellinfo,Fcs_Interest_all,length_neighbr,sizes_neighbrs,HashID,k )
% NEIGHBRCELLS_HISTOCATSINGLECELLS: This function finds the neighboring cells and 
% updates all neighbor ID's to the Fcs_interest_all table and the
% sessionData matrix. Runing all possibilities (1:6) of pixelexpansions when searching for neighboring
% cells and storing the found neighbors for each.
%
% This functions are modified from CellProfiler (1.0.9717)
% http://cellprofiler.org/previous_releases/
%
% Input variables:
% rownum --> loop for each images individual
% allvarnames --> all variable names for this particular image
% expansionfeature --> how many pixels to expand cells for defining neighborhood
% Current_channels --> current channel names without neighbors, incl. basic
% features from region props
% Current_Mask --> mask of current image
% Current_singlecellinfo --> data incl. basic features from region props
% (corresponding to current channel names)
% Fcs_Interest_all --> all tables (individual images) with the single cell information in fcs
% format style
% length_neighbr --> sizes_neighbrs --> allocate the table for each image
% using exact size for individual neighborhood size
% HashID --> Unique identifier for single image
%
% Output variables:
% Fcs_Interest_all --> (Updated) all tables with the single cell information in fcs
% length_neighbr --> sizes_neighbrs --> allocate the table for each image
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Load image size
[sr,sc]  = size(Current_Mask);

%List of pixel indices (linear)
props     = regionprops(Current_Mask,'PixelIdxList');
lenIDs    = unique(Current_Mask);
len       = double(lenIDs(lenIDs ~= 0));
centroids_cell = struct2cell(regionprops(Current_Mask,'Centroid'));

%Initialize variables
neighbour_CellId_table_all = [];
neighbr_cells          = {};
numbr_of_neighbors     = [];
imid_cellid = [];

%Looping through all the cells in an Image Mask to get percent touching and
%number neighbors
for CellId = len'

    %Coordinates of each CellId
    [r,c] = ind2sub([sr sc],props(CellId).PixelIdxList);

    %The below conditions check the min and max conditions for each.Do NOT CHANGE
    rmax = min(sr,max(r) + (expansionfeature));
    rmin = max(1,min(r)  - (expansionfeature));
    cmax = min(sc,max(c) + (expansionfeature));
    cmin = max(1,min(c)  - (expansionfeature));

    %Get percent tounching starting with the patch (CellProfiler)
    patch = Current_Mask(rmin:rmax,cmin:cmax);
    %Find boundary pixel of current cell (CellProfiler)
    se = strel('disk', expansionfeature);
    BoundaryPixels = bwperim(patch == CellId, 8);
    %Remove the current cell, and dilate the other objects (CellProfiler)
    OtherCellsMask = imdilate((patch > 0) & (patch ~= CellId), se, 'same');
    PercentTouching(CellId) = sum(OtherCellsMask(BoundaryPixels)) / sum(BoundaryPixels(:));

    %Extend cell to find neighbors
    extended = imdilate(patch==CellId,se,'same');
    overlap = patch(extended);
    neighbr_cells{CellId} = setdiff(unique(overlap(:)),[0,CellId]);
    numbr_of_neighbors(CellId,:) = length(neighbr_cells{CellId});

    %Store HashID as the imageID (first column)
    imid_cellid   = [imid_cellid;[hex2dec(HashID{rownum}) CellId]];
    
end %Finished all CellIds

%Initializing waitbar
hWaitbar = waitbar(0,['Updating Single Cell Information for Image', num2str(k)]);

%Run through each variant of pixelexpansion and get neighboring cells
for expansionNeighbrs=1:6

    CellId = len';
    
    %Get coordinates of each CellId
    [r,c] = cellfun(@(x) ind2sub([sr sc],x),{props(CellId).PixelIdxList},'UniformOutput', false);

    %The below conditions check the min and max conditions for each.Do NOT CHANGE
    rmax = cellfun(@(x) min(sr,max(x) + (expansionNeighbrs)), r);
    rmin = cellfun(@(x) max(1,min(x)  - (expansionNeighbrs)),r);
    cmax = cellfun(@(x) min(sc,max(x) + (expansionNeighbrs)),c);
    cmin = cellfun(@(x) max(1,min(x)  - (expansionNeighbrs)),c);
    se = strel('disk', expansionNeighbrs);
    idxr = cellfun(@(x,y) x:y, num2cell(rmin),num2cell(rmax),'UniformOutput',false);
    idxc = cellfun(@(x,y) x:y, num2cell(cmin),num2cell(cmax),'UniformOutput',false);
    patch = cellfun(@(x,y) Current_Mask(x,y),idxr,idxc,'UniformOutput',false);

    extended = cellfun(@(x,y) imdilate(x==y,se,'same'),patch,num2cell(CellId),'UniformOutput',false);
    overlap = cellfun(@(x,y) x(y),patch,extended,'UniformOutput',false);
    unOverlap = cellfun(@(x) unique(x)', overlap(:),'UniformOutput',false);
    id_count = cellfun(@(x) [0,x],num2cell(CellId),'UniformOutput',false);
    neighbr_cells(CellId) = cellfun(@(x,y) setdiff(x,y), unOverlap,id_count','UniformOutput',false);

    %Function call to get the cellIds of the neighbrs in a table
    [neighbour_CellId_table,~]= NeighbourID(neighbr_cells',expansionNeighbrs);
    neighbour_CellId_table_all = [neighbour_CellId_table_all,neighbour_CellId_table];
    
    %Update waitbar
    waitbar(expansionNeighbrs/6, hWaitbar);
end

waitbar(1, hWaitbar, 'Ready! ...');
close(hWaitbar);

%Add Neighbour CellIds as a table
[length_neighbr(rownum),sizes_neighbrs(rownum)] = size(neighbour_CellId_table_all);
temp_tableimidcellid = array2table(imid_cellid,'VariableNames',{'ImageId','CellId'});

%Add percent touching as table
temp_table_percenttouch = array2table(PercentTouching','VariableNames',{'Percent_Touching'});

%Add number of neighbors as table
temp_table_NumberNeighbors = array2table(numbr_of_neighbors,'VariableNames',{'Number_Neighbors'});
[~,idx_cur] = ismember(Current_channels,allvarnames);
cur_cells = zeros(size(Current_singlecellinfo,1),numel(allvarnames));
cur_cells(:,idx_cur) = Current_singlecellinfo;

%Add variable names as table
try
    temp_tableSinglecells = array2table(cur_cells,'VariableNames',allvarnames);
catch
    removesplcharacters = regexprep(allvarnames,'[^a-zA-Z0-9_]','');
    remove_beginnum = regexprep(removesplcharacters,'^[0-9]*','');
    temp_tableSinglecells = array2table(cur_cells,'VariableNames',remove_beginnum);
end

%Store single cell table, image and cellID table and neighbor table
put('temp_tableSinglecells',temp_tableSinglecells)
put('temp_tableimidcellid',temp_tableimidcellid);
put('neighbour_CellId_table',neighbour_CellId_table_all);

%Store everything in fcs file structure in FCS_Interest_all
Fcs_Interest_all{rownum,1} = [temp_tableimidcellid temp_tableSinglecells temp_table_percenttouch temp_table_NumberNeighbors neighbour_CellId_table_all];

end