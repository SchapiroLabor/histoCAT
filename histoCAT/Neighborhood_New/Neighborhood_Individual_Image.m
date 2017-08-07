function [pValue_higher,pValue_lower,real_data_mean,combos_all,Phenograph_index] = Neighborhood_Individual_Image(permutations,...
    selectedall_gates,gates,sessionData,image_num,expansion_name,Phenograph_index_selected)
% NEIGHBORHOOD_INDIVIDUAL_IMAGE Calculates the pValues for left/right tailed permutation test
% 
% Input:
% permutations --> Amount of permutations
% selectedall_gates --> gates selected in the GUI
% gates --> all gates
% sessionData --> all session data
% image_num --> image number
% expansion_name --> pixel expansion value for regexp
% Phenograph_index_selected --> Which PhenoGraph name selected
% 
% Output:
% pValue_higher,pValue_lower --> pValues for right/left tailed permutation test
% real_data_mean --> mean interactions for the real data set
% Phenograph_index --> Which PhenoGraph name selected
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%change default interpreter from tex to none
set(gca,'TickLabelInterpreter','none')
% Get neighbor index for each image
neigb_index = cellfun(@(x) find(~cellfun('isempty',regexp(x,expansion_name))),...
    gates(selectedall_gates,3),'UniformOutput',false);
% Get phenograph index for each image
Phenograph_index = cellfun(@(x) find(~cellfun('isempty',regexp(x,'Phenograph'))),...
    gates(selectedall_gates,3),'UniformOutput',false);

% Generate a matrix for only CellID, Neighbors and Phenograph
% We added +1 to use the index also for cells which have zero neighbors
Neighbor_Matrix = sessionData(gates{selectedall_gates(image_num),2},[neigb_index{image_num,1}]);
Neighbor_Matrix_index = Neighbor_Matrix+1;
Phenograph_Vector = sessionData(gates{image_num,2},[Phenograph_index_selected{image_num,1}]);
Phenograph_Vector_index =[0;Phenograph_Vector];

% Replace all neighbors with corresponding cell type
Phenograph_Neighor_Matrix = Phenograph_Vector_index(Neighbor_Matrix_index);

% Calculate all possible interactions
Available_Labels = unique(Phenograph_Vector);
combos_oneside = nchoosek(Available_Labels,2);
combos_all = [combos_oneside;fliplr(combos_oneside);[Available_Labels,Available_Labels]];

combos_all_histcount = [combos_all,zeros(size(combos_all,1),1)];


% Run through all combos_all_histcount
[combos_all_histcount_real] = Calculate_STDandMean(combos_all,Phenograph_Neighor_Matrix,...
    Phenograph_Vector,Neighbor_Matrix);

for p=1:permutations
    combos_all_histcount_Perm_single = [];Phenograph_Vector_perm = [];
    Phenograph_Vector_index_perm = [];
    % Generate matrix for permutation
    Phenograph_Vector_perm = Phenograph_Vector(randperm(length(Phenograph_Vector)));
    Phenograph_Vector_index_perm = [0;Phenograph_Vector_perm];
    % Replace all neighbors with corresponding cell type
    Phenograph_Neighor_Matrix_perm = Phenograph_Vector_index_perm(Neighbor_Matrix_index);
    % Run through all combos_all_histcount
    [combos_all_histcount_Perm_single] = Calculate_STDandMean(combos_all,Phenograph_Neighor_Matrix_perm,...
        Phenograph_Vector_perm,Neighbor_Matrix);
    combos_all_histcount_Perm(:,p+2) = combos_all_histcount_Perm_single(:,3);
end

% Calculate p-values
% Get real data and permutated data
real_data_mean = combos_all_histcount_real(:,3);
perm_data_mean = combos_all_histcount_Perm(:,3:end);
% Calculate amount higher or lower than mean (logic matrix)
% What is the likelihood realdata is higher than random?
Higher_perm_test=repmat(real_data_mean,1,size(perm_data_mean,2))<=perm_data_mean;
% What is the likelihood realdata is lower than random?
Lower_perm_test=repmat(real_data_mean,1,size(perm_data_mean,2))>=perm_data_mean;
% Calculate sum of lower and higherstat
Amount_higher = sum(Higher_perm_test,2);
Amount_lower = sum(Lower_perm_test,2);
% Calculate actuall pValues
pValue_higher = (Amount_higher+1)/(permutations+1);
pValue_lower = (Amount_lower+1)/(permutations+1);

end