function [] = pca_callback()
% PCA_CALLBACK: Runs PCA on selected data and returns to sessionData

% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%PCA similar to tSNE for 2 dimensions
ndims = 2;

%Retrieve GUI data
handles = gethand;
selected_gates = get(handles.list_samples,'Value');
selected_channels = get(handles.list_channels,'Value');
gates = retr('gates');
sessionData = retr('sessionData');
gate_context = retr('gateContext');
custom_gatesfolder = retr('custom_gatesfolder');

%Check if enough channels were selected to run PCA
if numel(selected_channels) <=1
    msgbox('Please select atleast two or more channels to run PCA');
    return;
end

%Get the data from the correct channel columns
[selectedset] = Find_selectedchannels;
data_for_PCA = selectedset;

%Run PCA
[coef, scores, latent] = pca(data_for_PCA,'NumComponents',ndims);
new_data_to_add = scores;

%Assign random number for k-means and afterwards the name
PCA_name = int2str(randi(10000000000));
disp('assigning random number for current PCA');
new_channel_names_to_add = cell(1, ndims);

%Store the new names for the PCA channels
for i=1:numel(new_channel_names_to_add)
    new_channel_names_to_add{i} = sprintf('PCA%s_%g',PCA_name,i);
end

%Prepare the inputs for adding channels to the listbox and sessionData
opt_gates = selected_gates;
opt_gate_context = gate_context;

%Function call to add the new channels
[sessionData,gates] =  addChannels(new_channel_names_to_add, new_data_to_add, opt_gate_context,opt_gates, gates, sessionData);

end

