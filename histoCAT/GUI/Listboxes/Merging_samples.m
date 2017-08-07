function [ merged_data ] = Merging_samples( Sample_Set_arranged,Fcs_Interest_all,HashID )
% MERGING_SAMPLES: Gets called when 'Merge samples' from the prepare samples 
% drop down menu is executed. This function will merge the selected samples 
% into one gate, save the new gate as fcs-file to the custom gates folder and import
% it into the sessionData/ the samples listbox.
%
% Input:
% Sample_Set_arranged --> paths to all sample folders in session (historical)
% Fcs_Interest_all --> all individual images as tables with their single-cell information in fcs
% format
% HashID --> Unique folder IDs
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve GUI variables
sessionData = retr('sessionData');
sessiondata_index = retr('sessiondata_index');
selected_gates = get(handles.list_samples,'Value');
gates = retr('gates');
custom_gatesfolder =  retr('custom_gatesfolder');

%Initialize variable
merged_data = [];

%Get the union of the variable names (channels) of the selected gates, in the 
%same order as in the original gates
variablesmax = unique([gates{selected_gates,3}],'stable');

%Loop through the selected gates
for ms=selected_gates
    
    %If data of the currently selected gate is found
    if isempty(sessiondata_index{ms}{1}) ~= 1

        %Initialize matrix of zeros to the size needed
        currentdata = zeros(numel(sessiondata_index{ms}{1}(1):sessiondata_index{ms}{1}(2)),numel(variablesmax));
        
        %Find the indices of the variable names in the sessionData
        [~,findgateidx] = ismember(variablesmax,gates{ms,3});
        findgateidx(findgateidx == 0) = [];
        findvaridx = find(ismember(variablesmax,gates{ms,3}));
        
        %If the variable names were found in the sessionData
        if isempty(findgateidx) ~= 1
            
            %Store the data in those respective columns corresponding to the variablenames union
            currentdata(:,findvaridx) = sessionData(sessiondata_index{ms}{1}(1):sessiondata_index{ms}{1}(2),findgateidx);
        end
        
        %Concatenate the data of all selected gates vertically into merged_data
        merged_data = vertcat(merged_data,currentdata);
    end
    
end

%Update GUI data
put('merged_data',merged_data);
put('variablesmax',variablesmax);

%If the merged data is not empty
if isempty(merged_data) ~= 1
    
    %Store the merged data as fcs-file in the custom gates folder
    pathmerged = custom_gatesfolder;
    namefcs = inputdlg('Give a name for the merged samples');
    filemerged = strcat(char(namefcs{:}),'.fcs');

    %If the filename is valid
    if strcmp(filemerged,'.fcs') ~= 1
        
        %Write out the fcs-file
        [filename_merged] = writefcs_merged(filemerged,pathmerged,merged_data);
        
        %If no file has been stored, return
        if isempty(filename_merged) == 1
            return;
            
        %If fcs-file was stored, import it as new gate
        else
            import_gatedarea( filename_merged );
        end
        
    else
        return;
    end
    
%Inform user that gates cannot be merged if merged_data was empty and
%return
else
    disp('Cannot merge tiffs');
    return;
end

end

