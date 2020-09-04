function [Matrix_Delta,Matrix_low,Unique_all,Unique_low_all,Matrix_high,Unique_high_all,pheno_name]...
    = Heatmap_individual_images(parfor_gates_high,parfor_gates_low,selectedall_gates,pixelexpansion,permutations,...
    Phenograph_index,custom_gatesfolder,gates,Special_clusters_name,Extra_information,pVal_sig,cut_off_percent,patch_det)
% HEATMAP_INDIVIDUAL_IMAGES Generates a clustergram with each image individual
%
% Input:
% parfor_gates_high, parfor_gates_low --> matrix with all combinations of
% PhenoGraph clusters and the corresponding significants (1 or 0) after pValue
% cut-off
% selectedall_gates --> gates selected in the GUI
% pixelexpansion --> pixel expansion selected
% permutations --> Amount of permutations
% Phenograph_index --> Which PhenoGraph name selected
% custom_gatesfolder --> location of the custom gates folder
% gates --> all gates
% Special_clusters_name --> which cluster number do you want to highlight
% and annotate
% Extra_information --> name for the special cluster selected (annotation)
% pVal_sig --> p-value considered to be significant
% cut_off_percent --> how many images (ratio: 0-1) need to be represented
%
% Output:
% Matrix_Delta --> all interactions in a heatmap where one tail is
% substracted from the other one
% Unique_all --> all unique combinations for both tails
% Matrix_low, Matrix_high --> all interactions in a heatmap for each tail
% Unique_low_all, Unique_high_all --> unique combinations of interactions
% pheno_name --> PhenoGraph name
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

% Global interpreter none for latex
set(0,'DefaultTextInterpreter','none');

Matrix_cut = [];
% Extract all combinations into one matrix with index for gate/image for
% high and low
Higher_logic_gate_output = [];
for i=1:size(parfor_gates_high,2)
    index_for_image_high = ones(size(parfor_gates_high{1,i},1),1)*i;
    Higher_logic_gate_output = [Higher_logic_gate_output;index_for_image_high,parfor_gates_high{1,i}];
end
Lower_logic_gate_output = [];
for i=1:size(parfor_gates_low,2)
    index_for_image_low = ones(size(parfor_gates_low{1,i},1),1)*i;
    Lower_logic_gate_output = [Lower_logic_gate_output;index_for_image_low,parfor_gates_low{1,i}];
end

% Calculate the delta matrix (high-low)
Delta_logic_gate_output = [Higher_logic_gate_output(:,1:3),Higher_logic_gate_output(:,4)-Lower_logic_gate_output(:,4)];

% Generate neighborhood matrix
[~, ~, interaction_index] = unique(Delta_logic_gate_output(:,[2 3]),'rows'); % get interaction identifiers
Matrix_Delta = accumarray([Delta_logic_gate_output(:,1) interaction_index], ...
    Delta_logic_gate_output(:,4), [], @sum, NaN); % build result, with NaN as fill value
% Generate neighborhood matrix high
[~, ~, interaction_index_high] = unique(Higher_logic_gate_output(:,[2 3]),'rows'); % get interaction identifiers
Matrix_high = accumarray([Higher_logic_gate_output(:,1) interaction_index_high], Higher_logic_gate_output(:,4), [], @sum, NaN);
% Generate neighborhood matrix low
[~, ~, interaction_index_low] = unique(Lower_logic_gate_output(:,[2 3]),'rows'); % get interaction identifiers
Matrix_low = accumarray([Lower_logic_gate_output(:,1) interaction_index_low], Lower_logic_gate_output(:,4), [], @sum, NaN);

% Save unique combinations for heatmap names
Unique_all = unique(Higher_logic_gate_output(:,[2 3]),'rows');
Unique_all_string = arrayfun(@num2str, Unique_all, 'UniformOutput', false);
Unique_all_string_names = strcat(Unique_all_string(:,1),'_',Unique_all_string(:,2));

% Save unique combinations for heatmap names
Unique_high_all = unique(Higher_logic_gate_output(:,[2 3]),'rows');

% Save unique combinations for heatmap names
Unique_low_all = unique(Lower_logic_gate_output(:,[2 3]),'rows');

% Show heatmap
for k=1:size(Matrix_Delta,2)
    if length(unique(Matrix_Delta(:,k)))==1 && unique(Matrix_Delta(:,k)) == 0
        Matrix_cut(k)=0;
    else
        Matrix_cut(k)=1;
    end
