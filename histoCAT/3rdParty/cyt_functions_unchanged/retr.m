function var = retr(name)
% RETR returns saved variable or empty matrix if the variable is not found
%
% This function is from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Input: name --> name for gui app data variable
%
% Output: var --> variable selected
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

    selectgui=getappdata(0,'histoCATgui');  
    var=getappdata(selectgui, name);
end
