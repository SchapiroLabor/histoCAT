function ZScore_Normalize()
% ZSCORE_NORMALIZE: Normalizes data using the ZScore.
% Each selected channel is treated individually but across all selected sample.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI hanldes
handles = gethand;

%Get selected channels and gates
selected_gates = get(handles.list_samples,'Value');
selected_channels = get(handles.list_channels,'Value');

%Retrieve variables
gates = retr('gates');
sessionData = retr('sessionData');
gate_context = retr('gateContext');

%Get all raw data for the selected gates and channels
[data_raw] = Find_selectedchannels;
if isempty(data_raw) == 1
    disp('No single cell data available for selected sample');
    return;
end

%Normalize the data using ZScore individually for each channel
data_ZScore = zscore(data_raw);

%Generate new channel names for normalized data
new_channel_names = strcat('ZScoreNorm_',handles.list_channels.String(selected_channels));

%Add normalized channels to list_channels box
addChannels(new_channel_names,data_ZScore, gate_context,selected_gates, gates, sessionData);

end

