function [] = Asymmetric_heatmap(~,~,...
    Matrix_high,Matrix_low,Unique_high_all,Unique_low_all,pheno_name,...
    pixelexpansion,permutations,custom_gatesfolder,Extra_information,pVal_sig,cut_off_percent,patch_det)
% ASYMMETRIC_HEATMAP Generates "asymmetric" heatmap for neighborhood results
%
% Input:
% Matrix_high, Matrix_low --> Matrix from left/right tailed permutation test
% 1 = significant; 0 = present not significant; -1 = not present
% Unique_high_all, Unique_low_all --> Unique interactions from right/left
% tailed permutation test
% pheno_name --> PhenoGraph name used
% pixelexpansion --> pixel expansion used
% permutations --> amount permutations used
% custom_gatesfolder --> location custom gates folder
% Extra_information --> name for the special cluster selected (annotation)
% pVal_sig --> p-value considered to be significant
% cut_off_percent --> how many images (ratio: 0-1) need to be represented
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

% change default interpreter from tex to none
set(gca,'TickLabelInterpreter','none')

% Calculate sum or mean of all present clusters using the significants
% output. -1 should be transformed to NaN
Matrix_high(Matrix_high == -1) = NaN;
Matrix_low(Matrix_low == -1) = NaN;

% Exclude clusters which are only present in a few images
% We are using (cut-off) images at least
Clusters_to_exclude_high = sum(isnan(Matrix_high))>(size(Matrix_high,1)-(size(Matrix_high,1)*cut_off_percent));
% Get mean using only present clusters
Sum_all_matrix_high = nanmean(Matrix_high,1);
% Remove clusters not present in (cut-off) images
Sum_all_matrix_high(Clusters_to_exclude_high) = 0;
Sum_all_for_transformation_high = [Unique_high_all Sum_all_matrix_high'];

n = max(Sum_all_for_transformation_high(:, 1));
m = max(Sum_all_for_transformation_high(:, 2));
SymmetricHeatMap_high = nan(n, m);
for i = 1:length(Sum_all_for_transformation_high)
    SymmetricHeatMap_high(Sum_all_for_transformation_high(i, 1), Sum_all_for_transformation_high(i, 2)) ...
        =Sum_all_for_transformation_high(i, 3);
end

% Exclude clusters which are only present in a few images
% We are using (cut-off) images at least
Clusters_to_exclude_low = sum(isnan(Matrix_low))>(size(Matrix_low,1)-(size(Matrix_low,1)*cut_off_percent));
Sum_all_matrix_low = nanmean(Matrix_low,1);
% Remove clusters not present in (cut-off) images
Sum_all_matrix_low(Clusters_to_exclude_low) = 0;

Sum_all_for_transformation_low = [Unique_low_all Sum_all_matrix_low'];
n = max(Sum_all_for_transformation_low(:, 1));
m = max(Sum_all_for_transformation_low(:, 2));
SymmetricHeatMap_low = nan(n, m);
for i = 1:length(Sum_all_for_transformation_low)
    SymmetricHeatMap_low(Sum_all_for_transformation_low(i, 1), Sum_all_for_transformation_low(i, 2)) ...
        =Sum_all_for_transformation_low(i, 3);
end

figure()

SymmetricHeatMap_high(isnan(SymmetricHeatMap_high)) = 0;
SymmetricHeatMap_low(isnan(SymmetricHeatMap_low)) = 0;

Delta_allvsall = SymmetricHeatMap_high-SymmetricHeatMap_low;
x = 1:size(Delta_allvsall,2);
y = (1:size(Delta_allvsall,1))';
%get rid of rows and columns that are all empty
x( :, ~any(Delta_allvsall,1) ) = [];
y( ~any(Delta_allvsall,2), : ) = [];
Delta_allvsall( ~any(Delta_allvsall,2), : ) = [];
Delta_allvsall( :, ~any(Delta_allvsall,1) ) = [];

imagesc(Delta_allvsall);
colormap(b2r(min(min(Delta_allvsall)),max(max(Delta_allvsall))));
title(['Heatmap_Pixel',num2str(pixelexpansion),'_',Extra_information,'_PatchDetection',num2str(patch_det),'_Perm_',permutations,'_',pheno_name]);
set(gca,'Xtick',1:length(x),'Ytick',1:length(y),'XtickLabel',x,'YtickLabel',y);

%custom_gatesfolder =  retr('custom_gatesfolder');
saveas(gca,[custom_gatesfolder,'/','Heatmap_Pixel',num2str(pixelexpansion),'_Perm_',num2str(permutations),'_',pheno_name,'_',Extra_information,'significance_cutoff',num2str(pVal_sig),'.fig']);

end

