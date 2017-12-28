function regressionline_checkbox_callback(hObject, eventdata, handles)
% REGRESSIONLINE_CHECKBOX_CALLBACK: Callback for checking and unchecking
% the regressionline checkbox. The scatterplot function is called to display the
% scatterplot with or without the regressionline when the box is checked or unchecked respectively.
%
% hObject: handle to scatter_plot (see GCBO)
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

%Get GUI handles
handles = gethand;

if handles.Regressionline.Value == 1
    %Call scatter plot with regressionline
    RegressionLine_ScatterPlot;
else handles.Regressionline.Value == 0
    %Call scatter plot without regressionline
    scatter_plot_Callback;
end
