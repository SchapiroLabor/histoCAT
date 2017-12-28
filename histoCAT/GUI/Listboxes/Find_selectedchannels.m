function [ selectedset ] = Find_selectedchannels
%FIND_SELECTEDCHANNELS: To find the selected channels for each sample irrespective of
%how they are selected. This resolves the problem when channels are
%selected for normalize or tSNE.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI handles
handles = gethand;

%Retrieve Variables
gates = retr('gates');
selected_samples = get(handles.list_samples,'Value');
selected_channels = get(handles.list_channels,'Value');
sessionData = retr('sessionData');
channels = get(handles.list_channels,'String');

%Initialize
selectedset = [];

%Loop through selected gates
for i = selected_samples
    
    %Get the value of the selected channel from the selected gate
    [~,curidxval,channelval] = intersect(channels(selected_channels),gates{i,3},'stable');
    
    %Store gate index
    gateindex  = gates{i,2};
    
    create_zeros = zeros(numel(gateindex),numel(channels(selected_channels)));
    create_zeros(:,curidxval) = sessionData(gateindex,channelval);
   
    %Vertcat the sessionData information for the gate index (rows in sessionData) and gate channels
    selectedset = vertcat(selectedset,create_zeros); 
    
end


end

