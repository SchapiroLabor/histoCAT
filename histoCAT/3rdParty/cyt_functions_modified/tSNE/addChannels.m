function [sessionData,gates] = addChannels(new_channel_names, new_data, opt_gate_context,opt_gates, gates, sessionData)
% ADDCHANNELS Once t-SNE/Normalization etc. is run this function is will add the newly created channels to the sessionData
% 
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Input:
% new_channel_names --> Cell array of strings with names for the new channels
% new_data --> matrix with new data to add
% opt_gate_context --> gate context
% opt_gates --> selected gate
% gates --> all gates
% sessionData --> full session data
%
% Output:
% sessionData --> Updated session data
% gates --> updated gates
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

if (exist('opt_gate_context','var'))
    gate_context = opt_gate_context;
else
    gate_context = retr('gateContext');
end

if (exist('opt_gates','var'))
    selected_gates = opt_gates;
elseif isempty(opt_gates)
    selected_gates = 1:size(gates, 1);
end

% add necessary channels to the selected gates
defined_channels = cellfun(@(x)numel(x), gates(selected_gates, 3), 'uniformoutput', true);
undef_channel_ind = max(defined_channels)+1;

if (size(sessionData,2)-undef_channel_ind >= 0) && ...
        any(~any(sessionData(gate_context, undef_channel_ind:end)))
    
    % find a streak the same width of new_data of empty columns
    d = diff([false any(sessionData(gate_context, undef_channel_ind:end)) == 0 ones(1, size(new_data, 2)) false]);
    p = find(d==1);
    m = find(d==-1);
    lr = find(m-p>=size(new_data, 2));
    last_def_channel = undef_channel_ind - 1 + (p(lr(1)) - 1);
else
    last_def_channel = size(sessionData,2);
end

for i=selected_gates
    
    % add new channel names to gate
    channel_names = gates{i, 3};
    if (last_def_channel-numel(channel_names) > 0)
        % add blank\placeholder channel names
        for j=numel(channel_names)+1:last_def_channel
            channel_names{j} = strcat('empty_channel',int2str(j));
        end
    end
    channel_names(end+1:end+numel(new_channel_names)) = new_channel_names;
    gates{i, 3} = channel_names;
    
    
end

n_new_columns = size(new_data, 2) - (size(sessionData,2) - last_def_channel);

% extend session data
if (n_new_columns > 0)
    new_columns = zeros(size(sessionData, 1), n_new_columns);
    sessionData = [sessionData new_columns];
end

% set new data to session
sessionData(gate_context, last_def_channel+1:last_def_channel+size(new_data, 2)) = new_data;

%update gui variables
put('sessionData',sessionData);
put('gates',gates);
list_samples_Callback;



end
