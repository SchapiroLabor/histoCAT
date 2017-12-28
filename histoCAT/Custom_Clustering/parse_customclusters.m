function parse_customclusters
% PARSE_CUSTOMCLUSTERS: Imports the individual clusters of the custom
% clustering as separate gates, similar to the parse_Phenographclusters
% function.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve variables
selected_gates = get(handles.list_samples,'Value');
custom_gatesfolder = retr('custom_gatesfolder');
gates = retr('gates');
sessionData = retr('sessionData');
 
%Initialize variables
ClusterIDs_pre = [];
num_pheno = [];
pheno_clusters = {};
 
%Get the unique customClusters string index from one of the selected gates(it
%is the last generated)
found_string = cellfun(@(x) find(~cellfun('isempty',regexp(x,'customClusters'))),gates(selected_gates(1),3),'UniformOutput',false);
found_string = found_string{1}(end);
 
%Get custom clustering column in sessionData
custom_cluster_idx = find(ismember(gates{1,3},gates{selected_gates(1),3}(found_string)));
 
%Find gate with maximum number of channels
ends = cellfun(@length,gates(selected_gates,3));
end_max = max(ends);
max_idx = find(ends==end_max);
max_idx = max_idx(1);
 
%Get all channel names of currently selected gates
gates_selected = gates(selected_gates,:);
var_names = gates_selected{max_idx,3};
 
%Find custom clustering column in current gates
clusterdata_pheno = ismember(var_names,gates_selected{max_idx,3}(found_string));

%Get the unique cluster numbers and ignore zeros
ClusterIDs_pre  = [ClusterIDs_pre;sessionData(:,custom_cluster_idx)];
clusterIDs = unique(ClusterIDs_pre(:,1));
clusterIDs = clusterIDs(clusterIDs ~= 0);
 
%Ask the user if they want to load the clusters into miCAT
quest_pheno = questdlg('Do you want to load all the clusters?',...
    'Load Phenograph Clusters',...
    'Yes','No','Cancel','Cancel');
 
%If user requests them to be loaded
if strcmp(quest_pheno,'Yes') == 1
    
        %Check if the number of clusters are more than 50, this is optional
        %and could be taken out to load more clusters
        if numel(clusterIDs) > 50
            disp('Too many Clusters to load..');
            
            %If its the first time for loading or the number of clusters
            %selected is still >50, keep asking to select upto 50
            while (isempty(num_pheno) == 1) || (numel(num_pheno) > 50)
                [num_pheno,~] = listdlg('PromptString','Select only upto 50 clusters to load..',...
                    'SelectionMode','multiple',...
                    'ListSize',[160,150],...
                    'ListString',clusterIDs);
                
                %Get the index of the clusters selected and restore
                clusterIDs = clusterIDs(num_pheno);
            end
        end
 
    %Initialize loading bar
    phenoLoadWaitbar = waitbar(0,'Loading phenograph Clusters, Please wait..');
    
    %Loop through the cluster IDs and import each corresponding data as a
    %gate
    for id=1:length(clusterIDs')
        
        %Check in the custom clustering column of sessionData, which ones are
        %equal to the current id
        idx_id =  ismember(sessionData(:,custom_cluster_idx),clusterIDs(id));
        
        %Store the unique rows corresponding to that cluster number
        pheno_clusters_cur = sessionData(idx_id,:);
        [~,iu,~] = unique(pheno_clusters_cur(:,1:2),'rows');
        pheno_clusters{id} = pheno_clusters_cur(iu,:);
 
        %Update loading bar
        waitbar(id/length(clusterIDs'), phenoLoadWaitbar);
        
        %If empty channels are added to the end
        if size(pheno_clusters{id},2) > length(var_names)
            pheno_clusters{id} = pheno_clusters{id}(:,1:length(var_names));
        end
 
        %Write out fcs files for each gate
        fcsfilename = fullfile(custom_gatesfolder,strcat(var_names{clusterdata_pheno},'Cluster_',int2str(clusterIDs(id)),'.fcs'));
        fca_writefcs(fcsfilename,pheno_clusters{id},var_names);
        
        %Call to import fcs files as gates
        import_gatedarea( fcsfilename );
 
    end
    waitbar(1, phenoLoadWaitbar, 'Done!');
    close(phenoLoadWaitbar);
    disp('Phenograph clusters are stored as fcs files in custom_gates_0...');
 
else
    disp('Phenograph cluster names saved in session data')
end
 
end
 
