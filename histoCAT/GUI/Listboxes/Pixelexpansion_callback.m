function Pixelexpansion_callback(hObject, eventdata, handles)
% PIXELEXPANSION_CALLBACK: Executes on selection 
% change in pixelexpansion_dropdown.
%
% hObject: handle to pixelexpansion_dropdown
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Check which number was selected and store it in pixelexpansion variable
if strcmp(handles.pixelexpansion_dropdown.String{handles.pixelexpansion_dropdown.Value},'1') == 1
    pixelexpansion ='1';
    put('pixelexpansion',pixelexpansion);
    
elseif strcmp(handles.pixelexpansion_dropdown.String{handles.pixelexpansion_dropdown.Value},'2') == 1
    pixelexpansion ='2';
    put('pixelexpansion',pixelexpansion);
    
elseif strcmp(handles.pixelexpansion_dropdown.String{handles.pixelexpansion_dropdown.Value},'3') == 1
    pixelexpansion ='3';
    put('pixelexpansion',pixelexpansion);
    
elseif strcmp(handles.pixelexpansion_dropdown.String{handles.pixelexpansion_dropdown.Value},'4') == 1
    pixelexpansion ='4';
    put('pixelexpansion',pixelexpansion);
    
elseif strcmp(handles.pixelexpansion_dropdown.String{handles.pixelexpansion_dropdown.Value},'5') == 1
    pixelexpansion ='5';
    put('pixelexpansion',pixelexpansion);
    
elseif strcmp(handles.pixelexpansion_dropdown.String{handles.pixelexpansion_dropdown.Value},'6') == 1
    pixelexpansion ='6';
    put('pixelexpansion',pixelexpansion);
    
end

end