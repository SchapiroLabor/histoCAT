function Run_Phenograph_Callback
% RUN_PHENOGRAPH_CALLBACK Run Phenograph once button (callback) selected
%
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%retrieve gui data
handles = gethand;
selected_gates = get(handles.list_samples,'Value');
gates = retr('gates');
sessionData = retr('sessionData');
gate_context = retr('gateContext');
 
%set_seed if want to reproduce
rng(2);
 
%data = sessionData(gate_context, selected_channels);
[ selectedset ] = Find_selectedchannels;
data = selectedset;
%normalize
percentile = 99;  
data = mynormalize(data, percentile);

% Run Phenograph
near_neighbors_cell = inputdlg('Nearst Neighbors','Nearst Neighbors',1,{'30'});
if isempty(near_neighbors_cell) == 1
    return;
end

% Random seed yes or no
random_seed = questdlg('Random seed - Yes or No?','Random seed - Yes or No?',{'Yes','No'});

near_neighbors = str2num(near_neighbors_cell{:});
[labels,~,~] = phenograph(data, near_neighbors,'random_seed',random_seed);

%remove fixed seed for name generation
rng('shuffle');
%added to create appropriate name for Phenograph
newPhenograph_name = int2str(randi(10000000000));%horzcat(cell2mat(gates{selected_gates(1),3}((selected_channels)))); 
disp('assigning random number for current Phenograph');
new_channel_name = {sprintf('Phenograph%s',newPhenograph_name)};

%create new session data
opt_gates = selected_gates;
opt_gate_context = gate_context;
new_data = labels;
[sessionData,gates] =  addChannels(new_channel_name, new_data, opt_gate_context,opt_gates, gates, sessionData);
[ pheno_clusters ] = parse_Phenographclusters( sessionData,gates );
custom_gatesfolder = retr('custom_gatesfolder');

% %write tsne channels to file for user's reference
% if exist(fullfile(custom_gatesfolder,'tSNEinfo.txt')) ~= 0
%    fileID = fopen(fullfile(custom_gatesfolder,'tSNEinfo.txt'),'a');
%         
% else
%    fileID = fopen(fullfile(custom_gatesfolder,'tSNEinfo.txt'),'w');
% end
% tsne_channels = horzcat(cell2mat(gates{selected_gates(1),3}((selected_channels))));
% fprintf(fileID,'\ntSNE_%s:%s\n',newbhSNE_name,tsne_channels);
% fclose(fileID);

end