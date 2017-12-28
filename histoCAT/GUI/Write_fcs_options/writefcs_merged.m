function [filename_merged] = writefcs_merged(filemerged,pathmerged,merged_data)
% WRITEFCS_MERGED: Write out fcs-file after merging multiple gates into
% one.
%
% Input:
% filemerged --> user-defined file name with fcs ending
% pathmerged --> path to custom gates folder, which is where the fcs-file
% will be saved
% merged_data --> matrix of merged single-cell data of multiple gates
%
% Output:
% filename_merged --> full file path to fcs-file that has been written
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Switch off external GUI functions
zoom off;
pan off;

%Retrieve variables
variablesmax = retr('variablesmax');

%Put merged data with variable names into table
fcs_gatetable = array2table(merged_data,'VariableNames',variablesmax);
%Write fcs-file
fca_writefcs(char(fullfile(pathmerged,filemerged)),merged_data,fcs_gatetable.Properties.VariableNames,fcs_gatetable.Properties.VariableNames);

%Return the path to the fcs-file
filename_merged = char(fullfile(pathmerged,filemerged));

end

