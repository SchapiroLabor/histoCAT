function [Fcs_Interest_all] = Process_SingleCell_Tiff_Mask(Tiff_all,Tiff_name,Mask_all,Fcs_Interest_all,HashID,expansionfeature,varargin)
% PROCESS_SINGLECELL_TIFF_MASK:
% This function stores the single cell information along with the expansion
% of pixels in mask mentioned by user and gets their neighbours. All
% masks/tiffs will be used to store these single cell information
% into the matrix of tables 'Fcs_Interest_all' of each ImageId/HashID processed.
%
% Input variables:
% Mask_all --> segmentation masks of all samples
% Tiff_all --> tiff matrices of all samples (images / channels)
% Tiff_name --> tiff names of all samples (image / channel names)
% HashID --> Unique folder IDs (!!!GLOBAL!!!)
% expansionfeature --> amount of pixels to expand from each cell in order
% to look for neighboring cells (set by user)
%
% Output variables;
% Fcs_Interest_all --> data in fcs format (first column: ImageID, second
% column: CellID, third column: marker1, etc.)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Call tiff names generating function
[ ~,tiff_matrix,cell_name ] = MasterTiffNames_Generation(Mask_all,Tiff_name,Tiff_all);

%If session was loaded for the first time, ask for the pixelexpansion to
%use in order to search for neighboring cells
if exist('expansionfeature','var') == 0
    prompt = {'Enter a single pixel expansion to use for calculation of number of neighbors:','Enter a single/range of pixelexpansions to detect neighbors (e.g for range 4:6)'};
    dlg_title = 'Pixel expansion';
    num_lines = 1;
    defaultans = {'4','4'};
    expansion = inputdlg(prompt,dlg_title,num_lines,defaultans);
    put('expansionfeature',expansion(1));
    put('expansion_range',str2num(cell2mat(expansion(2))));
end
%Else expansionfeature has already been set


%Initialize variables
length_neighbr = [];
sizes_neighbrs = [];
idx_cel = find(~cellfun('isempty',struct2cell(Mask_all)));
allvarnames_nospatial = unique([cell_name{idx_cel}],'stable');

%Add spatial features to variable names
BasicFeatures = {'Area', 'Eccentricity', 'Solidity', 'Extent', ...
    'EulerNumber', 'Perimeter',...
    'MajorAxisLength', 'MinorAxisLength', 'Orientation'};
%Add X and Y
XY = {'X_position','Y_position'};
allvarnames = [allvarnames_nospatial, BasicFeatures,XY];

% Ask user how to transform the data
option_list = {'Do not transform data','arcsinh','log'};
% Get response
transform_option = listdlg('ListString',option_list);
% Extract the string which was selected
transform_option_string = option_list(transform_option);

% If arcsinh selected, what co-factor should be used?
if strcmp(transform_option_string,'arcsinh')==1
    arcsinh_cofactor = inputdlg('Please specify a suitable cofactor (5 is often used).','arcsinh');
end

