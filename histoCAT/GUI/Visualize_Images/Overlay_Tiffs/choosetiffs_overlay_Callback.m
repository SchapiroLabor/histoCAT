function [imageids,gate_names_pre, SGsof_imageids_open,sample_orderIDX ] = choosetiffs_overlay_Callback(hObject, eventdata, handles)
% CHOOSETIFFS_OVERLAY_CALLBACK: This function is called when any of the visualize 
% options (excpet for gating) are selected. It takes the selected gates and 
% the selected channels and finds them in the entire SampleSet (which contains 
% all samples loaded in the current session). This SampleSet is only erased when
% the user closes the session.
%
% hObject: handle to figure (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Initialize variables
put('SGsof_imageids_open',{});
put('save_index',[]);
put('gate_names',{});

%Get GUI handles and global variables
handles = gethand;
global Sample_Set_arranged;
global HashID;
selected_gates = get(handles.list_samples,'Value');
allids = retr('allids');

%Function call to get the imageIDs, gate names and indices of the selected gates
[imageids, gate_names_pre, SGsof_imageids_open,sample_orderIDX ] = getimageids_of_selectedgates(...
    Sample_Set_arranged,HashID,selected_gates, allids);

%Store the gate names in a new variable
gate_names = gate_names_pre;

%Update gui variables
put('gate_names',gate_names);
put('SGsof_imageids_open',SGsof_imageids_open);
put('imageids',imageids);
put('sample_orderIDX',sample_orderIDX);

end
