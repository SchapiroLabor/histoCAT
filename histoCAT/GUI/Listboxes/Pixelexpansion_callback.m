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

pixelexpansion = handles.pixelexpansion_dropdown.String(handles.pixelexpansion_dropdown.Value);
put('pixelexpansion',pixelexpansion);


end