function [filename_ngate] = writefcs_neighbors(fileneighb,pathneighb,data_neighbrfile,max_varnames)
% WRITEFCS_NEIGHBORS: Write out fcs-file of the neighbors of a certain cell
% population to be imported later.
%
% Input:
% fileneighb --> user-defined file name with fcs ending
% pathneighb --> path to custom gates folder, which is where the fcs-file
% will be saved
% data_neighbrfile --> matrix of merged single-cell data of multiple gates
% max_varnames --> Channel names of selected gate with the largest amount
% of channels
%
% Output:
% filename_ngate --> full file path to fcs-file that has been written
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Switch off external GUI functions
zoom off;
pan off;
rotate3d off;
datacursormode off;

%Create fcs-file for neighbors gate
fcs_gatetable = array2table(data_neighbrfile,'VariableNames',max_varnames);
fca_writefcs(char(fullfile(pathneighb,fileneighb)),data_neighbrfile,fcs_gatetable.Properties.VariableNames,fcs_gatetable.Properties.VariableNames);

%Return path to fcs-file
filename_ngate = char(fullfile(pathneighb,fileneighb));

end

