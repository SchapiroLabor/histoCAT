function [] = Neighborhood_Master(permutations,pixelexpansion,pVal_sig,gates,...
    selectedall_gates,sessionData,custom_gatesfolder,Special_clusters_name,Extra_information,cut_off_percent)
% NEIGHBORHOOD_MASTER Calculates whether a neighboorhood is significant
% Currently only works for all images selected and one Phenograph
% available.
%
% Input:
% permutations --> Amount of permutations
% pixelexpansion --> pixel expansion selected
% pVal_sig --> p-value considered to be significant
% gates --> all gates
% selectedall_gates --> gates selected in the GUI
% sessionData --> all session data
% custom_gatesfolder --> location of the custom gates folder
% Special_clusters_name --> which cluster number do you want to highlight
% and annotate
% Extra_information --> name for the special cluster selected (annotation)
% cut_off_percent --> how many images (ratio: 0-1) need to be represented
% for the significant cluster in the overall data set.
% For example: 0.1 --> 10% of all images need to represent the significant
% cluster.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

% Get expansion name based on pixel expansion
expansion_name = ['neighbour_',num2str(pixelexpansion),'_CellId'];

% Get neighbor index for each image
neigb_index = cellfun(@(x) find(~cellfun('isempty',regexp(x,expansion_name))),...
    gates(selectedall_gates,3),'UniformOutput',false);
% Get phenograph index for each image
Phenograph_index = cellfun(@(x) find(~cellfun('isempty',regexp(x,'Phenograph'))),...
    gates(selectedall_gates,3),'UniformOutput',false);

% for multiple phenograph runs
[max_size, max_index] = max(cellfun('size', Phenograph_index, 2));
Phenograph_index_selected = {};
if max_size>1
    [selected,~] = listdlg('PromptString','Select Phenograph to use',...
        'SelectionMode','single',...
        'ListSize',[160,150],...
        'ListString',gates{max_index,3}(Phenograph_index{1,1}))
    put('selected',selected);
    for i = 1:size(Phenograph_index,1)
        Phenograph_index_selected{i,1} = Phenograph_index{i,1}(selected);
    end
else
    Phenograph_index_selected = Phenograph_index;
end

% Parfor progress bar
hbar = parfor_progressbar(size(selectedall_gates,2),'Please wait...');

% Run neighborhood module and get logic output for corresponing pValue
tic
parfor image_num=1:size(selectedall_gates,2)
    
    
    %     % Check whether gates are present
    %     if selectedall_gates(image_num)==image_num;
    
    [pValue_higher,pValue_lower,real_data_mean,combos_all,Phenograph_index] = Neighborhood_Individual_Image(permutations,...
        selectedall_gates,gates,sessionData,image_num,expansion_name,Phenograph_index_selected);
    Higher_logic = pValue_higher<pVal_sig;
    Lower_logic = pValue_lower<pVal_sig;
    
    % Extract higher and lower logic after pVal_sig for each image
    parfor_gates_high(image_num) = {[combos_all,Higher_logic]};
    parfor_gates_low(image_num) = {[combos_all,Lower_logic]};
    
    %     % Including it into the the gates function (non parfor)
    %     gates{selectedall_gates(image_num),5} = [combos_all,Higher_logic];
    %     gates{selectedall_gates(image_num),6} = [combos_all,Lower_logic];
    %     end
    Phenograph_index_name{image_num} = Phenograph_index;
    hbar.iterate(1);
end
toc
close(hbar);
% Heatmaps for each images individual and special cluster combinations
[Matrix_Delta,Matrix_low,Unique_all,Unique_low_all,Matrix_high,Unique_high_all,pheno_name]...
    = Heatmap_individual_images(parfor_gates_high,parfor_gates_low,selectedall_gates,pixelexpansion,...
    permutations,Phenograph_index_name,custom_gatesfolder,gates,Special_clusters_name,Extra_information,pVal_sig,cut_off_percent);

% Generate an assymmetric heatmap
Asymmetric_heatmap(parfor_gates_high,parfor_gates_low, Matrix_high,...
    Matrix_low,Unique_high_all,Unique_low_all,pheno_name,pixelexpansion,permutations,custom_gatesfolder,Extra_information,pVal_sig,cut_off_percent);

end

