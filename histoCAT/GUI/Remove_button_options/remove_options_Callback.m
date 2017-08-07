function remove_options_Callback(hObject, eventdata, handles)
% REMOVE_OPTIONS_CALLBACK: Executed when remove button is clicked. A selection of
% options will appear for remove possibilities (gates, channels, plots,...)
%
% hObject: handle to figure (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Disable external GUI functions
zoom off;
pan off;
rotate3d off;
datacursormode off;

%List of remove options
list = {'Clear gate selections','Gates','Channels','Gate coordinates','Clear plots','Clear All Tiff images'};

%Open list dialogue for user to choose option
[remove_elements,ok] = listdlg('PromptString','Remove/Clear options',...
    'SelectionMode','multiple',...
    'ListString',list,...
    'ListSize', [180 100]);

%If 'Clear gate selection' is selected, clear selection from samples
%listbox
if remove_elements == 1
    Scatter = 0;
    put('Scatter',Scatter);
    set(handles.list_samples,'Value',[]);
    
%If removes gates is selected, function call to remove the selected gates
elseif remove_elements == 2
    Remove_gates_Callback;
    
%If removes channels is selected, function call to remove selected channels
elseif remove_elements == 3
    Remove_channels_Callback;
    
%If removes gate coordinates is selected, function call to remove gated
%selection of cells
elseif remove_elements == 4
    clearall_gateselections;
    
%If remove plots is selected, remove all plots (right side of GUI)
elseif remove_elements == 5
    clear_plots;
    
%If remove Tiff images is selected, remove all tiff visualizations (left
%side of GUI)
elseif remove_elements == 6
    clear_tiffs;
    
else
    return;
end

end

