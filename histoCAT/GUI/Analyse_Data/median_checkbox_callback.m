function median_checkbox_callback(hObject, eventdata, handles)
% MEDIAN_CHECKBOX_CALLBACK: Callback for checking and unchecking the median
% checkbox. The heatmap_of_selected function is called to display the
% heatmap with the new settings everytime the box is checked/unchecked.
%
% hObject: handle to scatter_plot (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH


%Switch off external gui tools
zoom off;
pan off;
rotate3d off;
datacursormode off;

%Get GUI handles
handles = gethand;

if handles.median.Value == 1
    %Call heatmap function
    heatmap_of_selected;
else handles.median.Value == 0
    %Call heatmap function
    heatmap_of_selected;
end

