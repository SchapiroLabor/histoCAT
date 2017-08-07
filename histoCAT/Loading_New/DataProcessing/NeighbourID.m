function [ neighbour_CellId_table,removerows ] = NeighbourID(cellarray_neighbourids,expansionpixels)
% NEIGHBOURID: Function to get the CellIds of the neighbors of each cell at a certain pixelexpansion, in a table.
%
% Input variables:
% cellarray_neighbourids --> cellIDs of neighboring cells at current
% pixelexpansion
% expansionpixels --> current pixelexpansion of 1:6 from loop in NeighbrCells_histoCATsinglecells
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Initialize
count = 1;
removerws = {};

%Construct matrix of neighboring cellIDs
for i=1:length(cellarray_neighbourids)
    try
        length_neighbrid    =   length(cellarray_neighbourids{i,1});
        neighbour_CellId(i,1:length_neighbrid) = cellarray_neighbourids{i,1};
    catch
        %In unlikely case of  missing cellIDs
        removerws{count} = i;
        count = count + 1;
    end
end

%In unlikely case of  missing cellIDs
if isempty([removerws{:}]) ~= 1
    removerows = [removerws{:}];
    neighbour_CellId(removerows,:) = [];
else
    removerows = [];
end

%Make column names for table
neighbour_names = strcat({strcat('neighbour_',num2str(expansionpixels),'_CellId')},...
    int2str((1:size(neighbour_CellId,2)).')).';
neighbour_names_include = strrep(neighbour_names,' ','');

%Convert matrix to table
if isempty(neighbour_CellId) == 1
    neighbour_CellId = zeros(size(neighbour_CellId,1),1);
    neighbour_CellId_table = array2table(neighbour_CellId,'VariableNames',neighbour_names_include);
else
    neighbour_CellId_table = array2table(neighbour_CellId,'VariableNames',neighbour_names_include); 
end

end


