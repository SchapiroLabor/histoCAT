function [] = kmeans_callback()
%KMEANS_CALLBACK: Runs kmeans on selected data and returns to sessionData

% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI data
handles = gethand;
selected_gates = get(handles.list_samples,'Value');
gates = retr('gates');
sessionData = retr('sessionData');
gate_context = retr('gateContext');

%Get the data from the correct channel columns
[selectedset] = Find_selectedchannels;
data_to_kmeans = selectedset;

%Ask the user for amount clusters and interactions
answers = inputdlg({'Number of clusters:','iterations'},'k-means',1,{'20','100'});
amount_clusters = str2double(answers(1))
interations = str2double(answers(2))

%Run k-means
new_data_to_add = kmeans(data_to_kmeans,amount_clusters,'Replicates', interations)

%Assign random number for k-means and afterwards the name
newbhSNE_name = int2str(randi(10000000000));
disp('assigning random number for current k-means');
new_channel_names_to_add = cell(1, 1);
new_channel_names_to_add{1} = sprintf('k_mean_k_%g_it_%g_%s',amount_clusters,interations,newbhSNE_name);

%Prepare the inputs for adding channels to the listbox and sessionData
opt_gates = selected_gates;
opt_gate_context = gate_context;

%Function call to add the new channels
[sessionData,gates] =  addChannels(new_channel_names_to_add, new_data_to_add, opt_gate_context,opt_gates, gates, sessionData);

end


