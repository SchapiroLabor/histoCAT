function [ pheno_clusters ] = parse_Phenographclusters( sessionData,gates )
% PARSE_PHENOGRAPHCLUSTERS: This function is called after running Phenograph. 
% It will create fcs-files of all the Phenograph clusters and store them in 
% the custom gates folder. These Phenograph cluster fcs-files will then be 
% imported as individual gates and appear in the GUI. The single-cell
% Phenograph information was previously stored as an additional column in
% the sessionData.
%
% Input (not necessary when retrieved from GUI instead):
% sessionData --> the current session's single cell data in fcs-file format
% gates --> the current session's gates, also appearing in the list box of samples.
%
% Output:
% pheno_clusters --> All the single-cell cluster assignments are arranged
% in a cell array.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve GUI variables
selected_gates = get(handles.list_samples,'Value');
sessiondata_index = retr('sessiondata_index');
custom_gatesfolder = retr('custom_gatesfolder');
gates = retr('gates');
sessionData = retr('sessionData');

%Initialize variables
ClusterIDs_pre = [];
num_pheno = [];
pheno_clusters = {};

%Get the current Phenograph string index (column in sessionData) for the
%selected gates. It is the most recently added 'Phenograph' column if there are multiple.
found_string = cellfun(@(x) find(~cellfun('isempty',regexp(x,'Phenograph'))),gates(selected_gates(1),3),'UniformOutput',false);

%Get all the current variable names for all gates
allvarnames_gates = unique([gates{selected_gates,3}],'stable');

%Pre-allocate Cluster data matrix
ClusterData = zeros(numel([gates{selected_gates,2}]),numel(allvarnames_gates));

%Loop through the selected gates
for i = selected_gates
    
    %Get index of the current phenograph string for current gate (if
    %multiple Phenograph columns exist it is the most recently added one)
    pheno_idx = find(ismember(gates{i,3},gates{selected_gates(1),3}(found_string{1}(end))));
    
    %Get the vector of the cluster numbers corresponding to each cell of
    %the current gate
    ClusterIDs_pre  = [ClusterIDs_pre;sessionData(sessiondata_index{i}{1}(1):sessiondata_index{i}{1}(2),pheno_idx)];
    
    %Get the index of the current gate's variablenames in all variable
    %names(allvarnames of all gates)
    [~,cur_idx] = ismember(gates{i,3},allvarnames_gates);
    cur_idx = cur_idx(cur_idx ~= 0);
    cur = find(ismember(gates{i,3},allvarnames_gates));
    
    %Get the sessionData in the corresponding columns and store in
    %ClusterData
    ClusterData(sessiondata_index{i}{1}(1):sessiondata_index{i}{1}(2),cur_idx) = sessionData(sessiondata_index{i}{1}(1):sessiondata_index{i}{1}(2),cur);

end

%In case there are any, get rid of empty rows in ClusterData
ClusterData( all(~ClusterData,2), : ) = [];

%Get length of variable names of each selected gate and find the index of the selected gates with
%the maximum amount of variables (pick any of the selected gates with the maximum amount
%of variables is there are multiple with that same amount)
ends = cellfun(@length,gates([selected_gates],3));
end_max = max(ends);
max_idx = find(ends==end_max);
max_idx = max_idx(1);

%Get the variables names corresponding to the selected gate with the
%maximum amount of variables
gates_selected = gates(selected_gates,:);
var_names = gates_selected{max_idx,3};

%Get the amount of columns (variables) in the entire session
sess_max = size(sessionData,2);

%Exeption, deals with the case when additional (empty) colums were added to
%the end of ClusterData and cuts them off at the maximum amount of columns
%in the session
try
    ClusterData_final = ClusterData(:,1:sess_max);
catch
    ClusterData_final = ClusterData;
end

%Find phenograph column in var_names (variable names for ClusterData)
clusterdata_pheno = find(ismember(var_names,gates_selected{max_idx,3}(pheno_idx)));

%Get the unique cluster numbers and ignore zeros
clusterIDs = unique(ClusterIDs_pre(:,1));
clusterIDs = clusterIDs(clusterIDs ~= 0);

%Ask the user whether to load the clusters as gates and show them in the GUI
quest_pheno = questdlg('Do you want to load all the clusters?',...
    'Load Phenograph Clusters',...
    'Yes','No','Cancel','Cancel');

%If user requests cluster gates to be loaded
if strcmp(quest_pheno,'Yes') == 1
    
        %If the amount of clusters is greater than 50, ask user to select
        %up to 50 clusters to import
        if numel(clusterIDs) > 50
            disp('Too many Clusters to load..');
            
            %While the amount of clusters selected is still >50, keep asking to select up to 50
            while (isempty(num_pheno) == 1) || (numel(num_pheno) > 50)
                
                [num_pheno,~] = listdlg('PromptString','Select only upto 50 clusters to load..',...
                    'SelectionMode','multiple',...
                    'ListSize',[160,150],...
                    'ListString',clusterIDs);
                
                %Get the index of the clusters selected by user and store
                %corresponding clusterIDs
                clusterIDs = clusterIDs(num_pheno);
            end
        end

    %Initialize loading bar for the import of the Phenograph clusters
    phenoLoadWaitbar = waitbar(0,'Loading phenograph Clusters, Please wait..');
    
    %Loop through the clusterIDs
    for id=1:length(clusterIDs')
        
        %Find the indices of the current clusterIDs in the Phenograph column of ClusterData
        idx_id =  find(ismember(ClusterData_final(:,clusterdata_pheno),clusterIDs(id)));
        
        %Store the rows of ClusterData corresponding to the current cluster number
        pheno_clusters{id} = ClusterData_final(idx_id,:);
        
        %Update loading bar
        waitbar(id/length(clusterIDs'), phenoLoadWaitbar);
        
        %If additional, empty channels were added to the end of the matrix
        %at any point, cut the matrix columns down to the amount of
        %variable names
        if size(pheno_clusters{id},2) > length(var_names)
            pheno_clusters{id} = pheno_clusters{id}(:,1:length(var_names));
        end
        
        %Create a unique filename
        fcsfilename = fullfile(custom_gatesfolder,strcat(var_names{clusterdata_pheno},'Cluster_',int2str(clusterIDs(id)),'.fcs'));
        
        %Write fcs file
        fca_writefcs(fcsfilename,pheno_clusters{id},var_names);
        
        %Import current cluster as gate
        import_gatedarea( fcsfilename );

    end
    
    %Close loading bar when finished loading clusters
    waitbar(1, phenoLoadWaitbar, 'Done!');
    close(phenoLoadWaitbar);
    disp('Phenograph clusters are stored as fcs files in custom_gates_0...');

%If user did not want to load clusters
else
    disp('The Phenograph cluster IDs are saved in the session data')
end

end

