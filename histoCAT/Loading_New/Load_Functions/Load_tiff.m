function [Tiff_all,Tiff_name] = Load_tiff(Sample_Set_arranged,i)
% LOAD_TIFF: Load all tiffs for each image. This function checks in the path if there are any tiffs. If found, it
% reads them into matrices. If not, it is stored as empty.
%
% Input variables:
% Sample_Set_arranged --> paths all sample folders in session (historical)
% i --> loop variable for Sample_Set_arranged folder number
%
% Output variables:
% Tiff_all --> cell storing all tiff files (as matrices) for each sample
% Tiff_name --> contains all the tiff names to later load as channel names
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI variables
Tiff_all = retr('Tiff_all');
Tiff_name = retr('Tiff_name');

%If sample present in list
if cellfun(@isempty,Sample_Set_arranged(i)) == 0
    
    %Get all the files in the sample folder
    fileList = getAllFiles(char(Sample_Set_arranged(i)));
    
    %Extract tiffs (besides the one representing a mask)
    tiff_position = find(~cellfun('isempty',regexp(fileList,'(?<!mask)\.tif*')))';
    
    %Read all tiffs
    allimagesread = cellfun(@imread,fileList(tiff_position),'UniformOutput',false)';
    
    %%Dont include those tiffs that are not 2D
    idx_include = find(cellfun(@numel,cellfun(@size,allimagesread,'UniformOutput',false)) == 2);
    allimagesread_fin = allimagesread(idx_include);
    
    %Store their names
    alltiffnames = cellfun(@(xy) strsplit(xy,fullfile('/')) , fileList(tiff_position),'uni',0);
    
    %preallocating for faster loop
    if isempty(Tiff_all) == 1
        Tiff_all  = cell(size(Sample_Set_arranged,2),length(idx_include));
        Tiff_name = cell(size(Sample_Set_arranged,2),length(idx_include));
    end
    
    Tiff_all(i,idx_include) = allimagesread_fin;
    Tiff_split_name = cellfun(@(x) x(end),alltiffnames(idx_include)','UniformOutput',false);
    Tiff_name(i,idx_include) = Tiff_split_name;    
end

%Update GUI variables
put('Tiff_all',Tiff_all);
put('Tiff_name',Tiff_name);

end



