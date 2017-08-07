function handles=gethand
% GETHAND Get handles from GUI
%
% This function is from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

    selectgui=getappdata(0,'histoCATgui');
    handles=guihandles(selectgui);
end