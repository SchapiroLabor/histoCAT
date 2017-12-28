function [Sample_Set_arranged,Mask_all,Tiff_all,Tiff_name] = Load_MatrixDB(samplefolders,Sample_Set_arranged,Mask_all)
% LOAD_MATRIXDB: Main function for loading tiffs and mask data
%
% Input variable:
% samplefolders --> paths to the selected sample folders
% Sample_Set_arranged --> paths to all sample folders in session (historical)
% Mask_all --> segmentation masks of all samples (matrices)
%
% Output variables:
% Sample_Set_arranged --> paths to all sample folders in session (historical)
% Mask_all --> segmentation masks of all samples (matrices)
% Tiff_all --> tiff matrices of all samples (images / channels)
% Tiff_name --> tiff names of all samples (image / channel names)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%If not stored before, add the sample folders to Sample_Set_arranged
[Sample_Set_arranged]= unique([Sample_Set_arranged samplefolders],'stable');

%Display update
disp('Samples arranged..Loading Masks,Tiffs of all Samples..');
hWaitbar = waitbar(0,'Loading all files from Database. This may take a while...');

%Loop through all the samples in DB
for i=1:size(Sample_Set_arranged,2)
    
    %Load all mask from the TMA
    [Mask_all] = Load_mask(Sample_Set_arranged,Mask_all,i);
    
    %Load all tiff files and names for each image
    [Tiff_all,Tiff_name] = Load_tiff(Sample_Set_arranged,i);
    
    %Update waitbar
    waitbar(i/size(Sample_Set_arranged,2), hWaitbar);
end

close(hWaitbar);

end

