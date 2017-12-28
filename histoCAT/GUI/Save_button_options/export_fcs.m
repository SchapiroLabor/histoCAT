function [] = export_fcs(hObject,eventdata,handles)
% EXPORT_FCS: Exports the single cell information (including custom 
% channels but excluding neighbor columns) for each gate in the
% session as a separate fcs-file and saves to custom gates folder.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve session variables
gates = retr('gates');
sessionData = retr('sessionData');
custom_gatesfolder =  retr('custom_gatesfolder');

%Find the neighbor columns for each sample and get rid of the neighbor
%columns in the sessionData
idx_neighbours = cellfun(@(x) find(strncmp(x,'neighbour',9)),gates(:,3),'UniformOutput',false);
neighbor_start = cellfun(@(v) v(1), idx_neighbours(:,1));
amount_neighbors = cellfun(@length, idx_neighbours);
max_neighbors = amount_neighbors == max(amount_neighbors);
%In the sessionData the neighbor colums are at the same index for all samples
neighbor_start_session = neighbor_start(max_neighbors); 


%Find the empty_channels for each selected gate (don't want to export those
%either)
empty_channel_idx_tot = cellfun(@(x) find(strncmp(x,'empty_channel',13)),gates(:,3),'UniformOutput',false);

%If there are no empty channels the last column before the custom
%channels is the last column of the neighbours
em = find(~(cellfun('isempty',empty_channel_idx_tot)));
if isempty(em)
    %If there are no custom channels, only export the sessionData up to
    %before the first neighbor column
    data_without_neighbors = sessionData(:,1:(neighbor_start_session-1));
else
    %If there are empty channels, find the empty channel columns for each
    %sample
    ind = not(cellfun('isempty',empty_channel_idx_tot));
    empty_channel_idx = empty_channel_idx_tot(ind);
    %The empty channels always end in the same column in the sessionData if
    %there are custom channels following
    empty_end = empty_channel_idx{1}(length(empty_channel_idx{1}));
    %Export all columns except for the neighbors and the empty channels
    data_without_neighbors = sessionData(:,[1:(neighbor_start_session-1),empty_end+1:size(sessionData,2)]);
end

%Replace the imageIDs used in histoCAT with the image IDs
%originally assigned by CellProfiler in order to be able to compare
%data with other CellProfiler output (often these are the same IDs
%but sometimes CellProfiler skips a number)
CellIDs_by_CellProfiler = retr('CellIDs_by_CellProfiler');
if ~isempty(CellIDs_by_CellProfiler)
    imageIDs_corresp = sessionData([gates{1:length(CellIDs_by_CellProfiler),2}],1);
    all_originalIDs = cell2mat(CellIDs_by_CellProfiler');
    ImageId_CellId = [imageIDs_corresp,all_originalIDs];
    histoCAT_ImageId_CellId = unique(data_without_neighbors(:,1:2),'rows','stable');
    data_without_neighbors(:,1:2) = changem(data_without_neighbors(:,1:2),ImageId_CellId, histoCAT_ImageId_CellId);
end


%Save each image as an fcs file to custom_gatesfolder
for i=1:length(gates(:,1))
    
    %Get corresponding rows in sessionData
    rows = gates{i,2};
    imagedata = data_without_neighbors(rows,:);
    
    %Get variable names
    header = gates{i,3};
    
    %If there are no custom channels
    if isempty(em) 
        %Get variable names up to before first neighbor column
         header_without_neighbors = header(:,1:(neighbor_start_session-1));
         
    %If there are custom channels
    else
        %Get variable names without neighbors or empty channels
        try
            header_without_neighbors = header(:,[1:(neighbor_start_session-1),empty_end+1:size(sessionData,2)]);
        catch
            %In case of complications with exporting the
            %custom channels, just export the data without the custom cols
            header_without_neighbors = header(:,1:(neighbor_start_session-1));
            imagedata = imagedata(:,1:length(header_without_neighbors));
        end
    end
    %Write to fcs file and store in custom gates folder
    fca_writefcs([fullfile(custom_gatesfolder,strcat(gates{i,1})),'.fcs'], imagedata, header_without_neighbors);
end

disp('fcs files saved in custom_gates folder');
end


