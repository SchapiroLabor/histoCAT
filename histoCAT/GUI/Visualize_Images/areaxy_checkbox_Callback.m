function areaxy_checkbox_Callback(hObject, eventdata, handles)
% AREAXY_CHECKBOX_CALLBACK: This function is executed when the areaxy on/off 
% checkbox is checked or unchecked. Checking the box displayes the
% centroids of the individual cells on the current image tab.
%
% hObject: handle to figure
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Switch off external GUI tools
zoom off;
pan off;
rotate3d off;
datacursormode off;

%Retrieve GUI handles/variables
tabmaster_histonetiff = retr('tabmaster_histonetiff');
handles = gethand;

%If the user unchecks the checkbox
if handles.areaxy_onoff.Value == 0
    
    %Get the previously stored line type with the tag 'Areaplot' 
    %(it was stored in the the plotAreaXY function)
    foundline = tabmaster_histonetiff.SelectedTab.Children.findobj('type','axes').findobj('Tag','Areaplot');
    
    %If the line type was found, switch its visibility off
    if isempty(foundline) ~= 1
        set(foundline,'Visible','off');
        
    %If the line type was not found, there is no segmentation/ single-cell information
    else
        disp('No single-cell information was found');
    end
    
%If the ckeckbox is checked 
else
    
    %Get the previously stored line type with the tag 'Areaplot' 
    %(it was stored in the plotAreaXY function)
    foundline = tabmaster_histonetiff.SelectedTab.Children.findobj('type','axes').findobj('Tag','Areaplot');
    
    %If the line type was found, switch its visibility on
    if isempty(foundline) ~= 1
        set(foundline,'Visible','on');
        
    %If the line type was not found, there is no segmentation/ single-cell information
    else
        disp('No single-cell information was found');
    end
      
end

end

