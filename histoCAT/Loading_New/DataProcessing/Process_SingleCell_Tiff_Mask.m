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
if exist('expansionfeature') == 0
    expansioninput = inputdlg('Please specify the number of pixels(eg:between 1 to 6) you want to expand per cell the search area for finding neighbors','Storing neighboring cell information',1,{'4'});
    expansionfeature = str2double(expansioninput{1});
    put('expansionfeature',expansionfeature);
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
allvarnames = [allvarnames_nospatial, BasicFeatures];

%Ask user whether to use arcsinh transform or not
arcsinh_boolean = inputdlg('Do you want to arcsinh tranform the data? If yes, please specify a suitable cofactor (5 is often used).','arcsinh',1,{'Do not transform data'});
if strcmp(char(arcsinh_boolean),'Do not transform data')
    arcsinh_boolean = [];
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
            
            %Transform single cell data by arcsinh if selected by user
            if isempty(arcsinh_boolean)
                Current_singlecellinfo_nospatial = mean_tab;
            else
                Current_singlecellinfo_nospatial = asinh(mean_tab ./ arcsinh_boolean{1});
            end
            
            %Add spatial information to data matrix: variable names and
            %data
            Current_channels_nospatial = cell_name{k};
            Current_channels = [Current_channels_nospatial, BasicFeatures];

            BasicFeatures_Matrix = [cat(1,props_spatial.Area),...
                cat(1,props_spatial.Eccentricity),...
                cat(1,props_spatial.Solidity),...
                cat(1,props_spatial.Extent),...
                cat(1,props_spatial.EulerNumber),...
                cat(1,props_spatial.Perimeter),...
                cat(1,props_spatial.MajorAxisLength),...
                cat(1,props_spatial.MinorAxisLength),...
                cat(1,props_spatial.Orientation)]; 
            Current_singlecellinfo= [Current_singlecellinfo_nospatial, BasicFeatures_Matrix];
              
            %Function call to expand cells and get the neighbrcellIds
            [ Fcs_Interest_all,length_neighbr,sizes_neighbrs ] = NeighbrCells_histoCATsinglecells( rownum,allvarnames,expansionfeature,Current_channels,Current_Mask,Current_singlecellinfo,...
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
