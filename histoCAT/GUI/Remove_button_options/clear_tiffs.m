function clear_tiffs
% CLEAR_PLOTS: Clears all current tiff-images from the left side of the GUI
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve tabs
tabmaster_histonetiff = retr('tabmaster_histonetiff');

%If there are tabs open delete them
if isempty(tabmaster_histonetiff) ~= 1
     handles.panel_tiff_images.Children.delete;
else
    return;
end

end

