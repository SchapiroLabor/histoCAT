function [meanchannel_gates] = histmean( selectedGates,channel )
% HISTMEAN: Returns the mean of the selected channel across all the selected gates.
%
% Input:
% selectedGates --> currently selected gates
% channel --> currently selected channel
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI variables
sessionData	= retr('sessionData');
gates       = retr('gates');

%Store the indices of the gates in sessionData
intIndices  = getIntIndices;

%Clear/initializing variables
ntotal_count = 0;
store_channelvalues = cell(numel(selectedGates),1);

%Loop through the selected gates
for ngates = selectedGates
    
     %Get the current gate's indices
     currGate = gates{ngates, 2};
     
     %Check what is common in both the current gate and all the selected
     %gates (intIndices)
     if ~isempty(intIndices)
            currGate = intersect(intIndices, currGate);
     end
     
     %Store the corresponding channel data and their size
     store_channelvalues{ngates,1} = sessionData(currGate, channel);
     total(ngates) = size(store_channelvalues{ngates,1},1);
     ntotal_count = ntotal_count + total(ngates);
     
end

%If channelvalues are empty, store empty
store_channelvalues(cellfun(@isempty,store_channelvalues)) = [];

%Calculate the mean of selected channel's aggregated gate columns
meanchannel_gates = mean(cell2mat(store_channelvalues));

%Store variable
put('store_channelvalues',store_channelvalues);

end

