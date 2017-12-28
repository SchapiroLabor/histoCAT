function intIndices=getIntIndices
% GETINTINDICES Get integer indices for gates
%
% This function is from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

    handles = gethand;
    gates = retr('gates');
    selIntGates = get(handles.list_samples,'Value');

    intIndices = [];
    
        for i=selIntGates
            intIndices = union(intIndices, gates{i, 2});
        end
    
end