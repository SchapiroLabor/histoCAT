function visualize_button_Callback(hObject, eventdata, handles)
% VISUALIZE_BUTTON_CALLBACK: Gets called whenever visualiuze button is pressed
% and executes the chosen visualize option.
%
% hObject: handle to figure (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles and global variables
handles = gethand;
global Sample_Set_arranged;
global Fcs_Interest_all;
global Mask_all;
global HashID;

%Set gating variable to zero (previous gates)
gatedontiff = 0;
put('gatedontiff',gatedontiff);

%Disable all other toolbar options before visualizing
zoom off;
pan off;
rotate3d off;
datacursormode off;

%If gate on tiff option is selected in visualize options drop down menu
if strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Gate an area on Tiff image') == 1
    
    %Retrieve current image tabs
    tabmaster_histonetiff = retr('tabmaster_histonetiff');
    set(tabmaster_histonetiff.SelectedTab.Children.findobj('type','axes').Children.findobj('type','image'),'Visible','on');
    
    %Visualize cell centroids
    areaxy = tabmaster_histonetiff.SelectedTab.Children.findobj('Tag','Areaplot');
    set(areaxy,'Visible','on');
    
    %Set current axes
    current_axes = tabmaster_histonetiff.SelectedTab.Children.findobj('Type','axes');

    %If the current axes is not empty, call area selection tool function
    if isempty(current_axes) == 1
        return;
        
    else
        %Function call to select area on tiff
        Area_selection_Tiff(current_axes,Sample_Set_arranged,Mask_all,Fcs_Interest_all);
        
        %Retrieve data of area selection tool
        area_selected = retr('area_selected');
        
        %If sample was not segmented, area_selected is empty and no cells
        %can be gated
        if isempty(area_selected) ~= 1
            
            %Update gating variable
            gatedontiff = 1;
            put('gatedontiff',gatedontiff);
            
            %Function call to ask user about saving the gate
            Selection_save_questions( Sample_Set_arranged,Fcs_Interest_all,HashID );
        end
    end
    
    
%If highlight sample on tiff option was selected in visualize options drop down
%menu
elseif strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Highlight sample on Tiff images') == 1
    
    %Function call to get the imageIDs of the selected samples
    [imageids,gate_names, SGsof_imageids_open,sample_orderIDX ] = choosetiffs_overlay_Callback;
    
    %Function call to apply the channel colors to Image (RGBCMY) based on
    %user selection
    overlay_maskandchannels( Mask_all,Fcs_Interest_all,imageids,gate_names,SGsof_imageids_open,sample_orderIDX );
    
    %Function call to highlight the cells of interest(from selected gate)
    show_selected_area_onTiff( Sample_Set_arranged,HashID,Fcs_Interest_all,Mask_all );
    
    %Set the channels list selection (between 1 and 6 channels can be
    %visualized simultaneouslynin RGBCMY)
    set(handles.list_channels,'Min',1,'Max',6);
    
    %Reset channels list incase RGBCMY image was used before
    channels = retr('list_channels');
    set(handles.list_channels,'String',channels);
    put('valchannel',{});
     
    
%If apply RGBCMY option was selected in visualize options drop down menu
elseif strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Apply RGBCMY on selected samples') == 1
    
    %Function call to get the imageIDs of the selected samples
    [imageids,gate_names, SGsof_imageids_open,sample_orderIDX ] = choosetiffs_overlay_Callback;
    
    %Function call to overlay RGBCMY channels based on user selection
    overlay_maskandchannels( Mask_all,Fcs_Interest_all,imageids,gate_names,SGsof_imageids_open,sample_orderIDX );
    
    
%If Heatmap channel on selected samples option was selected in the
%visualize options drop down menu
elseif strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Heatmap channel on selected samples') == 1
    
    %Get currently selected channels
    curchan = get(handles.list_channels,'Value');
    
    %Reset channels list in case RGBCMY was used before
    channels = retr('list_channels');
    set(handles.list_channels,'String',channels);
    
    %If multiple channels are selected, set only the first one to selected
    %(this option visualizes only one channel at the time)
    if isempty(curchan) ~= 1
        set(handles.list_channels,'Value',curchan(1));
    else
        set(handles.list_channels,'Value',1);
    end
    
    %Function call to get the imageIDs of the selected samples
    [imageids,gate_names, SGsof_imageids_open,sample_orderIDX ] = choosetiffs_overlay_Callback;
    
    %Function call to visualize image
    overlay_maskandchannels( Mask_all,Fcs_Interest_all,imageids,gate_names,SGsof_imageids_open,sample_orderIDX );
    
    %Set the channels list selection
    set(handles.list_channels,'Min',1,'Max',3);
    
    %Function call to create slider for intensity scaling (percentile
    %cut-off) of heatmap
    Heatmap_slider(curchan);
    
    
%If Highlight excluding selected sample option is selected in the visualize
%options drop down menu
elseif get(handles.visualize_options,'Value') == 6
    
    %Function call to get the imageIDs of the selected samples
    [imageids,gate_names, SGsof_imageids_open,sample_orderIDX ] = choosetiffs_overlay_Callback;
    
    %Function call to visualize selected RGBCMY channels
    overlay_maskandchannels( Mask_all,Fcs_Interest_all,imageids,gate_names,SGsof_imageids_open,sample_orderIDX );
    
    %Function call to show the ungated/unselected area
    show_ungatedareaonTiff( Sample_Set_arranged,HashID,Fcs_Interest_all,Mask_all );
    
    %Set the channels list selection
    set(handles.list_channels,'Min',1,'Max',6);
    
    %Reset channels list incase RGBCMY was used before
    channels = retr('list_channels');
    set(handles.list_channels,'String',channels);
    put('valchannel',{});   
end

end

