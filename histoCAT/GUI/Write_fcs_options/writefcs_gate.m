function [filename_gatedarea] = writefcs_gate(filegate,pathgate)
% WRITEFCS_GATE: Write out fcs-file of the selected area during manual
% gating.
%
% Input:
% filegate --> user-defined file name with fcs ending
% pathgate --> path to custom gates folder, which is where the fcs-file
% will be saved
%
% Output:
% filename_gatedarea --> full file path to fcs-file that has been written
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Disable extrenal GUI functions
zoom off;
pan off;
handles = gethand;

%Retrieve variables
gates  = retr('gates');
area_selected = retr('area_selected');
selected_gates = get(handles.list_samples,'Value');

%Get all channel names of each selected gate
allnames = cellfun(@(x) gates{x,3}, num2cell(selected_gates),'UniformOutput',false);
%Find neighbor columns for each selected gate
neigh_cols = cellfun(@(x) strncmp(x,'neighbour',9),allnames,'UniformOutput',false);
%Get the amount of neighbor columns each selected gate contains
amount_neighbours = cellfun(@(x) sum(x), neigh_cols);
%Get the index of the selected gate containing the most neighbor columns
max_idx = find(amount_neighbours == max(amount_neighbours));

%Get the channel names of the selected gate with the most neighbor columns
%and get the corresponding columns form the selected area data
varnames = gates{selected_gates(max_idx),3};
area_selected =area_selected(:,1:length(varnames));

%Write fcs-file with single cell data of selected area and corresponding
%channel names
fcs_gatetable = array2table(area_selected,'VariableNames',strrep(varnames,'-','_'));
fca_writefcs(char(fullfile(pathgate,filegate)),area_selected,fcs_gatetable.Properties.VariableNames,fcs_gatetable.Properties.VariableNames);

%Return the file path to the fcs-file
filename_gatedarea = char(fullfile(pathgate,filegate));

end

