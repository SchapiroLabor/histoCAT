function Run_tsne_Callback
% RUN_TSNE_CALLBACK Runs tSNE and returns the sessionData matrix with the added channels for which tSNE was run
% 
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

% fast tsne is only implemented for 2 dims.
ndims = 2;

%retrieve gui data
handles = gethand;
selected_gates = get(handles.list_samples,'Value');
selected_channels = get(handles.list_channels,'Value');
gates = retr('gates');
sessionData = retr('sessionData');
gate_context = retr('gateContext');
custom_gatesfolder = retr('custom_gatesfolder');
%%%%%%%%%%%%%%%%%%%%%%%%%

if numel(selected_channels) <=1
    msgbox('Please select atleast two or more channels to run tSNE');
    return;
end

MAX_TSNE = 1000000;

if (numel(gate_context) > MAX_TSNE)
    %setStatus(sprintf('Cannot run tSNE locally on more than %g points. Please subsample first.', MAX_TSNE));
    return;
end

msg = 'BH-SNE started. Refer to Command window or std-o for progress.';
hwaitbar = waitbar(0,msg);


tic;
%%Get the data from the correct channel columns
[ selectedset ] = Find_selectedchannels;
data = selectedset;
%normalize
percentile = 99;
data = mynormalize(data, percentile);


try
    map = fast_tsne(data, 110);
catch
    msgbox(...
        ['tSNE Failed: Common causes are \n' ...
        'a) illegal histoCAT installation path - spaces in path.\n' ...
        'b) illegal histoCAT installation path - no writing persmissions in folder.\n' ...
        'c) perplexity too high caused by insufficient number of points.'],...
        'Error','error');
    return;
end

disp(sprintf('map generated in %g m', toc/60));


%undo seed for names
rng('shuffle');
%added to create appropriate names and not bhSNE1 bhSNE2(creates confusion)
newbhSNE_name = int2str(randi(10000000000));%horzcat(cell2mat(gates{selected_gates(1),3}((selected_channels))));
disp('assigning random number for current tSNE');
new_channel_names = cell(1, ndims);

%%Store the new names for the tsne channels
for i=1:numel(new_channel_names)
    new_channel_names{i} = sprintf('tSNE%s_%g',newbhSNE_name,i);
end

%%Prepare the inputs for adding channels to the listbox and sessionData
opt_gates = selected_gates;
opt_gate_context = gate_context;
new_data = map;
%%Function call to add the new channels
[ sessionData,gates ] =  addChannels(new_channel_names, new_data, opt_gate_context,opt_gates, gates, sessionData);

waitbar(1,hwaitbar, 'Done.');

close(hwaitbar);

%write tsne channels to file for user's reference
if exist(fullfile(custom_gatesfolder,'tSNEinfo.txt')) ~= 0
    fileID = fopen(fullfile(custom_gatesfolder,'tSNEinfo.txt'),'a');
    
else
    fileID = fopen(fullfile(custom_gatesfolder,'tSNEinfo.txt'),'w');
end
tsne_channels = horzcat(cell2mat(gates{selected_gates(1),3}((selected_channels))));
fprintf(fileID,'\ntSNE_%s:%s\n',newbhSNE_name,tsne_channels);
fclose(fileID);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