%Loop over all masks
masks = Mask_all;
for k=1:size(masks,2)
    
    %Store Image number or rowid
    rownum = k;
    
    %If there is a mask for the current image
    if isempty(masks(k).Image) ~= 1
        
        %If single cell info is not present already then store
        if (rownum <= size(Fcs_Interest_all,1) && isempty(Fcs_Interest_all{rownum,1}) == 1) || (rownum > size(Fcs_Interest_all,1))
            
            %Get current mask
            Current_Mask = masks(k).Image;
            
            %Get all the tiff data for each mask
            chandat = tiff_matrix{k};
            
            %Prepare to get the mean intensities of all channels
            get_mean = @(chan) struct2array(regionprops(Current_Mask, chandat{chan}, 'MeanIntensity'))';
            mean_tab = cell2mat(arrayfun(get_mean,1:length(chandat), 'UniformOutput',0));
            
            %Get spatial features similar to CellProfiler
            props_spatial = regionprops(Current_Mask, BasicFeatures(~strcmp(BasicFeatures,'FormFactor')));
            %Add X and Y coordinates to output
            props_spatial_XY = regionprops(Current_Mask, 'Centroid');
            
            %Transform single cell data as selected by user
            if strcmp(transform_option_string,'Do not transform data')==1
               Current_singlecellinfo_nospatial = mean_tab;
            elseif strcmp(transform_option_string,'arcsinh')==1
               Current_singlecellinfo_nospatial = asinh(mean_tab ./ arcsinh_cofactor{1});
            elseif strcmp(transform_option_string,'log')==1
               Current_singlecellinfo_nospatial = log(mean_tab);
            end
            
            %If RNA channels with spot detection masks are in the sample,
            %replace the mean with the amount of spots per cell
            spot_masks = retr('spot_masks');
            if ~isempty(spot_masks)
                idx_RNA = ~cellfun(@isempty, spot_masks(rownum,:));
                amount_RNAchannels = sum(idx_RNA);
                if amount_RNAchannels > 0
                    for rna = 1:amount_RNAchannels
                        spotMasks = spot_masks(rownum,idx_RNA);
                        currspotMask = spotMasks{rna};
                        get_spots = regionprops(Current_Mask, currspotMask, 'PixelValues');
                        spots_cell = struct2cell(get_spots);
                        unSpots = cellfun(@unique, spots_cell,'UniformOutput',false);
                        notzero = cellfun(@(x) x~=0, unSpots,'UniformOutput',false);
                        amount_spots = cellfun(@(x,y) length(x(y)), unSpots,notzero,'UniformOutput',false);
                        curridx = find(idx_RNA);
                        curridx = curridx(rna);
                        Current_singlecellinfo_nospatial(:,curridx) = cell2mat(amount_spots)';
                    end
                    
                    
                    %For the 'Abs_count' IMC channels, replace means with
                    %raw count
                    IMC_channels = ~cellfun(@isempty, strfind(allvarnames_nospatial,'Abs_counts'));
                    % If not present, skip this step
                    if any(IMC_channels)==1
                        % If IMC 'Abs_count' is present
                        IMC_chandat = chandat(IMC_channels);
                        get_count = @(chan) struct2cell(regionprops(Current_Mask,IMC_chandat{chan}, 'PixelValues'));
                        count_tab = arrayfun(get_count,1:length(IMC_chandat), 'UniformOutput',0)';
                        sum_tab = {};
                        for c=1:length(count_tab)
                            curr_count_tab = count_tab{c};
                            curr_sum = cellfun(@(x) sum(x), curr_count_tab);
                            sum_tab{c} = curr_sum';
                        end
                        Current_singlecellinfo_nospatial(:,IMC_channels) = cell2mat(sum_tab);
                    end
                end
            end
            
            %Add spatial information to data matrix: variable names and
            %data
            Current_channels_nospatial = cell_name{k};
            Current_channels = [Current_channels_nospatial, BasicFeatures,XY];
            
            BasicFeatures_Matrix = [cat(1,props_spatial.Area),...
                cat(1,props_spatial.Eccentricity),...
                cat(1,props_spatial.Solidity),...
                cat(1,props_spatial.Extent),...
                cat(1,props_spatial.EulerNumber),...
                cat(1,props_spatial.Perimeter),...
                cat(1,props_spatial.MajorAxisLength),...
                cat(1,props_spatial.MinorAxisLength),...
                cat(1,props_spatial.Orientation),...
                cat(1,props_spatial_XY.Centroid)];
            
            Current_singlecellinfo= [Current_singlecellinfo_nospatial, BasicFeatures_Matrix];
            
            %Function call to expand cells and get the neighbrcellIds
            [ Fcs_Interest_all,length_neighbr,sizes_neighbrs ] = NeighbrCells_histoCATsinglecells( rownum,allvarnames,expansion,Current_channels,Current_Mask,Current_singlecellinfo,...
                Fcs_Interest_all,length_neighbr,sizes_neighbrs,HashID,k );
            
            %If single cell information is already present for image
        else
            disp(['Single Cell Information  is already present for ImageId ',int2str(rownum)]);
            neighb_index = find(~(cellfun('isempty',strfind(Fcs_Interest_all{rownum,1}.Properties.VariableNames,'neig'))));
            length_neighbr(rownum) = size(Fcs_Interest_all{rownum,1},1);
            sizes_neighbrs(rownum) = length(neighb_index);
            continue;
        end
        
        %If there is no mask no single cell information can be extracted
    else
        Fcs_Interest_all{rownum,1} = [];
    end
    
end

end
