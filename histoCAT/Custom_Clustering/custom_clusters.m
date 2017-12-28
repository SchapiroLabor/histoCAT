function custom_clusters(hObject, eventdata, handles)
% CUSTOM_CLUSTERS: Generates custom clustering based on selected
% gates. This function will assign the selected subsets of cells to
% individual clusters and fill up the rest of the not yet assigned cell's cluster
% membership with previously made PhenoGraph clusters. This allows the user
% to combine manual gating with unsupervised clustering.
%
% hObject: handle to preparesample_button (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH
 
%Get GUI handles
handles = gethand;
 
%Retrieve variables
sessionData = retr('sessionData');
selected_gates = get(handles.list_samples,'Value');
gates = retr('gates');
 
%Get phenograph column of the original images containing the cells in the custom gates
orig_images = sessionData([gates{selected_gates,2}],1);
un_orig_images = unique(orig_images,'stable');
all_un_images = unique(sessionData(:,1),'stable');
index_images = ismember(all_un_images,un_orig_images);
Pheno_column = cellfun(@(x) find(strncmp('Phenograph',x,10)), gates(index_images,3),'UniformOutput',false);

%In case multiple phenographs have been run, ask user which to use
[max_size, max_index] = max(cellfun('size', Pheno_column, 2));
Phenograph_index_selected = {};
if max_size>1
    [selected,~] = listdlg('PromptString','Select Phenograph to use',...
        'SelectionMode','single',...
        'ListSize',[160,150],...
        'ListString',gates{max_index,3}(Pheno_column{1,1}));
    put('selected',selected);
    for i = 1:size(Pheno_column,1)
        Phenograph_index_selected{i,1} = Pheno_column{i,1}(selected);
    end
else
    Phenograph_index_selected = Pheno_column;
end

%If no phenograph has been run yet, tell user to run it first
if isempty(Phenograph_index_selected)
    msgbox('Please run Phenograph on the Images first, so the cells not contained in a custom gate can be assigned.')
    return;
end
column = unique([Phenograph_index_selected{:}]);
pheno_clusters = sessionData(:,column);
 
 
%Replace in pheno_clusters the cells of the selected gates with a separate
%cluster number (to distinguish these numbers are in steps of hundreds:
%100,200...)

%Fill up clustering vector with zeros if not same length as whole session
if size(pheno_clusters,1) < size(sessionData,1)
    add = zeros(size(sessionData,1)-size(pheno_clusters,1),1);
    pheno_clusters = [pheno_clusters; add];
end
 
%Assign random name to custom clustering
newClustering_name = int2str(randi(10000000000));
new_channel_name = {sprintf('customClusters%s',newClustering_name)};
 
%Update new clustering column to sessionData and gates
sessionData = [sessionData pheno_clusters];
gates(:,3) = cellfun( @(x) [x new_channel_name],gates(:,3),'UniformOutput',false);
 
%Find the phenograph gates and the corresponding rows in the sessionData to
%set to zero in the costum clustering column
indexPhenoGates = find(cellfun(@(x) strncmp(x,'Phenograph',10),gates(:,1)));
firstPheno = indexPhenoGates(1);
lastPheno = indexPhenoGates(end);
sessionData((gates{firstPheno,2}(1)-1):(gates{lastPheno,2}(1)-1),end) = 0;
 
%Each selected gate is one cluster, assign numbers 100,200,... to
%distinguish them from the phenograph clusters
cell_store =[];
for i=1:length(selected_gates)
    rows = gates{selected_gates(i),2};
    sessionData(rows,size(sessionData,2)) = i*100;
    
    %Find corresponding cells in original images
    correspCells = find(ismember(sessionData(:,1:2),sessionData(rows,1:2),'rows'));%[orig_images cellID]
    sessionData(correspCells,size(sessionData,2)) = i*100;
    cell_store = [cell_store; correspCells];
end
 
%If cells are in more than one custom gate, the last one will overwrite the
%previous ones, the user should try to manually gate without overlap
doubles = length(cell_store)- length(unique(cell_store));
if ~ doubles == 0 
    msgbox('Warning: Certain cells are in more than one selected gate. They can only be assigned to one cluster and thus will be assigned to the cluster of last selected gate, in which they appear.');
end
 
%Update GUI variables
put('gates',gates);
put('sessionData',sessionData);
 
%Update listboxes
list_samples_Callback;
 
%Call to import the clusters as individual gates
parse_customclusters;
 
end
