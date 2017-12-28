function [Tiff_all,Tiff_name] = spot_detection_master(Tiff_name,Tiff_all)
% SPOT_DETECTION_MASTER: Detects RNA channel(s) and calls spot detection for
% each.
%
% Input:
% Tiff_all --> tiff matrices of all samples (images / channels)
% Tiff_name --> tiff names of all samples (image / channel names)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Only go into spot detection when RNA channel present
RNAstr_logic_asses = cellfun(@(x) strfind(x,'RNA'),Tiff_name,'UniformOutput',false);
try
    if sum(~cellfun(@(x) isempty(x{1}),RNAstr_logic_asses)) < 1
        return
    end
catch
    return
end

%Duplicate IMC channels to have a separate channel for means and counts,
%the counts are necessary for correlations with the spot detection counts

%Loop through samples
for i=1:size(Tiff_name,1)

    %Get the channel names containing 'IMC'
    IMC_channels = ~cellfun(@isempty, strfind([Tiff_name{i,:}],'IMC'));
    
    %Allocate space for duplicated channels and mark IMC channel positions
    IMC_channels_dup = [IMC_channels, zeros(1,sum(IMC_channels))];
    found_imc_orig = find(IMC_channels);
    count = 0;
    for imc = 1:length(found_imc_orig)
        curr_found = found_imc_orig(imc)+count;
        IMC_channels_dup (curr_found) =1;
        if IMC_channels_dup (curr_found+1) == 0
            IMC_channels_dup (curr_found+1) =1;
        elseif IMC_channels_dup (curr_found+2) == 0
            count=count+1;
        else
            all_ones_inarow = find(IMC_channels_dup((curr_found+1):end));
            if isempty(setdiff(all_ones_inarow,1:length(all_ones_inarow)))
                count=count+length(all_ones_inarow);
            else
                first_zero = setdiff(all_ones_inarow,1:length(all_ones_inarow));
                count=count+(first_zero-1);
            end
        end
    end
    
    %Save original non-IMC channels
    save_orig_names = Tiff_name(i,~IMC_channels);
    save_orig_all = Tiff_all(i,~IMC_channels);
    
    %Generate the new names containing 'Abs_count_' for the additional IMC
    %channels and fill corresponding positions with the new channels
    new_names = cellfun(@(x) strcat('Abs_counts_',x),Tiff_name(i,IMC_channels));
    found_imc = find(IMC_channels_dup);
    new_Tiff_names = {};
    new_Tiff_all = {};
    counter = 1;
    for n=1:length(new_names)
        curr_idx = found_imc(n);
        if n==1
            new_Tiff_names(curr_idx) = Tiff_name(i,curr_idx);
            new_Tiff_all(curr_idx) = Tiff_all(i,curr_idx);
            new_Tiff_names(curr_idx+1) = {new_names(n)};
            new_Tiff_all(curr_idx+1) = Tiff_all(i,curr_idx);
        else
            curr_idx_plus = found_imc(n+counter);
            new_Tiff_names(curr_idx_plus) = Tiff_name(i,found_imc_orig(n));
            new_Tiff_all(curr_idx_plus) = Tiff_all(i,found_imc_orig(n));
            new_Tiff_names(curr_idx_plus+1) = {new_names(n)};
            new_Tiff_all(curr_idx_plus+1) = Tiff_all(i,found_imc_orig(n));
            counter = counter +1;
        end
    end
    
    %Add the original non-IMC channels to the remaining positions
    new_Tiff_names(~IMC_channels_dup) = save_orig_names;
    new_Tiff_all(~IMC_channels_dup) = save_orig_all;
    Tiff_name_temp(i,:) = new_Tiff_names;
    Tiff_all_temp(i,:) = new_Tiff_all;
end

%Replace the old Tiff storage variables with the new ones
Tiff_name = Tiff_name_temp;
Tiff_all = Tiff_all_temp;

%Find "RNA" in channel names
RNAstr_logic = cellfun(@(x) strfind(x,'RNA'),Tiff_name,'UniformOutput',false);

%Get matrices of corresponding images
for m=1:size(RNAstr_logic,1)
    for l =1:size(RNAstr_logic,2)
        RNAstr_logic_mat{m,l} = cell2mat(RNAstr_logic{m,l});
    end
end

%Get the channels that aren't empty
notEmptyChannels = ~cellfun(@isempty,RNAstr_logic_mat);
[row,col] = ind2sub(size(RNAstr_logic_mat),find(notEmptyChannels));
spot_masks = {};

%If RNA channels were detected, run spot detection on each
for i=1:(max(length(row), length(col)))
    RNAname = Tiff_name{row(i),col(i)};
    [spots_mask, spots_tiff] = IdentifySpots2D(Tiff_all(row(i),col(i)),RNAname);
    spots_tiff = {uint16(spots_tiff{1})};
    spots_tiff{1} = spots_tiff{1}*65280;
    spot_masks(row(i),length(RNAstr_logic)+1) = spots_mask;
    Tiff_all(row(i),length(RNAstr_logic)+1) = spots_tiff;
    Tiff_name(row(i),length(RNAstr_logic)+1) = cellstr(strcat('Spots_',char(Tiff_name{row(i),col(i)})));
    put('Tiff_all', Tiff_all);
    put('Tiff_name',Tiff_name);
end

%Store spot masks
put('spot_masks',spot_masks);

end