end

Matrix_Delta_cut= Matrix_Delta(:,logical(Matrix_cut));
Unique_all_string_names_cut = Unique_all_string_names(logical(Matrix_cut));

% Get PhenoGraph name and location
selected = retr('selected');
pheno_name = char(gates{1,3}(cell2mat((Phenograph_index{1,1}(1)))));
if size(pheno_name,1) > 1
    pheno_name = pheno_name(selected,:);
end

Matrix_Delta_cut_noNaN = Matrix_Delta_cut;

% For clustergram replace NaN's with zeros
Matrix_Delta_cut_noNaN(isnan(Matrix_Delta_cut_noNaN)) = 0;

% Generate only if more than 1 image selected for neighborhood analysis
if size(Matrix_Delta_cut_noNaN,1) == 1
    msgbox('No clustergram since only one image selected');
    return
else
    % Clustergram for all images
    Delta = clustergram(Matrix_Delta_cut_noNaN,'RowLabels',gates(selectedall_gates',1)...
        ,'ColumnLabels',Unique_all_string_names_cut,...
        'Cluster','all','linkage','ward','Colormap',redbluecmap); addTitle...
        (Delta,['Deltaclustergram for all images with Pixel',...
        num2str(pixelexpansion),'_Perm_',num2str(permutations),'_',pheno_name,'_',Extra_information]);
    plot_delta =plot(Delta);
    
    % Save clustergram for all images
    saveas(plot_delta,fullfile(custom_gatesfolder,['Clustergram_all_Pixel',num2str(pixelexpansion),'_PatchDetection',num2str(patch_det),...
        '_Perm_',num2str(permutations),'_',pheno_name,'_',Extra_information,'significance_cutoff',num2str(pVal_sig),'.fig']));
    
    
    % Search for special cases
    Special_clusters = [];
    Special_clusters = find(~cellfun(@isempty,regexp(Unique_all_string_names,strcat('_',Special_clusters_name,'$|^',Special_clusters_name,'_'),'match')));
    Special_cluster= Matrix_Delta(:,Special_clusters);
    
    % Show heatmap
    for j=1:size(Special_cluster,2)
        if length(unique(Special_cluster(:,j)))==1 && unique(Special_cluster(:,j)) == 0
            Special_cluster_cut(j)=0;
        else
            Special_cluster_cut(j)=1;
        end
    end
    
    Matrix_cut_special= Special_cluster(:,logical(Special_cluster_cut));
    Matrix_cut_special_noNaN = Matrix_cut_special;
    Matrix_cut_special_noNaN(isnan(Matrix_cut_special_noNaN)) = 0;
    
    % Adapt column labels
    Special_for_columnlabel = Unique_all_string_names(Special_clusters,:);
    Special_for_columnlabel_cut = Special_for_columnlabel(logical(Special_cluster_cut));
    
    % Clustergram for special output
    higher_special = clustergram(Matrix_cut_special_noNaN,'RowLabels',gates(selectedall_gates,1),'ColumnLabels',Special_for_columnlabel_cut,...
        'Cluster','all','linkage','ward','Colormap',redbluecmap); addTitle(higher_special,['Delta_Special_Pixel',num2str(pixelexpansion),'_Perm_',permutations,'_',pheno_name,'_',Special_clusters_name,'_',Extra_information]);
    plot_delta_special =plot(higher_special);
    
    % Save special output clustergram
    saveas(plot_delta_special,fullfile(custom_gatesfolder,['Clustergram_special_Pixel',num2str(pixelexpansion),'_PatchDetection',num2str(patch_det),'_Perm_',num2str(permutations),'_',pheno_name,'_SpecialCluster',Special_clusters_name,'_',Extra_information,'significance_cutoff',num2str(pVal_sig),'.fig']));
    
    
    % User input: Do you want to save an interactive clustergram into the
    % customs folder?
    save_data_forInteractive = questdlg('Would you like to save the data to rebuild the interactive clustergram?','Interactive clustergram');
    if strcmp(save_data_forInteractive,'Yes')
        save(fullfile(custom_gatesfolder,['Data_for_interactive_clustergram_','pixelexpansion',num2str(pixelexpansion),'_PatchDetection',num2str(patch_det),'_Perm',num2str(permutations),'_',pheno_name,'_',Extra_information,'significance_cutoff',num2str(pVal_sig),'.mat']))
    end
end
end

