function list_channels_Callback(hObject, eventdata, handles)
% LIST_CHANNELS_CALLBACK: Callback for channel box. Executes on selection 
% change in list_channels.
%
% hObject: handle to listbox1 (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns contents
% contents{get(hObject,'Value')} returns selected item from listbox1
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH


%Get GUI handles
handles = gethand;

%Function call to callback of samples box
list_samples_Callback;

%Pass control back to GUI
uicontrol(handles.list_channels);

end

