function [combos_all_histcount] = Calculate_STDandMean(combos_all,Phenograph_Neighor_Matrix,...
    Phenograph_Vector,Neighbor_Matrix)
%CALCULATE_STDANDMEAN Calculate STD, mean and histcount for permutation test
%
% Input:
% combos_all --> all possible combinations of clusters
% Phenograph_Neighor_Matrix --> matrix with all phenograph clusters and the
% corresponding neighbors
% Phenograph_Vector --> Phenograph cluster for each cell
% Neighbor_Matrix --> matrix with all neighbor ID's
%
% Output:
% combos_all_histcount --> histcount for the individual combinations
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

for i=1:size(combos_all,1)
    % Clean variable
    Ncount = []; Ncount_zero=[]; Find_Cluster_in_PhenoVector = [];
    Intersect_combos_all = []; Get_unique_rows = []; row_cluster_matrix = [];
    column_cluster_matrix = []; Find_cluster_in_neighbormatrix = [];
    
    % Test for the different interactions
    Find_cluster_in_neighbormatrix = find(combos_all(i,1)==Phenograph_Neighor_Matrix);
    [row_cluster_matrix,column_cluster_matrix] = ind2sub(size(Phenograph_Neighor_Matrix),Find_cluster_in_neighbormatrix);
    Find_Cluster_in_PhenoVector = find(combos_all(i,2)==Phenograph_Vector);
    
    % Find intersect between row_cluster_matrix and Find_Cluster_in_PhenoVector
    Intersect_combos_all = intersect(row_cluster_matrix,Find_Cluster_in_PhenoVector);
    % Get the histocount
    Get_unique_rows = unique(Intersect_combos_all);
    Ncount = histc(row_cluster_matrix, Get_unique_rows); % this will give the number of occurences of each unique element
    Ncount_zero = [Ncount;zeros(size(Neighbor_Matrix,1)-size(Intersect_combos_all,1),1)];
    % Save in matrix
    combos_all_histcount(i,3) = mean(Ncount_zero);
end

end

