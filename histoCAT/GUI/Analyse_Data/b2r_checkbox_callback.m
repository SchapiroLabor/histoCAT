function b2r_checkbox_callback(hObject, eventdata, handles)
% B2R_CHECKBOX_CALLBACK: Callback for checking and unchecking
% the b2r checkbox. The heatmap function is called to display the
% heatmap with or without the b2r settings when the box is checked or unchecked respectively.
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

%Retrieve GUI handles
handles = gethand;

%Call heatmap function everythime the checkbox is changed
if handles.b2r.Value == 1
    heatmap_of_selected;
else handles.b2r.Value == 0
    heatmap_of_selected;

end