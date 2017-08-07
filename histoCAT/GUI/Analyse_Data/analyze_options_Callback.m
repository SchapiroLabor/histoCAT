function analyze_options_Callback(hObject, eventdata, handles)
% ANALYZE_OPTIONS_CALLBACK: Executes on any change in the analyze options
% drop down menu.
%
% hObject: handle to scatter_plot (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH


%Disable all other toolbar options
zoom off;
pan off;
rotate3d off;
datacursormode off;

%Get GUI handles
handles = gethand;

%Set gating variable to zero
gatedontiff = 0;
put('gatedontiff',gatedontiff);

%If RGB is selected on visualization side, reset the option since channels would otherwise be RGB in list_channels
if strcmp(handles.visualize_options.String{handles.visualize_options.Value},'Apply RGBCMY on selected samples') == 1
    set(handles.visualize_options,'Value',1);
end

%If scatter plot option is selected
if strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Scatter') == 1
    %Make the checkbox for the regression line visible
    set(handles.Regressionline,'Visible','on');
else
    %Hide checkbox otherwise
    set(handles.Regressionline,'Visible','off');
end

%If heatmap option is selected
if strcmp(handles.analyze_options.String{handles.analyze_options.Value},'Heatmap') == 1
    %make the checkbox for the b2r appear
    set(handles.b2r,'Visible','on');
    %make the checkbox for the median appear
    set(handles.median,'Visible','on');
else
    %Hide checkboxes otherwise
    set(handles.b2r,'Visible','off');
    set(handles.median,'Visible','off');
end

%Updates the heatmap channels;
list_samples_Callback;

end

