function ExportCSV_singlecells( hObject, eventdata, handles )
% EXPORTCSV_SINGLECELLS: Exports the single cell data (including the
% neighbors) of the selected gates as CSV (in fcs format) and stores them
% in custom gates folder
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve Variables from handel
handles = gethand;
%Gates currently selected
gates = retr('gates');
selected_gates = get(handles.list_samples,'Value');
%Custom folder name
custom_gatesfolder = retr('custom_gatesfolder');
%Get sessionData instead of "Fcs_Interest_all" to export more information
%to the CSV file including PhenoGraph and X and Y coordinates
sessionData = retr('sessionData');
%Get Sample_Set_arranged and Mask all from global
global Sample_Set_arranged
global Mask_all

%Split the file paths of all gates and get the sample names
[~,names] = cellfun(@fileparts,Sample_Set_arranged,'UniformOutput',false);

%Display the location of the CSV files
disp(['All selected gates/samples will be exported as .csv files to ',fullfile(custom_gatesfolder)]);
%Display waitbar
hWaitbar = waitbar(0,['All selected gates/samples will be exported as .csv files']);
%Intitialize waitbar variable
waitbar_i = 0;
%Loop through the selected gates
for sg = selected_gates
    
    %Waitbar variable
    waitbar_i = waitbar_i+1;
    
    %Generate empty table
    table_sessionData_selectedGate = [];
    
    %Get the name of the current sample
    [~,name,~] = fileparts(gates{sg,4});
    
    %Check if CSV file of sample already exists in the custom gates folder
    if exist(fullfile(custom_gatesfolder,strcat(gates{sg},'.csv'))) || exist(fullfile(custom_gatesfolder,strcat(name,'.csv')))
        disp(['Sample already exported ',gates{sg,1}]);
        continue;
    end
    
    %Remove empty channels before output
    Empty_channel_position = strfind(gates{sg,3},'empty_');
    Not_empty_channels = find(cellfun(@isempty,Empty_channel_position));
    
    %Check if x and y positions are included
    Xposition_position = strfind(gates{sg,3},'X_position');
    if any(~cellfun(@isempty,Xposition_position)) == 0
        %Add X and Y coordinates to output
        %Get current mask
        Current_Mask = Mask_all(sg).Image;
        props_spatial_XY = regionprops(Current_Mask, 'Centroid');
        XY_data=cat(1,props_spatial_XY.Centroid);
        %Add X and Y
        XY = {'X_position','Y_position'};
        %Get the single cell data and make a table for each gate selected
        table_sessionData_selectedGate = array2table([sessionData(gates{sg,2},Not_empty_channels),XY_data],...
        'VariableNames',[(gates{sg,3}(Not_empty_channels)),XY]);
    else
        table_sessionData_selectedGate = array2table(sessionData(gates{sg,2},Not_empty_channels),...
        'VariableNames',(gates{sg,3}(Not_empty_channels)));
    end
    
    
    %Replace the imageIDs used in histoCAT with the image IDs
    %originally assigned by CellProfiler in order to be able to compare
    %data with other CellProfiler output (often these are the same IDs
    %but sometimes CellProfiler skips a number)
    CellIDs_by_CellProfiler = retr('CellIDs_by_CellProfiler');
    if ~isempty(CellIDs_by_CellProfiler)
        currSession_ImageId_cellId = unique(sessionData(:,1:2),'rows','stable');
        imageIDs_corresp = sessionData([gates{1:length(CellIDs_by_CellProfiler),2}],1);
        all_originalIDs = cell2mat(CellIDs_by_CellProfiler');
        ImageId_CellId_orig = [imageIDs_corresp,all_originalIDs];
        curr_data = table2array(table_sessionData_selectedGate);
        fcs_names = table_sessionData_selectedGate.Properties.VariableNames;
        curr_data = changem(curr_data,ImageId_CellId_orig,currSession_ImageId_cellId);

        %Get the fcs format data from FCS_Interest_all and save as csv to
        %custom gates folder
        writetable(array2table(curr_data,'VariableNames',fcs_names),fullfile(custom_gatesfolder,strcat(gates{sg},'.csv')));
    else

        %Save as csv to custom gates folder
        writetable(table_sessionData_selectedGate,fullfile(custom_gatesfolder,strcat(gates{sg},'.csv')));
    end
    
    %Update waitbar
    waitbar(waitbar_i/size(selected_gates,2), hWaitbar);
end

close(hWaitbar);

end

