function import_neighbrs( Sample_Set_arranged,Fcs_Interest_all,HashID )
% IMPORT_NEIGHBRS: Imports the neighbrs fcs-file for any selected sample.
%
% Input: 
% Sample_Set_arranged --> Cell containing all file paths to the
% gates in the current session
% HashID --> Contains all hashes of the original gate names in the same
% order as the gates
% Fcs_Interest_all --> Contains all single cell data for each gate in fcs
% format
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%If there is no pixelexpansion set in the GUI, ask user to first chose
%one.
pixelexpansion = retr('pixelexpansion');
if isempty(pixelexpansion)
    msgbox('please define pixel expansion to find neighbours');
    return;
end

%Retrieve variables
selected_gates = get(handles.list_samples,'Value');
gates = retr('gates');
sessnidx = retr('sessiondata_index');
sessionData = retr('sessionData');
custom_gatesfolder =  retr('custom_gatesfolder');
allids = retr('allids');


%Loop through the selected gates
for i=selected_gates
    
    %Find the amount of columns to create for each neighbr fcs
    endfcs = numel((gates{i,3}));
    
    %Find all the columns with the name 'neighbour_CellId' --> the neighbor
    %columns
    neigb_index = find(~cellfun('isempty',(strfind(gates{i,3},['neighbour_',pixelexpansion]))));
    
    %If no neighbrs were found, the sample is probably not segmented
    if isempty(neigb_index) == 1
        disp('Cannot import neighbors for sample not segmented');
        continue;
    end
    
    %Get the image IDs contained in the current gate. These are the images
    %the cells in the current sample originate from.
    [imageids, ~, ~,sample_orderIDX ] = getimageids_of_selectedgates(Sample_Set_arranged,HashID, i, allids);
    
    %Find the selected gate(s) with the max amount of channels
    maxVar = max(cell2mat(cellfun(@(x) size(x,2),gates(sample_orderIDX,3),'UniformOutput',false)));
    max_varidx = find(cell2mat(cellfun(@(x) size(x,2),gates(sample_orderIDX,3),'UniformOutput',false)) == maxVar);
    
    %If there are multiple selected gates with max amount channels get the one with
    %the max amount of neighbor columns and use these variable names later
    if length(max_varidx) > 1
        idx_neighbours = cellfun(@(x) find(strncmp(x,'neighbour',9)),gates(sample_orderIDX,3),'UniformOutput',false);
        max_neigh = max(cellfun(@length, idx_neighbours));
        max_idx = find(cellfun(@length, idx_neighbours)== max_neigh);
        max_varnames = gates{sample_orderIDX(max_varidx(max_idx)),3};
    else
        max_varnames = gates{sample_orderIDX(max_varidx),3};
    end
    
    %Get rows in sessionData corresponding to the selected gates
    rows = [gates{sample_orderIDX,2}];

    %Preallocate to store single-cell data of selected gates
    fcsimagedata = zeros(length(rows),length(max_varnames));

    %Storen single-cell data of selected gates
    fcsimagedata(:,:) = sessionData(rows,1:length(max_varnames));
    
    %Store the neighbor data that was found for the respective samples
    Neighbours_data = horzcat(sessionData(sessnidx{i}{1}(1):sessnidx{i}{1}(2),1),sessionData(sessnidx{i}{1}(1):sessnidx{i}{1}(2),neigb_index));
    idxSesn = sessnidx{i}{1}(1):sessnidx{i}{1}(2);
    
    %Initialize
    data_neighbr_fcs = [];

    %Loop through the Columns of neighbors Cellids
    for eachn=1:length(neigb_index)

        %Find the length of the columns to create for each neighbr fcs
        endfcs = size(fcsimagedata,2);
        
        %Temporarily store
        tempdata = fcsimagedata;

        %Initialize
        store_data = [];

        %Loop through the imageids in the current sample
        for imid = imageids
            
            %Get rows from single-cell data corresponding to current imageID
            curtemp_rows = find(tempdata(:,1) == imid);
            
            %Get rows from sample's neighbor data corresponding to current
            %imageID
            neighb_rows  = find(Neighbours_data(:,1) == imid);      
            
            %Get the rows corresponding to the neighbr data cells from original single-cell data
            found_cellid_match = find(ismember(tempdata(curtemp_rows,2),Neighbours_data(neighb_rows,eachn+1),'rows') & ismember(tempdata(curtemp_rows,1),Neighbours_data(neighb_rows,1),'rows'));
            
            %Remove repeated cellid single-cell data between neighbr data and sample data
            remvdups = find(~ismember(tempdata(curtemp_rows(found_cellid_match),2),sessionData(idxSesn(neighb_rows),2)));

            %Store neighbor data
            store_data = [store_data;tempdata(curtemp_rows(found_cellid_match(remvdups)),:)];

        end
        
        %If the neighbor info was not empty keep adding to variable for all the columns
        if (isempty(store_data)) ~= 1
            data_neighbr_fcs      =  vertcat(data_neighbr_fcs,store_data);
        end
    end
    
    %Update end of fcs information
    put('endfcs',endfcs);
    
    %Since it is possible that the neighbors could be repetitive in certain columns, we extract the the unique rows
    data_neighbr_fcs = unique(data_neighbr_fcs,'rows');

    %Create neighbor fcs-file
    neighbcells = size(data_neighbr_fcs,1);
    pathneighb = custom_gatesfolder;
    fileneighb = strcat('neighboursof',char(gates{i,1}),int2str(neighbcells),'cells.fcs');

    %Write and then import the neighbr fcs-file
    if fileneighb ~= 0
        
        %Function call to write fcs-file
        [filename_ngate] = writefcs_neighbors(fileneighb,pathneighb,data_neighbr_fcs,max_varnames);
        
        %Function call to import fcs-file
        import_gatedarea(filename_ngate);
    end

end

end

