function Remove_channels_Callback
% REMOVE_CHANNELS_CALLBACK: For the selected gates the selected channels will be
% removed ONLY if they are costum made. If the user selects any of the
% original sample channels and wants to delete them, he will be told that
% this is not possible, since it would destroy the session.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve global variables
global Fcs_Interest_all;
global Sample_Set_arranged;
global HashID;

%Get GUI handles
handles = gethand;

%Retrieve GUI variables
selected_channels = get(handles.list_channels, 'Value');
selected_gates    = get(handles.list_samples,'Value');
gates             = retr('gates');
sessiondata_index = retr('sessiondata_index');
sessionData       = retr('sessionData');
allids = retr('allids');
chan_string = get(handles.list_channels,'String');

%If no channels were selected
if isempty(selected_channels) == 1
    
    %If samples exist and no channels were selected, prompt user to select
    %them first
    if isempty(gates) ~= 1
        msgbox('Please select a channel first');
        
    %If there are no samples in the session, ask user to load them first
    else
        msgbox('Please load samples first');
    end
    
%If channels were selected, get the channel name of the selected channel
else
    chan_todelete = chan_string(selected_channels);
end

%Function call to get sample order and the indices of the selected gates
[  ~, ~, ~ ,sample_orderIDX] = getimageids_of_selectedgates(Sample_Set_arranged,HashID,selected_gates, allids);

%Start count and initialize
count = 1;
com_del = [];

%Loop through selected gates
for j = selected_gates
    
    %Get the original channels of the samples -> deleting these is
    %not allowed
    original_names = Fcs_Interest_all{sample_orderIDX(count)}.Properties.VariableNames;
    
    %Get the indices of the channels to delete
    ntorg_idx = find(~ismember(chan_todelete,original_names));
    
    %If all selected channels are members of the original list, then dont
    %delete and prompt user
    if isempty(ntorg_idx) == 1
        com_del = [com_del ntorg_idx];
        warning('Cannot delete constant channels over all samples');
        
    else
        com_del = 0; 
        %Check where the channels to delete exist in the gates list
        todel_fromgates = find(ismember(gates{j,3},chan_todelete(ntorg_idx)));
        
        %Delete these channels for the current gate
        gates{j,3}(todel_fromgates) = [];
        
        %Fill up the corresponding column with zeros in sessionData for only this gate
        sessionData(sessiondata_index{j}{1}(1):sessiondata_index{j}{1}(2),todel_fromgates) = 0;
    end
end

%If all selected channels were original channels, nothing was deleted
if isempty(com_del) == 1
    msgbox('Cannot delete constant channels over all samples');
end

%Update GUI variables
put('gates',gates);
put('sessionData',sessionData);

%Update list box
list_samples_Callback;

end

