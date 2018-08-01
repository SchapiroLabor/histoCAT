function [combos_all_histcount] = Calculate_STDandMean(combos_all,Phenograph_Neighor_Matrix,...
    Phenograph_Vector,Neighbor_Matrix,patch_det)
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
    
    % Test for the different interactions
    Find_cluster_in_neighbormatrix = find(combos_all(i,1)==Phenograph_Neighor_Matrix);
    [row_cluster_matrix,~] = ind2sub(size(Phenograph_Neighor_Matrix),Find_cluster_in_neighbormatrix);
    Find_Cluster_in_PhenoVector = find(combos_all(i,2)==Phenograph_Vector);
    
    % Find intersect between row_cluster_matrix and Find_Cluster_in_PhenoVector
    Intersect_combos_all = intersect(row_cluster_matrix,Find_Cluster_in_PhenoVector);
    % Get the histocount
    Get_unique_rows = unique(Intersect_combos_all);
    
    % Include interaction information
    combos_all_histcount(i,1:2) = combos_all(i,1:2);
    % Check if empty
    if isempty(Get_unique_rows)==1
        combos_all_histcount(i,3) = 0;
    else
        
        %For patch detection
        intersectNeighbours = Phenograph_Neighor_Matrix(Intersect_combos_all,:);
        eachLogic = ismember(intersectNeighbours, combos_all(i,1));
        eachCount = sum(eachLogic,2);
        atLeastX = eachCount > patch_det;
        
        % Count all interactions divided by the amount of interacting cells
        combos_all_histcount(i,3) = sum(eachCount)/length(Intersect_combos_all);
        if isnan(combos_all_histcount(i,3))
            combos_all_histcount(i,3) = 0;
        end
    end
end

end


