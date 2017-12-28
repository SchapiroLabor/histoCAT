function [Fcs_Interest_all] = DataProcessing_Master(Mask_all,Tiff_all,Tiff_name,HashID,Fcs_Interest_all,expansionpixels,varargin)
% DATAPROCESSING_MASTER: Main function for processing the data
% This function processes all tiff files using the mask
% to extract single cell information for each channel. Additionally, we
% can expand the cell to get the extracellular information
% ('Nano'-Environment) and their neighbors.
%
% Input variables:
% Mask_all --> segmentation masks of all samples
% Tiff_all --> tiff matrices of all samples (images / channels)
% Tiff_name --> tiff names of all samples (image / channel names)
% HashID --> Unique folder IDs (!!!GLOBAL!!!)
% fcs_Boolean --> 1 creates fcs files, 0 no fcs files are generated
%
% Output variables;
% Fcs_Interest_all --> data in fcs format (first column: ImageID, second
% column: CellID, third column: marker1, etc.)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

% Get all single cell information from a TIFF file using the mask

% If a pixelexpansion has already been set by the user, pass it to the function and don't ask again
% (This can be used for UnitTest)
if exist('expansionpixels') == 1
    [Fcs_Interest_all] = Process_SingleCell_Tiff_Mask(Tiff_all,Tiff_name,Mask_all,Fcs_Interest_all,HashID,expansionpixels);
else
    [Fcs_Interest_all] = Process_SingleCell_Tiff_Mask(Tiff_all,Tiff_name,Mask_all,Fcs_Interest_all,HashID);
end

end

