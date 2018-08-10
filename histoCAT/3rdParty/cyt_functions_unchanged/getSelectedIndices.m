function [indices,channels] = getSelectedIndices(selected_gates, gates)
% GETSELECTEDINDICES Gets the indices of the selected gates, and combines all channels of selected gates and displays the common among them in the listbox.
%When an individual sample is selected, it only displays those that have
%data(or non-zeros) and don't display neighbour columns
%
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Input:
% selected_gates --> selected gates in the GUI
% gates --> all gates
%
% Output:
% indices --> indices of selected gates
% channels --> channels selected
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve
sessionData = retr('sessionData');

%extract specific gate or merge multiple gates according to selection
if (numel(selected_gates) == 1)
    indices = gates{selected_gates, 2};
    %incase its a tiff
    if isempty(indices) == 1
        channels = gates{selected_gates, 3};
    else
        getthoseNtzeros = find(~all(sessionData(indices,1:length(gates{selected_gates,3})) == 0,1));
        channels =  gates{selected_gates, 3}(getthoseNtzeros);
        getNtneighbrs = find(~strncmp('neighbour',channels,9));
        if ~isempty(getNtneighbrs)
            channels = channels(getNtneighbrs);
        end
    end
else
    indices = [];
    if (~isempty(selected_gates))
        channels = gates{selected_gates(1),3}; %gates{selected_gates(1),3};
    else
        channels = [];
    end
    
    for i=selected_gates
        curidices = gates{i, 2};
        %incase its a tiff
        if isempty(curidices) == 1
            channels = intersect(gates{i,3},channels,'stable');
            getNtneighbrs = find(~strncmp('neighbour',channels,9));
            if ~isempty(getNtneighbrs)
                channels = channels(getNtneighbrs);
            end
        else
            getthoseNtzeros = find(~all(sessionData(curidices,1:length(gates{i,3})) == 0,1));
            indices = union(gates{i, 2}, indices);
            channels = intersect(gates{i,3}(getthoseNtzeros),channels,'stable');
            getNtneighbrs = find(~strncmp('neighbour',channels,9));
            if ~isempty(getNtneighbrs)
                channels = channels(getNtneighbrs);
            end
        end
    end
end
end
