function list_change_Callback( hObject, eventdata, handles )
% LIST_CHANGE_CALLBACK: This function is onlyused for RGBCMY (to display the listbox channels in colors
% selected by user)
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

%Retrieve variables
channels = retr('list_channels');

%If apply RGB option is selected from visualize options drop down menu
if strcmp(handles.visualize_options.String{handles.visualize_options.Value},...
        'Apply RGBCMY on selected samples') == 1
    
    %Set the list channels min and max values to be selected (more than 6
    %channels can not be visualized simulateously)
    set(handles.list_channels,'Min',1,'Max',6);
    
    %The selected channels are stored in the order the user clicked them
    %for the RGBCMY colors
    persistent valchannel
    if numel(valchannel) < numel(hObject.Value)
        valchannel = union(valchannel,hObject.Value,'stable');
    elseif numel(valchannel) > numel(hObject.Value)
        valchannel = intersect(valchannel,hObject.Value,'stable');
    elseif (numel(valchannel) == numel(hObject.Value)) && numel(hObject.Value) == 1
        valchannel = hObject.Value;
    end
    
    %Check how many values were selected by user
    %If only the first channel(Red) is selected 
    if numel(valchannel) == 1
        
        %Refresh the list
        set(handles.list_channels,'String',channels);
        %Get the string of the channel name
        origstring = get(handles.list_channels,'String');
        %Store the selected channel's name
        origname = origstring{valchannel(1)};
        
        %Sample html to update as red
        htmlname = sprintf('<HTML><BODY bgcolor="%s">%s</BODY></HTML>', 'red', origname);
        %Store the channel's name as the htmlname
        origstring{valchannel(1)} = htmlname;
        
        %Update the list box channels
        set(handles.list_channels, 'String', origstring);
        
    %If two channels are selected
    elseif numel(valchannel) == 2
        
        %Get the string of the channel names
        origstring = get(handles.list_channels,'String');
        %Store the second selected channel's name
        origname = origstring{valchannel(2)};
        
        %Sample html to update as green
        htmlname = sprintf('<HTML><BODY bgcolor="%s">%s</BODY></HTML>', 'green', origname);
        %Store the second channel's string as the htmlname
        origstring{valchannel(2)} = htmlname;
        
        %Update the list box channels
        set(handles.list_channels, 'String', origstring);
        
    %If three channels are selected
    elseif numel(valchannel) == 3
        
        %Get the string of the channel names
        origstring = get(handles.list_channels,'String');
        %Store the third selected channel's name
        origname = origstring{valchannel(3)};
        
        %Sample html to update as blue
        htmlname = sprintf('<HTML><BODY bgcolor="%s">%s</BODY></HTML>', 'blue', origname);
        %Store the third channel's string as the htmlname
        origstring{valchannel(3)} = htmlname;
        
        %Update the list box channels
        set(handles.list_channels, 'String', origstring);
        
    %If four channels are selected
    elseif numel(valchannel) == 4
        
        %Get the string of the channel names
        origstring = get(handles.list_channels,'String');
        %Store the fourth selected channel's name
        origname = origstring{valchannel(4)};
        
        %Sample html to update as cyan
        htmlname = sprintf('<HTML><BODY bgcolor="%s">%s</BODY></HTML>', '#00FFFF', origname);
        %Store the fourth channel's string as the htmlname
        origstring{valchannel(4)} = htmlname;
        
        %Update the list box channels
        set(handles.list_channels, 'String', origstring);
        
    %If five channels are selected
    elseif numel(valchannel) == 5
        
        %Get the string of the channel names
        origstring = get(handles.list_channels,'String');
        %Store the fifth selected channel's name
        origname = origstring{valchannel(5)};
        
        %Sample html to update as magenta
        htmlname = sprintf('<HTML><BODY bgcolor="%s">%s</BODY></HTML>', '#FF00FF', origname);
        %Store the fifth channel's string as the htmlname
        origstring{valchannel(5)} = htmlname;
        
        %Update the list box channels
        set(handles.list_channels, 'String', origstring);
        
    %If six channels are selected
    elseif numel(valchannel) == 6
        
        %Get the string of the channel names
        origstring = get(handles.list_channels,'String');
        %Store the sixth selected channel's name
        origname = origstring{valchannel(6)};
        
        %Sample html to update as yellow
        htmlname = sprintf('<HTML><BODY bgcolor="%s">%s</BODY></HTML>', '#FFFF00', origname);
        %Store the channel's string as the htmlname
        origstring{valchannel(6)} = htmlname;
        
        %Update the list box channels
        set(handles.list_channels, 'String', origstring);
        
    %If more than six channels are selected
    elseif numel(valchannel) > 6
        
        %Can visualize only 6 channels at the time, so unselect the
        %additional ones
        set(handles.list_channels,'Value',valchannel(1:6));
        valchannel(7:end) = [];
    end
    
    %Store the values selected by RGBCMY
    put('valchannel',valchannel);
    
    %Find the channels that were not selected
    valuesntselected = find(~ismember(1:numel(channels),valchannel));
    %Get the original channel names of those that were not selected
    origname = [channels(valuesntselected)];
    
    %Get the current string(with rgbcmy), if there is any
    origstring = get(handles.list_channels,'String');

    %Store the not selected names in the current channel list(this is incase the user had unselected any RGBCMY
    origstring(valuesntselected) = origname;
    %Set them to the current list_channels
    set(handles.list_channels, 'String', origstring);
    
end


end

