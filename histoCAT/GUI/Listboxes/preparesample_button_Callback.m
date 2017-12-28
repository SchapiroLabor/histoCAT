function preparesample_button_Callback(hObject, eventdata, handles)
% PREPARESAMPLE_BUTTON_CALLBACK: Executed when Prepare button is clicked.
%
% hObject: handle to preparesample_button (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Disable external GUI functions
zoom off;
pan off;
rotate3d off;
datacursormode off;

%Set the listbox
list_samples_Callback;

%Get GUI handles and variables
handles = gethand;
global Sample_Set_arranged;
global Fcs_Interest_all;
global HashID;

%If import neighbors option is selected
Logic_Neighbrs = strcmp(handles.preparesample_options.String{handles.preparesample_options.Value},...
    'Import Neighbors');
if Logic_Neighbrs == 1
    %Function call to import neighbors of selected samples
    import_neighbrs( Sample_Set_arranged,Fcs_Interest_all,HashID );
end

%If merge samples is selected
Logic_Merge = strcmp(handles.preparesample_options.String{handles.preparesample_options.Value},...
    'Merge Samples');
if Logic_Merge == 1
    %Function call to merge selected samples into one gate
    Merging_samples( Sample_Set_arranged,Fcs_Interest_all,HashID );
end

%If normalize channels option is selected
Logic_Normalize = strcmp(handles.preparesample_options.String{handles.preparesample_options.Value},...
    'Normalization');
if Logic_Normalize
    %Function call to Z-score normalize the selected channels for the
    %selected samples
    ZScore_Normalize;
end

%If neighborhood analysis option is selected
Logic_Neighbrhood = strcmp(handles.preparesample_options.String{handles.preparesample_options.Value},...
    'Neighborhood Analysis');
if Logic_Neighbrhood
    %Function call to run neighborhood analysis on the selected samples
    Neighborhood_callback;
end

%If custom clustering option is selected
Logic_customClusters = strcmp(handles.preparesample_options.String{handles.preparesample_options.Value},...
    'Custom Clustering');
if Logic_customClusters
    %Function call to generate custom clustering based on selected samples
    custom_clusters;
end


end

