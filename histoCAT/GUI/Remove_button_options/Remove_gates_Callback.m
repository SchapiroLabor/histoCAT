function Remove_gates_Callback
% REMOVE_GATES_CALLBACK: Removes the selected gates from the session.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Retrieve GUI variables
gates = retr('gates');
hplots_gates = retr('hplots_gates');
hplots = retr('hplots');
tabmaster_histonetiff = retr('tabmaster_histonetiff');
hist_plot = retr('hist_plot');

%If only originally loaded gates are selected
if isempty(get(handles.list_samples, 'Value')) ~= 1
    
    %Get indices from samples listbox
    org_gates = get(handles.list_samples,'Value');
    
    %If all gates are removed, display nothing in list_channels box
    if size(org_gates,2) == size(gates,1)
        set(handles.list_samples,'String','');
        set(handles.list_visual,'String','');
        set(handles.list_heatmap,'String','');
        set(handles.list_channels,'String','');
        set(handles.list_channels,'Value',1);
        
        %Switch off all the GUI features, which are not necessary before loading samples
        set(handles.analyze_button,'Enable','off');
        set(handles.visualize_button,'Enable','off');
        set(handles.preparesample_button,'Enable','off');
        set(handles.remove_options,'Enable','off');
        set(handles.areaxy_onoff,'Visible','off');
        set(handles.mask_onoff,'Visible','off');
        set(handles.areaxy_onoff,'Callback',@areaxy_checkbox_Callback);
        
        %Remove plots if there are any
        delete(handles.panel_plots.Children);
        
        %Remove tiff-image tabs ifthere are any
        if isempty(tabmaster_histonetiff) ~= 1
            tabmaster_histonetiff.delete;
            handles.panel_tiff_images.Children.delete
        end
        
    end
    
    %Function call to remove gates from all involved variables
    removegates_commonfunction(org_gates);
    
%If no gates were selected, prompt user
else
    uiwait(msgbox('No gates selected'));
    return;
    
end

%Retrieve the gates
gates = retr('gates');

%If there are gates
if (~isempty(gates))
    
    %Update GUI handles.
    set(handles.list_samples,'String',gates(:, 1));
    set(handles.list_samples,'Value',1);
    
    %Update list boxes
    list_samples_Callback;
       
end

end



