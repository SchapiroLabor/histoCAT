function clear_plots
% CLEAR_PLOTS: Clears all current plots on the right side of the GUI
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%If there is a plot, delete it
if isempty(handles.panel_plots.Children) ~= 1
    delete(handles.panel_plots.Children)   
else
    uiwait(msgbox('Nothing to clear'));    
end

end

