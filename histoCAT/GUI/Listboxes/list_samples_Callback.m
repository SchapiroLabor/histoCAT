function list_samples_Callback(hObject, eventdata, handles)
% LIST_SAMPLES_CALLBACK: Executes on selection change in list_samples.
%
% hObject: handle to lstGates (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns contents
% contents{get(hObject,'Value')} returns selected item from listbox1
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve variables
gates = retr('gates');
allids = retr('allids');
global HashID;
global Sample_Set_arranged;
selected_gates = get(handles.list_samples,'Value');

%If there are no gates in session, return
if (size(gates, 1) == 0)
    return;
end

%If no gate is selected, then the context is all the data available in the session.
if isempty(selected_gates)
    selected_gates = 1:size(gates, 1);
end

%Store gate indices (in sessionData matrix) and channel names of the selected gates
[gate_indices, channel_names] = getSelectedIndices(selected_gates, gates);

%Preserve selection
selected_channels = get(handles.list_channels, 'Value');
selected_channels(selected_channels > numel(channel_names)) = [];
set(handles.list_channels, 'Value', selected_channels);

%Set list_channels to channels names in selected gates
set(handles.list_channels, 'String', channel_names);

%Set the heatmap listbox to channel names in selected gates
set(handles.list_heatmap,'String',['None' channel_names]);
set(handles.list_heatmap,'Min',1,'Max',100);
set(handles.list_heatmap,'Value',1);

%If user wants to visualize single channel or RGBCMY
if strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Highlight sample on Tiff images') == 1 || strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Apply RGBCMY on selected samples') == 1 || strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Heatmap channel on selected samples') == 1 || strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Highlight excluding selected sample') == 1
    
    %Check which selected gates came from more than just one imageID
    foundlengthgrt = find(cellfun('length',allids([selected_gates])) > 1);
    
    %If they are from more than one image, display the original image names
    %in list subsamples box
    if isempty(foundlengthgrt) ~= 1
        
        %Get their gate names
        allids = retr('allids');
        [  ~, gate_names_pre, ~,~ ] = getimageids_of_selectedgates(Sample_Set_arranged,HashID,selected_gates,allids);

        %Allow only upto 10 selections
        set(handles.list_visual,'String',['None' gate_names_pre]);
        set(handles.list_visual,'Min',1,'Max',10);
        set(handles.list_visual,'Value',1);

    %If the selected gates only came from current imageID
    else
        
        %Get gate name of current image
        [  ~, gate_names_pre, ~,~ ] = getimageids_of_selectedgates(Sample_Set_arranged,HashID,selected_gates,allids);
        
        %Set it to null string
        set(handles.list_visual,'String',['None' gate_names_pre]);
        set(handles.list_visual,'Value',1);
        
    end
    
else
    %List subsample box stays empty
    set(handles.list_visual,'String','');
    set(handles.list_visual,'Value',1);
end 


%Save new gate context
put('gateContext', gate_indices);

%Save new channel names
put('list_channels', channel_names);

%Pass control back to GUI
uicontrol(handles.list_samples);

end


