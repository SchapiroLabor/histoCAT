function Savetiff_fig(hObject, eventdata, handles)
% SAVETIFF_FIG: Opens currently displayed tiff image (left side of the GUI) in a new
% window and saves it to user defined folder
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Retrieve Variables of displayed images
tabmaster_histonetiff = retr('tabmaster_histonetiff');
all_tabs = get(tabmaster_histonetiff.Children.findobj('type','axes'));

%If there is no image displayed, return
if isempty(tabmaster_histonetiff) == 1
    msgbox('No figure found');
    return;
end

if length(all_tabs) > 1
    %Ask user about batch saving
    batch = questdlg('Save current image or save all tabs?','Batch save?','Current image','All tabs','Current image');
else
    batch = 'Current image';
end
    
%If the user only wants to save the current image
if strcmp(batch,'Current image')

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
    
%If the user selects to save all curently opened image tabs
else
    
    %Loop through open tabs
    for i=1:size(all_tabs,1)

        %Open new figure
        currentfig=figure;
        
        %Get only the image in the current tab of iteration
        tab = get(all_tabs(i,:).Parent);
        
        %Copy the tiff image to the figure
        copyobj(tab.Children,currentfig);

        if ~exist('filename','var')  
            %Ask user for the folder to save it in
            [filename,path]=uiputfile('*.jpeg','Save Tiff');
        end

        %If no path found
        if path==0
            return;
        end

        %Save the figure as jpeg
        saveas(currentfig,fullfile(path,strcat(tab.Title,'_',filename)));

        %Close the current figure
        close(currentfig);
    end
end


end

