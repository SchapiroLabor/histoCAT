function SavePlot(hObject, eventdata, handles)
% SAVEPLOT: Opens currently displayed plot (right side of the GUI) in a new
% window and saves it to user defined folder
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve GUI variables
handles = gethand;
plots = handles.panel_plots;

%If there is no plot
if isempty(plots.Children) == 1
    msgbox('No plot found');
    return;
end

%Open figure
currentplot=figure;

%Copy the current plot to figure
copyobj(plots.Children,currentplot);

%Ask user for the folder to save it in
[filename,path]=uiputfile('*.jpeg','Save Plot');

%If no path found
if path==0
    return;
end

%Save the figure as jpeg
saveas(currentplot,fullfile(path,filename));

%Close the current figure
close(currentplot);

end

