function visualize_options_Callback(hObject, eventdata, handles)
% VISUALIZE_OPTIONS_CALLBACK: Executes on any change in the visualize options
% drop down menu.
%
% hObject: handle to figure (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Switch off external operations of GUI
zoom off;
pan off;
rotate3d off;
datacursormode off;

%Get GUI handles, retrieve GUI variables and get global variables
handles = gethand;
selected_gates = get(handles.list_samples,'Value');
allids = retr('allids');
global Sample_Set_arranged;
global HashID;


%If no specific option is selected
if strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'View Options') == 1
    
    %Empty RGBCMY channel values
    valchannel = {};
    put('valchannel',valchannel);
    
    %Hide the plot area xy checkbox
    set(handles.areaxy_onoff,'Visible','off');
    
    %Hide the mask on/off checkbox
    set(handles.mask_onoff,'Visible','off');
    
    %Set the list_visual box string and value to empty
    set(handles.list_visual,'String','');
    set(handles.list_visual,'Value',1);

    
%If Gate and area on Tiff image option is selected
elseif strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Gate an area on Tiff image') == 1
    
    %Set the analyze options drop down menu to null (first value)
    set(handles.analyze_options,'Value',1);
    
    %Hide the plot area xy checkbox
    set(handles.areaxy_onoff,'Visible','off');
    
    %Hide the mask on/off checkbox
    set(handles.mask_onoff,'Visible','off');

    
%If Highlight sample on Tiff is selected
elseif strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Highlight sample on Tiff images') == 1
    
    %Empty mask outline
    put('maskoutline',[]);    
    
    %Set analyze options drop down menu to null
    set(handles.analyze_options,'Value',1);
    
    %Show the plot area xy checkbox (check to visualize the cell centroids)
    set(handles.areaxy_onoff,'Visible','on');
    
    %Show the mask on/off checkbox (check to display the mask outlines)
    set(handles.mask_onoff,'Visible','on');
    
    %Function call to set list_visual list box to display the gates that
    %contain cells of the current sample
    Set_listVisualSamples( handles,allids,selected_gates,Sample_Set_arranged,HashID );
    
    
%If apply RGBCMY is selected
elseif strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Apply RGBCMY on selected samples') == 1
    
    %Empty mask outline
    put('maskoutline',[]);
    
    %Call list_change function to apply RGBCMY colors to listbox
    set(handles.list_channels,'Callback',@list_change_Callback);

    %Set analyze options drop down menu to null
    set(handles.analyze_options,'Value',1);
    
    %Show the plot area xy checkbox
    set(handles.areaxy_onoff,'Visible','on');
    
    %Show the mask on/off checkbox
    set(handles.mask_onoff,'Visible','on');
    
    %Function call to set list_visual list box to display the gates that
    %contain cells of the current sample
    Set_listVisualSamples( handles,allids,selected_gates,Sample_Set_arranged,HashID );
    
    
%If Heatmap channel on selected samples option is selected
elseif strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Heatmap channel on selected samples') == 1
    
    %Set channels list callback
    set(handles.list_channels,'Callback',@list_channels_Callback);
    
    %Empty mask outline
    put('maskoutline',[]);
    
    %Empty RGBCMY channel values
    valchannel = {};
    put('valchannel',valchannel);

    %Set analyze options drop down menu to null
    set(handles.analyze_options,'Value',1);
    
    %Show the plot area xy checkbox
    set(handles.areaxy_onoff,'Visible','on');
    
    %Show the mask on/off checkbox
    set(handles.mask_onoff,'Visible','on');
    
    %Function call to set list_visual list box to display the gates that
    %contain cells of the current sample
    Set_listVisualSamples( handles,allids,selected_gates,Sample_Set_arranged,HashID );
 
    
%If Highlight excluding selected sample option is selected
elseif get(handles.visualize_options,'Value') == 6
    
    %Empty mask outline
    put('maskoutline',[]);
        
    %Set the analyze options drop down menu to null
    set(handles.analyze_options,'Value',1);
    
    %Show the plot area xy checkbox
    set(handles.areaxy_onoff,'Visible','on');
    
    %Show the mask on/off checkbox
    set(handles.mask_onoff,'Visible','on');
    
    %Function call to set list_visual list box to display the gates that
    %contain cells of the current sample
    Set_listVisualSamples( handles,allids,selected_gates,Sample_Set_arranged,HashID );

end


end

