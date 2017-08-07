function put(name, what)
% PUT Updates GUI data
%
% This function is from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Input:
% name --> name for gui app data variable
% what --> data
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

    selectgui=getappdata(0,'histoCATgui');
    setappdata(selectgui, name, what);
    
    listener = retr([name '_listener']);
    if ~isempty(listener)
        listener();
    end
end