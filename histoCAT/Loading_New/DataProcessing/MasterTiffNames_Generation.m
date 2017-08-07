function [ tiff_assigned,tiff_matrix,cell_name ] = MasterTiffNames_Generation(Mask_all,Tiff_name,Tiff_all)
% This function gets the names of all the tiffs loaded, and makes a unique
% list out of it. This list will be maintained, and new tiffs when
% encountered will be just concatenated to the list. This method avoids
% dependencies on assigning standard library names and only considers the
% way the user has named the tiffs. If the names of the tiffs are exactly
% the same, they will be listed in the same index.
%
% Input variables: 
% Mask_all --> segmentation masks of all samples
% Tiff_name --> names of all tiffs. Samples are row-wise
% Tiff_all  --> matrix of all tiffs. Samples are row-wise
%
% Output variables:
% For every sample tiff_assigned,tiff_matrix,cell_name are
% stored depending on the tiffs found for each of them.
% tiff_assigned --> name of the tiffs for each sample (without empty columns)
% tiff_matrix --> matrix of the tiffs for each sample (without empty columns)
% cell_name --> Names of the tiffs concatenated with 'Cell_' representing
% it as a cell mask's tiff intensity.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Initialize
cell_name = {};
tiff_assigned = {};
tiff_matrix = {};

%Get only those samples which have been segmented
idx_seg = find(~cellfun('isempty',struct2cell(Mask_all)));
if isempty(idx_seg) == 1
    all_tiffnames = unique([Tiff_name{:,:}],'stable');
else
    %Get all tiff names of the loaded samples
    all_tiffnames = unique([Tiff_name{idx_seg,:}],'stable');
end

%Store only the name without extension
split_tiffnms = cellfun(@(x) strsplit(x,'.'),all_tiffnames,'UniformOutput',false);
onlynamesall  = cellfun(@(endspl) endspl(1),split_tiffnms);

%Check length >40
maxlengthidx = find(cellfun(@length,onlynamesall) > 40);
onlynamesall(maxlengthidx) = cellfun(@(x) x(1:40),onlynamesall(maxlengthidx),'UniformOutput',false);

%For each row of Tiffname
for fnum=1:size(Tiff_name,1)
    
    if isempty([Tiff_name{fnum,:}]) ~= 1
        
        %Get the current sample's tiffs
        currenttiffs = [Tiff_name{fnum,:}];
        
        if ~ismember(fnum,idx_seg) == 1
            %Store the tiffs
            tiff_assigned{fnum,1} = currenttiffs;
            %Store the cell names
            cell_name{fnum,1}     = currenttiffs;
        else
            %Get the idx of those columns that are not empty
            ntempty = find(~cellfun('isempty',Tiff_name(fnum,:)));
            
            %Store only the name without extension
            split_curr = cellfun(@(x) strsplit(x,'.'),currenttiffs,'UniformOutput',false);
            curr_names = cellfun(@(endspl) endspl(1),split_curr);
            cur40 = find(cellfun(@length,curr_names) > 40);
            curr_names(cur40) = cellfun(@(x) x(1:40),curr_names(cur40),'UniformOutput',false);
            
            %Check which of the current ones are a member of the big list of tiffs
            [~,idx_all]  = ismember(curr_names,onlynamesall(:));%%(Returns index of onlynamesall)
            idx_all(idx_all == 0) = [];
            
            %Get the index of the current
            idx_curr = find(ismember(curr_names,onlynamesall(:)));
            
            %Store the tiffs
            tiff_assigned{fnum,1}(idx_curr) = currenttiffs(idx_curr);
            
            %Get the index of current tiff_name variable
            tiffchanidx = find(ismember([Tiff_name{fnum,ntempty}],[tiff_assigned{fnum}(idx_curr)]));
            
            %Store the respective Tiff all matrix
            curnam = [Tiff_all(fnum,ntempty)];
            tiff_matrix{fnum,1}(idx_curr)   = curnam(tiffchanidx); 
            name_assigned{fnum}(idx_curr) = onlynamesall(idx_all);
            
            %Store the cell names
            cell_name{fnum,1}(idx_curr)     = strcat('Cell_',name_assigned{fnum}(idx_curr));
        end
    end
end

end