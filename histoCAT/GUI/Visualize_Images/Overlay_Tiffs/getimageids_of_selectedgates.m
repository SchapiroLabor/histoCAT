function [  imageids, gate_names_pre, SGsof_imageids_open,sample_orderIDX ] = getimageids_of_selectedgates(Sample_Set_arranged,HashID,selected_gates, allids)
% GETIMAGEIDS_OF_SELECTEDGATES: Extract the imageids, gate names and
% indices of the selected gates.
%
% Input:
% Sample_Set_arranged --> all samples loaded into the current session (Even if 
% a sample was removed from the listbox, this will still retain the information 
% and will only be deleted when session is closed.)
% selected_gates --> current selection of gates by user
% allids --> the HashIDs of all samples (All imageIDs irrespective of whether 
% they contain single-cell information or not are saved into allids.)
% Output:
% imageids --> the HashIDs corresponding to the currently selected gates
% gate_names_pre --> all names of the samples corresponding to the imageids
% SGsof_imageids_open  --> the indices of the selected gates in the samples listbox
% sample_orderIDX --> the indices of the selected gates in the whole SampleSet (This index corresponds to the order in which all singlecell info,
% masks and tiffs are stored.)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH


%Initialize variables
count = 1;
SGsof_imageids_open = [];
imageid_entr = {};

%Get the ID for each selected gate from allids
for j= selected_gates
    imageid_entr{count} = unique([allids{j}],'stable');
    SGsof_imageids_open = [SGsof_imageids_open repmat(j,1,numel(imageid_entr{count}))];
    count = count+1;
end

%Store the unique imageids sequentially
imageids = unique([imageid_entr{:}],'stable');

%Convert the full hashes into decimals for comparison
alldhextodecHashes = cellfun(@(x) hex2dec(x),HashID,'UniformOutput',false);

%Compare the decimal hashes with the imageids list retrieved to see which sample name/hashID
%appears in it
[ax,idx_name] = ismember(imageids,[alldhextodecHashes{:}]); 

%Get the sample name corresponding to the imageids
[~,gate_names_pre] = cellfun(@fileparts,Sample_Set_arranged(idx_name),'UniformOutput',false);

%Store the selected gates' indices and the index of a match of imageids and
%hashID
SGsof_imageids_open = selected_gates;
sample_orderIDX = idx_name;

end

