function [Tested_Clustering_Index] = Check_if_equal_and_replace(Clustering_Index)
%CHECK_IF_EQUAL_AND_REPLACE Tests if the individual clustering methods are
% present across the samples selected for neighborhood analysis
%   Detailed explanation goes here

% Check if empty
Cluster_available = cellfun(@isempty,Clustering_Index);
% Check if equal
if range(Cluster_available) == 0
    Tested_Clustering_Index = Clustering_Index;
else
    Tested_Clustering_Index = [];
end

end

