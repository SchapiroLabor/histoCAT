function Savetiff_fig(hObject, eventdata, handles)
% SAVETIFF_FIG: Opens currently displayed tiff image (left side of the GUI) in a new
% window and saves it to user defined folder
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve Variables of displayed image
tabmaster_histonetiff = retr('tabmaster_histonetiff');

%If there is no image displayed
if isempty(tabmaster_histonetiff) == 1
    msgbox('No figure found');
    return;
end

%Open new figure
currentfig=figure;

%Get only the image in the currently selected tab
tab = tabmaster_histonetiff.SelectedTab;

%Copy the tiff image to the figure
copyobj(tab.Children,currentfig);

%Ask user for the folder to save it in
[filename,path]=uiputfile('*.jpeg','Save Tiff');

%If no path found
if path==0
    return;
end

%Save the figure as jpeg
saveas(currentfig,fullfile(path,filename));

%Close the current figure
close(currentfig);

end

